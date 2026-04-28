#!/bin/bash
set -e
hostnamectl set-hostname master

echo "🚀 Update system..."
sudo apt update -y

echo "🚀 Install containerd..."
sudo apt install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

# Enable systemd cgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "🚀 Disable swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "🚀 Enable kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "🚀 Install Kubernetes tools..."
sudo apt install -y apt-transport-https ca-certificates curl

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable kubelet

echo "✅ Common setup complete"

echo "🚀 Initialize Kubernetes Master..."
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tee /tmp/kubeadm_init.log

echo "🚀 Setup kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "🚀 Install Calico network..."
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo "🚀 Save join command..."
grep "kubeadm join" /tmp/kubeadm_init.log > /tmp/join.sh
chmod +x /tmp/join.sh

echo "✅ Master ready"

wget https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz
tar -xvf helm-v3.14.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/
