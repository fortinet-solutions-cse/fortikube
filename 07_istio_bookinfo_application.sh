 
# https://istio.io/docs/examples/bookinfo/ 
 
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml 
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml 

# Check gateway
kubectl get gateway 

# Check services from Ingress
kubectl get svc istio-ingressgateway -n istio-system 


# Use the below host/port to ingress traffic using Istio

export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}') 
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway –o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}') 
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}') 

export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT 

# Example
curl -s http://${GATEWAY_URL}/productpage | grep -o "<title>.*</title>" 

kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml 

 