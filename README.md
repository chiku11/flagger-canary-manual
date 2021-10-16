## Run the setup

./setup.sh

## Install hello world V1 first time.
helm upgrade --install hello-world ./charts --values ./values/v1.yaml

## Install hello world V2.
helm upgrade --install hello-world ./charts --values ./values/v2.yaml

## Testing

Go to browser and open the url and you will get response from v1.

Hello version: v1, instance: helloworld-6b958d6685-qrvz2

Go to terminal and run the curl. You will get response from v2.

curl http://helloworld.local/hello -i -H "user-agent: canary"

Hello version: v2, instance: helloworld-6b958d6685-qxva1


## Once satisified edit canaries
change halt to approve
kubectl patch $(kubectl get canaries.flagger.app -o name) --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/approve"}]'

After few minutes all the traffic will be shifted to the new release.


## If things go bad with canary

Rollback

# option 1

kubectl patch $(kubectl get canaries.flagger.app -o name) --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/2/url", "value":"http://flagger-loadtester.istio-system/rollback/open"}]'

Waiting couple of minutes and then close it

kubectl patch $(kubectl get canaries.flagger.app -o name) --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/2/url", "value":"http://flagger-loadtester.istio-system/rollback/close"}]'

# option 2 
kubectl -n istio-system exec -it $(kubectl -n istio-system get pods -l app=loadtester -o name) -- /bin/sh

the below curl will rollback
curl -d '{"name":"helloworld","namespace":"default"}' http://localhost:8080/rollback/open

close once done
curl -d '{"name":"helloworld","namespace":"default"}' http://localhost:8080/rollback/close


# Updated options
Rollback
kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/3/url", "value":"http://flagger-loadtester.istio-system/rollback/open"}]'

kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/3/url", "value":"http://flagger-loadtester.istio-system/rollback/check"}]'


Promote
kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/approve"}]'

kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/check"}]'