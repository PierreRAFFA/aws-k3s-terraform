#!/bin/bash
node_name=$(cat /etc/hostname)
k3s_master_secret=$(aws secretsmanager get-secret-value --secret-id ${secretsmanager_secret_id} --region ${region} --query 'SecretString' --output text)
master_private_ip=$(echo $k3s_master_secret | awk '{print $1}')
token=$(echo $k3s_master_secret | awk '{print $2}')

# curl -sfL https://get.k3s.io | K3S_TOKEN=$token K3S_URL=https://$master_private_ip:6443 K3S_KUBECONFIG_MODE="644" K3S_NODE_NAME=$node_name \

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" K3S_NODE_NAME=$node_name sh -s agent --server https://$master_private_ip:6443 \
  --token "$token"  \
  --kubelet-arg="cloud-provider=external" \
  --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
