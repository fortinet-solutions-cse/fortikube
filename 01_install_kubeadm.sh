#################################################
# Master node 
#################################################

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/ 

apt-get update && apt-get install -y apt-transport-https curl 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF

apt-get update 
apt-get install -y kubelet kubeadm kubectl 
apt-mark hold kubelet kubeadm kubectl 

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/ 
# https://www.josedomingo.org/pledin/2018/05/instalacion-de-kubernetes-con-kubeadm/ 
 

sudo apt install docker.io 
systemctl enable docker.service 


# Setup daemon. 
cat > /etc/docker/daemon.json <<EOF 
{ 
"exec-opts": ["native.cgroupdriver=systemd"], 
"log-driver": "json-file", 
"log-opts": { 
  "max-size": "100m" 
}, 
"storage-driver": "overlay2" 
} 
EOF


mkdir -p /etc/systemd/system/docker.service.d 
 
# Restart docker. 
systemctl daemon-reload 
systemctl restart docker 

# Disable swap 
swapoff -a 

 
# Start kubeadm
kubeadm init --pod-network-cidr=192.168.0.0/16 

 
#################################################
# Worker node 
#################################################

apt-get update && apt-get install -y apt-transport-https curl 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - 
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list 
deb https://apt.kubernetes.io/ kubernetes-xenial main 
EOF

apt-get update 
apt-get install -y kubelet kubeadm kubectl 
apt-mark hold kubelet kubeadm kubectl 


systemctl enable docker.service 

# Setup daemon. 
cat > /etc/docker/daemon.json <<EOF 
{ 
"exec-opts": ["native.cgroupdriver=systemd"], 
"log-driver": "json-file", 
"log-opts": { 
  "max-size": "100m" 
}, 
"storage-driver": "overlay2" 
} 
EOF

mkdir -p /etc/systemd/system/docker.service.d 

# Restart docker. 
systemctl daemon-reload 
systemctl restart docker 

# Disable swap 
swapoff -a 
