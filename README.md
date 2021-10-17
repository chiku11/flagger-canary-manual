# Run the setup

```
./setup.sh
```

### Install hello world V1. It will be primary release.

```
helm upgrade --install hello-world ./charts --values ./values/v1.yaml
```

### Install hello world V2. It will be canary release.

```
helm upgrade --install hello-world ./charts --values ./values/v2.yaml
```

# Testing

Go to browser and open the url and you will get response from v1 thats the primary.

```
http://helloworld.local/hello
```

response:

```Hello version: v1, instance: helloworld-6b958d6685-qrvz2```

Go to terminal and run the curl. You will get response from v2 thats the canary. Immportant thing to notice is the header user-agent: canry

```
curl http://helloworld.local/hello -i -H "user-agent: canary"
```

```Hello version: v2, instance: helloworld-6b958d6685-qxva1```


## Promoting Canary

Open the gate to approve:

### Option 1 (Recommended) using CURL:

```
kubectl -n istio-system exec -it $(kubectl -n istio-system get pods -l app=loadtester -o name) -- /bin/sh

curl -d '{"name": "helloworld","namespace":"default"}' http://localhost:8080/gate/open
curl -d '{"name": "helloworld","namespace":"default"}' http://localhost:8080/gate/approve

```

After few minutes all the traffic will be shifted to the new release.

```
curl -d '{"name": "helloworld","namespace":"default"}' http://localhost:8080/gate/check 
```

should say ```Forbidden```. As the gates closes after promotion to avoid promotion of the future releases.


### Option 2 using PATCH:


```
kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/approve"}]'
```

After few minutes change it check to avoid future releases from auto approval.

```
kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/check"}]'
```

## Rollback canary release

### Option 1(Recommended) using CURL:

```
kubectl -n istio-system exec -it $(kubectl -n istio-system get pods -l app=loadtester -o name) -- /bin/sh

curl -d '{"name":"helloworld","namespace":"default"}' http://localhost:8080/rollback/open
```

After few minutes the new release will be failed and rolled back.

```
curl -d '{"name":"helloworld","namespace":"default"}' http://localhost:8080/rollback/check 
```

should say rollout ```Forbidden```. As the gate closes after rollback to avoid rollback for future releases.


### Option 2 using PATCH:

kubectl patch $(kubectl get canaries.flagger.app -o name) --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/2/url", "value":"http://flagger-loadtester.istio-system/rollback/open"}]'

After few minutes change it close to avoid future releases from auto approval.

kubectl patch $(kubectl get canaries.flagger.app -o name) --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/2/url", "value":"http://flagger-loadtester.istio-system/rollback/close"}]'

