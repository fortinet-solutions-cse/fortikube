 
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

# Reference Example from BookInfo application:
# 
# apiVersion: networking.istio.io/v1alpha3
# kind: Gateway
# metadata:
#   name: bookinfo-gateway
# spec:
#   selector:
#     istio: ingressgateway # use istio default controller
#   servers:
#   - port:
#       number: 80
#       name: http
#       protocol: HTTP
#     hosts:
#     - "*"
# ---
# apiVersion: networking.istio.io/v1alpha3
# kind: VirtualService
# metadata:
#   name: bookinfo
# spec:
#   hosts:
#   - "*"
#   gateways:
#   - bookinfo-gateway
#   http:
#   - match:
#     - uri:
#         exact: /productpage
#     - uri:
#         prefix: /static
#     - uri:
#         exact: /login
#     - uri:
#         exact: /logout
#     - uri:
#         prefix: /api/v1/products
#     route:
#     - destination:
#         host: productpage
#         port:
#           number: 9080
#                             