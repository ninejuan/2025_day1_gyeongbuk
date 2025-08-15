#!/bin/bash
set -o xtrace

# Install required packages
yum install -y amazon-efs-utils

# Configure kubelet
/etc/eks/bootstrap.sh ${cluster_name} \
  --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=ami-0123456789abcdef0,eks.amazonaws.com/nodegroup=nodegroup-1' \
  --apiserver-endpoint ${cluster_endpoint} \
  --b64-cluster-ca ${cluster_certificate_authority_data}
