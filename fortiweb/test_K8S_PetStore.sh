# #####################################
# Initialize
# #####################################

# Use these host/port to access Istio Ingress
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}') 
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}') 
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}') 
echo ${INGRESS_HOST}:${INGRESS_PORT}

# Use these to access Pet Store service directly (bypass FortiWeb)
PETSTORE_IP=$(kubectl get svc petstore -o jsonpath='{.spec.clusterIP}')
PETSTORE_PORT=$(kubectl get svc petstore -o jsonpath='{.spec.ports[0].port}')


# #####################################
# Get Pets by status
# #####################################

# Directly to Service
curl -X GET "http://${PETSTORE_IP}:${PETSTORE_PORT}/v3/pet/findByStatus?status=available" -H  "accept: application/json"|jq

# Using Istio Gateway
curl -X GET "http://${INGRESS_HOST}:${INGRESS_PORT}/v3/pet/findByStatus?status=available" -H  "accept: application/json"

# Via FortiWeb
curl -X GET "http://192.168.100.40:8080/v3/pet/findByStatus?status=available" -H  "accept: application/json"


# #####################################
# Test Wrong Parameters
# #####################################

# Directly to Service
curl -X GET "http://${PETSTORE_IP}:${PETSTORE_PORT}/v3/pet/findByStatus?status=1" -H  "accept: application/json"|jq

# Using Istio Gateway
curl -X GET "http://${INGRESS_HOST}:${INGRESS_PORT}/v3/pet/findByStatus?status=1" -H  "accept: application/json"

# Via FortiWeb
curl -X GET "http://192.168.100.40:8080/v3/pet/findByStatus?status=1" -H  "accept: application/json"


# #####################################
# Test Wrong Calls
# #####################################

# Directly to Service
curl -X GET "http://${PETSTORE_IP}:${PETSTORE_PORT}/v3/pet/findByStatusWRONGCALL?status=available" -H  "accept: application/json"|jq

# Using Istio Gateway
curl -X GET "http://${INGRESS_HOST}:${INGRESS_PORT}/v3/pet/findByStatusWRONGCALL?status=available" -H  "accept: application/json"

# Via FortiWeb
curl -X GET "http://192.168.100.40:8080/v3/pet/findByStatusWRONGCALL?status=available" -H  "accept: application/json"



