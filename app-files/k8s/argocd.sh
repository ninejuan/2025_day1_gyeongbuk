#!/bin/bash

# Argo install
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Change password
# argocd가 준비된 후, 아래 명령어를 통해 argocd 비밀번호를 과제지의 지시대로 변경합니다.

#kubectl exec -it -n argocd deployment/argocd-server -- /bin/bash
#argocd login localhost:8080
#argocd account update-password