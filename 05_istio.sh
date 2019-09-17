# Install crd and prerequisites
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.2.2 sh - 
cd istio-1.2.2 

export PATH=$PWD/bin:$PATH 

for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done 

# Install Istio
kubectl apply -f install/kubernetes/istio-demo.yaml 


# Check services and pods from istio
kubectl get svc -n istio-system 
kubectl get pods -n istio-system 

 
# Set automatic istio injection for every pod
kubectl label namespace default istio-injection=enabled 

# Uninstall Istio
kubectl delete ns istio-system
kubectl delete -f install/kubernetes/istio-demo.yaml
for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl delete -f $i; done