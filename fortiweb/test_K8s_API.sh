# #####################################
# Initialize
# #####################################

# Check all possible clusters, as your .KUBECONFIG may have multiple contexts:
kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

# Select name of cluster you want to interact with from above output:
export CLUSTER_NAME="kubernetes"

# Point to the API server referring the cluster name
APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

# Gets the token value
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)

# Create a cluster role to allow list operations with default service account

kubectl apply  -f - <<EOF
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: service-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods", "nodes"]
  verbs: ["get", "watch", "list"]
EOF

# Associate cluster role to service account

kubectl create clusterrolebinding service-reader-pod \
  --clusterrole=service-reader  \
  --serviceaccount=default:default
  
-----

# #####################################
# Pod listing 
# #####################################

curl -X GET $APISERVER/api/v1/namespaces/default/pods --header "Authorization: Bearer $TOKEN" --insecure

curl -X GET https://192.168.100.40:6443/api/v1/namespaces/default/pods --header "Authorization: Bearer $TOKEN" --insecure


# #####################################
# Wrong parameters test case 
# (limit should be numeric)
# #####################################

curl -X GET $APISERVER/api/v1/namespaces/default/pods?limit=de --header "Authorization: Bearer $TOKEN" --insecure

curl -X GET https://192.168.100.40:6443/api/v1/namespaces/default/pods?limit=de --header "Authorization: Bearer $TOKEN" --insecure


# #####################################
# Wrong calls
# #####################################

curl -X GET $APISERVER/api/v1/namespaces/default/podsWRONGCALL?limit=1 --header "Authorization: Bearer $TOKEN" --insecure

curl -X GET https://192.168.100.40:6443/api/v1/namespaces/default/podsWRONGCALL?limit=1 --header "Authorization: Bearer $TOKEN" --insecure


# #####################################
# Rate Limiting
# #####################################

time for i in {1..1250}; do echo Attack $i; curl  -X GET $APISERVER/api?user=<your_fwb_user_token> --header "Authorization: Bearer $TOKEN" --insecure; done 2>/dev/null


time for i in {1..1250}; do echo Attack $i; curl  -X GET https://192.168.100.40:6443/api?user=<your_fwb_user_token> --header "Authorization: Bearer $TOKEN" --insecure; done 2>/dev/null


# #####################################
# User A accessing correctly pods
# #####################################

curl -X GET "https://192.168.100.40:6443/api/v1/namespaces/default/pods?token=xxxxxxxxxx" --header "Authorization: Bearer $TOKEN" --insecure


# #####################################
# User B accessing correctly nodes
# #####################################

curl -X GET "https://192.168.100.40:6443/api/v1/nodes?token=xxxxxxxxxxxx" --hader "Authorization: Bearer $TOKEN" --insecure


# #####################################
# SQL Injection (with user token)
# #####################################

curl -X GET "$APISERVER/api/v1/namespaces/default/pods?select%20%2A%20from%20information_schema" --header "Authorization: Bearer $TOKEN" --insecure


curl -X GET "https://192.168.100.40:6443/api/v1/namespaces/default/pods?token=xxxxxxxx&select%20%2A%20from%20information_schema" --header "Authorization: Bearer $TOKEN" --insecure




