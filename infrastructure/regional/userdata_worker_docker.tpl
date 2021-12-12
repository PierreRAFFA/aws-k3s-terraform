#!/bin/bash

amazon-linux-extras enable docker 
yum -y install amazon-ecr-credential-helper
yum -y install docker
usermod -a -G docker ec2-user

systemctl daemon-reload
systemctl enable --now docker

mkdir ~/.docker
cat <<EOF >> ~/.docker/config.json
{
    "credsStore": "ecr-login"
}
EOF

node_name=$(cat /etc/hostname)
k3s_master_secret=$(aws secretsmanager get-secret-value --secret-id ${secretsmanager_secret_id} --region ${region} --query 'SecretString' --output text)
master_private_ip=$(echo $k3s_master_secret | awk '{print $1}')
token=$(echo $k3s_master_secret | awk '{print $2}')

curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" K3S_NODE_NAME=$node_name sh -s agent --docker --server https://$master_private_ip:6443 \
  --token "$token"  \
  --kubelet-arg="cloud-provider=external" \
  --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
