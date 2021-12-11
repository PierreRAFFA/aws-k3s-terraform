# aws-k3s-terraform

K3s cluster build with Terraform and deployed on AWS EC2 instances.
The container-runtime used is Docker.

The cluster runs 2 Go apps (ms-users, ms-payments) which serve a api server on port 8080.  
The api route are respectively:
 - **GET** /api/users/1
 - **GET** /api/payments/qwe

# Technical Overview

- k3s
- Helm
- AWS (EC2, Cloudfront, AutoscalingGroup)
- Docker
- Terraform
- Bash
- Go

# Install

### Build regional infrastructure
```sh
cd infrastructure/regional
AWS_ACCESS_KEY_ID={your_access_key} AWS_SECRET_ACCESS_KEY={your_secret} ENV=prod REGION={your_region} ./_deploy.sh
```

### Once the k3s master up and running, ssh into it and get kubeconfig from the master node
```sh
cat /etc/rancher/k3s/k3s.yaml
```

### Create secret from the master for ecr login of the workers
kubectl create secret docker-registry regcred   --docker-server=940432861086.dkr.ecr.eu-west-2.amazonaws.com  --docker-username=AWS --docker-password=$(aws ecr get-login-password --region eu-west-2)

### Install ms-users chart
```bash
cd cluster
helm install --kubeconfig ./kubeconfig.yaml  --debug -f ./aws-k3s/ms-users-values.yaml ms-users ./aws-k3s
```

### Install ms-payments chart
```bash
cd cluster
helm install --kubeconfig ./kubeconfig.yaml  --debug -f ./aws-k3s/ms-users-values.yaml ms-users ./aws-k3s
```

### Build global infrastructure
```sh
cd infrastructure/global
AWS_ACCESS_KEY_ID={your_access_key} AWS_SECRET_ACCESS_KEY={your_secret} ENV=prod REGION={your_region} ./_deploy.sh
```

# Commands

@Todo cleanup below

k3s check-config
kubectl cluster-info
kubectl get endpoints -A


kubectl --kubeconfig ./k3s/kubeconfig.yaml get nodes
kubectl --kubeconfig ./k3s/kubeconfig.yaml apply -f ./k3s/app1.yaml
kubectl --kubeconfig ./k3s/kubeconfig.yaml get pods

### Get ccm logs
kubectl logs -l k8s-app=aws-cloud-controller-manager -n kube-system 
kubectl -n kube-system logs aws-cloud-controller-manager-5cfzk

### Retry deployment apps after error like `ImagePullBackOff`
kubectl replace --force -f ./k3s/app1.yaml

### Log pod
kubectl -n kube-system logs aws-cloud-controller-manager-kbjwb

# Commands for ctr

### From workers, list the images
sudo /usr/local/bin/ctr images ls

### From workers, list the containers
sudo /usr/local/bin/ctr containers list

### From workers, pull an image
sudo /usr/local/bin/crictl pull --creds AWS:$(aws ecr get-login-password --region eu-west-2) 940432861086.dkr.ecr.eu-west-2.amazonaws.com/app1:latest

### Create secret from the master for ecr login of the workers
kubectl create secret docker-registry regcred   --docker-server=940432861086.dkr.ecr.eu-west-2.amazonaws.com  --docker-username=AWS --docker-password=$(aws ecr get-login-password --region eu-west-2)

# Documentation
Cluster Access
https://rancher.com/docs/k3s/latest/en/cluster-access/

# Credits
Install Helm:
https://gist.github.com/icebob/958b6aeb0703dc24f436ee8945f0794f
https://rancher.com/docs/rancher/v2.0-v2.4/en/installation/resources/advanced/helm2/helm-init/
