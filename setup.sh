istioctl install --set profile=default

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/addons/prometheus.yaml

kubectl apply -f https://raw.githubusercontent.com/fluxcd/flagger/main/artifacts/flagger/crd.yaml

helm repo add flagger https://flagger.app

helm upgrade -i flagger flagger/flagger \
--namespace=istio-system \
--set crd.create=false \
--set meshProvider=istio \
--set metricsServer=http://prometheus:9090

helm upgrade -i flagger-loadtester flagger/loadtester \
--namespace=istio-system \
--set cmd.timeout=1h


kubectl apply -f gateway.yaml

