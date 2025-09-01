#!/bin/bash
kubectl -n argocd patch deployment argocd-repo-server --patch-file patch-argo-reposerver.yaml