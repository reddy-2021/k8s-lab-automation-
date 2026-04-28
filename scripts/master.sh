#!/bin/bash
set -e

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
