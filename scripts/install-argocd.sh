#!/bin/bash
set -e

echo "Creating argocd namespace..."

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "Installing ArgoCD..."

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD..."

kubectl wait --for=condition=Available deployment/argocd-server \
-n argocd \
--timeout=600s

echo "ArgoCD Installed Successfully"
