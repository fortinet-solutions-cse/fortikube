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

# Direct to Service
curl -X GET "http://${PETSTORE_IP}:${PETSTORE_PORT}/v3/pet/findByStatus?status=available" -H  "accept:application/json"|jq

# Direct via Istio Gateway
curl -X GET "http://${INGRESS_HOST}:${INGRESS_PORT}/v3/pet/findByStatus?status=available" -H  "accept:application/json"

# Direct via Istio - Using DNS
watch curl -X GET "http://petstore.com:31380/v3/pet/findByStatus?status=available" -H "accept:application/json" -H "Host:petstore.com"

# Through FortiWeb via Istio - Using DNS
watch curl -X GET "http://petstore-fwb.com:31380/v3/pet/findByStatus?status=available" -H  "accept:application/json" -H "Host:petstore-fwb.com"

# Through FortiWeb (using external FWB GW, as VM) (Legacy)
curl -X GET "http://192.168.100.40:8080/v3/pet/findByStatus?status=available" -H  "accept:application/json"


# #####################################
# Test Wrong Parameters
# #####################################

# Direct to Service
curl -X GET "http://${PETSTORE_IP}:${PETSTORE_PORT}/v3/pet/findByStatus?status=1" -H  "accept:application/json"|jq

# Direct via Istio Gateway
curl -X GET "http://${INGRESS_HOST}:${INGRESS_PORT}/v3/pet/findByStatus?status=1" -H  "accept:application/json"

# Through FortiWeb (using external FWB GW, as VM) (Legacy)
curl -X GET "http://192.168.100.40:8080/v3/pet/findByStatus?status=1" -H  "accept:application/json"


# #####################################
# Test Wrong Calls
# #####################################

# Direct to Service
curl -X GET "http://${PETSTORE_IP}:${PETSTORE_PORT}/v3/pet/findByStatusWRONGCALL?status=available" -H  "accept:application/json"|jq

# Direct via Istio Gateway
curl -X GET "http://${INGRESS_HOST}:${INGRESS_PORT}/v3/pet/findByStatusWRONGCALL?status=available" -H  "accept:application/json"

# Through FortiWeb (using external FWB GW, as VM) (Legacy)
curl -X GET "http://192.168.100.40:8080/v3/pet/findByStatusWRONGCALL?status=available" -H  "accept:application/json"


# #####################################
# Test Users accessing different urls
# #####################################

# Direct via Istio - Using DNS
curl -X GET "http://petstore.com:31380/v3/pet/findByStatus?status=available" -H "accept:application/json" -H "Host:petstore.com"
curl -X GET "http://petstore.com:31380/v3/store/inventory" -H "accept:application/json" -H "Host:petstore.com"

# Through FortiWeb via Istio - Using DNS
curl -X GET "http://petstore-fwb.com:31380/v3/pet/findByStatus?status=available" -H  "accept:application/json" -H "Host:petstore-fwb.com"
curl -X GET "http://petstore-fwb.com:31380/v3/store/inventory" -H "accept:application/json" -H "Host:petstore-fwb.com"

# User A accessing correctly findByStatus api call
curl -X GET "http://petstore-fwb.com:31380/v3/pet/findByStatus?status=available" -H "accept:application/json" -H "Host:petstore-fwb.com" -H "token:xxxxxxxx"

# User B accessing correctly store inventory
curl -X GET "http://petstore-fwb.com:31380/v3/store/inventory?token=xxxxxxxx" -H "accept:application/json" -H "Host:petstore-fwb.com"

# User B doing SQL Injection
curl -X GET "http://petstore-fwb.com:31380/v3/store/inventory?token=xxxxxxxx&select%20%2A%20from%20information_schema" -H "accept:application/json" -H "Host:petstore-fwb.com"
