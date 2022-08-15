#!/bin/bash

set -o xtrace

systemctl stop kubelet
/etc/eks/bootstrap.sh '${cluster_name}' \
  --b64-cluster-ca '${cluster_auth_base64}' \
  --apiserver-endpoint '${endpoint}' \
  --kubelet-extra-args '"--allowed-unsafe-sysctls=net.ipv4.ip_forward"'