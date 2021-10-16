kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/3/url", "value":"http://flagger-loadtester.istio-system/rollback/open"}]'

kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/3/url", "value":"http://flagger-loadtester.istio-system/rollback/check"}]'



kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/approve"}]'

kubectl patch canaries.flagger.app helloworld --type='json' -p='[{"op": "replace", "path": "/spec/analysis/webhooks/1/url", "value":"http://flagger-loadtester.istio-system/gate/check"}]'