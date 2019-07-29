# Clone repo
git clone https://github.com/intel/multus-cni.git && cd multus-cni 

# Uninstall previous leftovers of multus (if needed)
kubectl delete network-attachment-definitions macvlan-conf 

 
cat <<EOF | kubectl create -f - 
apiVersion: "k8s.cni.cncf.io/v1" 
kind: NetworkAttachmentDefinition 
metadata: 
name: macvlan-conf 
spec: 
config: '{ 
    "cniVersion": "0.3.0", 
    "type": "bridge", 
    "master": "ens160", 
    "mode": "bridge", 
    "ipam": { 
        "type": "host-local", 
        "subnet": "10.244.0.0/24", 
        "rangeStart": "10.244.0.100", 
        "rangeEnd": "10.244.0.200", 
        "routes": [ { "dst": "0.0.0.0/0" } ], 
        "gateway": "10.244.0.1" 
    } 
}' 
EOF