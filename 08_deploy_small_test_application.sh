# Note: disable annotations if Multus is not needed

cat <<EOF | kubectl create -f - 
apiVersion: v1 
kind: Pod 
metadata: 
  name: samplepod 
  annotations: 
    k8s.v1.cni.cncf.io/networks: macvlan-conf 
spec: 
  containers: 
  - name: samplepod 
    command: ["/bin/bash", "-c", "trap : TERM INT; sleep infinity & wait"] 
    image: dougbtv/centos-network 
EOF  

# Access application internally
k exec -it samplepod /bin/bash 