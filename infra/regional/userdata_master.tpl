#!/bin/bash

# Authorise public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYI4tfQ9YpTPSxh8bgLnPiSi2qU99LST0l9zeUnRsD8YqDUdxDoem4x/lVRxaUHr1c4VJTzF0iZ1gUGxXcsmPKnCJRpLS4/Q+hqmiRh+Gj+j+F6Z6ZPuafHKz3VTtG9BUHuYp4KOl4LvOxE1OxaJJVm16T1EFxsKIeL8FLDtS8XpbzukmDvv9KKfix04u6NDGeBRsDvpLLkEmhG9bukWDWCkDgh0DBAqkXxNvIbv4PkUjFHrb3ZevPtl/4toD8IC3vISe2xfy2R8nrnhBV/3lY+ynP3hdBaM8HM3iWbdQX1BhThUHtY4SrEwdMe2h7G3Qag1i4IgQkyR5aaa5HEeQE+nfx+jkj8aYIpj7UBE4LBPO77YALiEJYxwcfF/3w6wATJylioLeDi6wqNCatitgqDpMYvddZdkkBd1eEDQV7U2IOfv6B8qTbnOaf7g11IVtd1ptwwNTHIxgh/NP/35M2ufHsEjNQ5/zTkMxdNAUyUx3yeAP4vlUJZ9EioWaIbjRzQfhVoZUH6XHAW/orkEFnZACwtI/NNvOzDADnMD1MfH/nqjyrqTcV0UtHXNGDgY0IdERb4fC0chc1z6rtJTC+NAmiNVoa6Km3kKZa1YP014H61ISG4IxOmxatyzvQn0JI5jORoDM4baE0M+zsOY2J69lGMeu6boeRPni7T8tC4w== praffa@mediamath.com" > /home/ec2-user/.ssh/authorized_keys

# Install k3s
# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s
# from https://cloud-provider-aws.sigs.k8s.io/getting_started/
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_NAME=${cluster_id} sh -s server --disable-cloud-controller \
      --disable servicelb \
      --disable local-storage \
      --disable traefik \
      --kubelet-arg="cloud-provider=external" \
      --kubelet-arg="provider-id=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

      #--configure-cloud-routes false \ [[ PROBLEM HERE !!! ]]
      
# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server \
#   --disable-cloud-controller \
#   --disable servicelb \
#   --disable traefik \
#   --node-name="$(hostname -f)" \
#   --kubelet-arg="cloud-provider=external" \
#   --write-kubeconfig-mode=644" sh -

# Install Helm + AWS Cloud Provider
########################################
# # Copy k3s config
# mkdir $HOME/.kube
# sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
# sudo chmod 644 $HOME/.kube/config

# # # Download & install Helm
# curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > install-helm.sh
# chmod u+x install-helm.sh
# ./install-helm.sh

# # # Link Helm with Tiller
# kubectl -n kube-system create serviceaccount tiller
# kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
# helm init --service-account tiller

# Install Helm + AWS Cloud Provider (zip)
########################################

# Download and extract the AWS Cloud Provider:
# From https://gist.github.com/yankcrime/f934333aa8562be6d7d5b2ee762746b0
wget https://github.com/kubernetes/cloud-provider-aws/archive/master.zip
unzip master.zip

tar czvf /var/lib/rancher/k3s/server/static/charts/aws-ccm.tgz -C cloud-provider-aws-master/charts/aws-cloud-controller-manager .

cat > aws-ccm.yaml << EOF
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: aws-cloud-controller-manager
  namespace: kube-system
spec:
  chart: https://%%{KUBERNETES_API}/static/charts/aws-ccm.tgz
  targetNamespace: kube-system
  bootstrap: true
  valuesContent: |-
    hostNetworking: true
    nodeSelector:
      node-role.kubernetes.io/master: "true"
EOF

cp aws-ccm.yaml /var/lib/rancher/k3s/server/manifests/

# Store k3s token and master private ip in Secrets Manager
########################################
token=$(cat /var/lib/rancher/k3s/server/node-token)
master_private_ip=$(ifconfig | grep eth0 -A 1 | grep inet | awk '{print $2}')
aws secretsmanager put-secret-value --secret-id ${secretsmanager_secret_id} --secret-string "$master_private_ip $token" --region ${region}

# # Install Rancher
# mkdir -p /etc/rancher/rke2

# cat <<< "
# token: qwerty
# tls-san:
#   - $master_private_ip" > /etc/rancher/rke2/config.yaml


# curl -sfL https://get.rancher.io | sh -
# systemctl enable rancherd-server 
# systemctl start rancherd-server 

# yum update -y
# amazon-linux-extras install docker
# systemctl start docker
# usermod -a -G docker ec2-user