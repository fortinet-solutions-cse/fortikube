
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml 

kubectl proxy --address 0.0.0.0 --accept-hosts='^.*' & 

# Access: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ 
 

#################################################
# Dashboard can be accessed only locally. Need to create an ssh tunnel
#################################################

ssh -L 8001:localhost:8001 student@10.210.9.140 

#################################################
# Create Admin user for dashboard 
#################################################

cat >dashboard-adminuser.yaml << EOF 
apiVersion: v1 
kind: ServiceAccount 
metadata: 
  name: admin-user 
  namespace: kube-system 
EOF 

cat >dashboard-clusterrolebinding.yaml << EOF 
apiVersion: rbac.authorization.k8s.io/v1 
kind: ClusterRoleBinding 
metadata: 
  name: admin-user 
roleRef: 
  apiGroup: rbac.authorization.k8s.io 
  kind: ClusterRole 
  name: cluster-admin 
subjects: 
- kind: ServiceAccount 
  name: admin-user 
  namespace: kube-system 
EOF 

  
kubectl apply -f dashboard-adminuser.yaml 
kubectl apply -f dashboard-clusterrolebinding.yaml 


#################################################
# Get token for signing into dashboard
#################################################

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') 
 

#################################################
# Uninstall 
#################################################

# Check this first:
kubectl get secret,sa,role,rolebinding,services,deployments --namespace=kube-system | grep dashboard 


# Execute this to uninstall automatically 
kubectl delete deployment kubernetes-dashboard --namespace=kube-system  
kubectl delete service kubernetes-dashboard  --namespace=kube-system  
kubectl delete role kubernetes-dashboard-minimal --namespace=kube-system  
kubectl delete rolebinding kubernetes-dashboard-minimal --namespace=kube-system 
kubectl delete sa kubernetes-dashboard --namespace=kube-system  
kubectl delete secret kubernetes-dashboard-certs --namespace=kube-system 
kubectl delete secret kubernetes-dashboard-key-holder --namespace=kube-system 
