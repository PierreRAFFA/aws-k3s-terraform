# aws-k3s-terraform

K3s cluster build with Terraform and deployed on AWS EC2 instances.
The container-runtime used is Docker.

The cluster runs 2 Go apps (app1, app2) which serve a api server on port 8080.  
The api route are respectively:
 - `GET /api/app1'
 - `GET /api/app2'

# Technical Overview

- k3s
- Helm
- AWS
- Docker
- Terraform
- Bash
- Go

# Install

Once the k3s master up and running, get k3s config in the master node
```sh
cat /etc/rancher/k3s/k3s.yaml
```


# Commands

@Todo cleanup below

k3s check-config
kubectl cluster-info
kubectl get endpoints -A


kubectl --kubeconfig ./k3s/kubeconfig.yaml get nodes
kubectl --kubeconfig ./k3s/kubeconfig.yaml apply -f ./k3s/app1.yaml
kubectl --kubeconfig ./k3s/kubeconfig.yaml get pods

# Get ccm logs
kubectl logs -l k8s-app=aws-cloud-controller-manager -n kube-system 
kubectl -n kube-system logs aws-cloud-controller-manager-5cfzk

# Retry deployment apps after error like `ImagePullBackOff`
kubectl replace --force -f ./k3s/app1.yaml

## Documentation
Cluster Access
https://rancher.com/docs/k3s/latest/en/cluster-access/

## From workers, list the images
sudo /usr/local/bin/ctr images ls

## From workers, list the containers
sudo /usr/local/bin/ctr containers list

## From workers, pull an image
sudo /usr/local/bin/crictl pull --creds AWS:$(aws ecr get-login-password --region eu-west-2) 940432861086.dkr.ecr.eu-west-2.amazonaws.com/app1:latest

# Create secret from the master for ecr login of the workers
kubectl create secret docker-registry regcred   --docker-server=940432861086.dkr.ecr.eu-west-2.amazonaws.com  --docker-username=AWS --docker-password=$(aws ecr get-login-password --region eu-west-2)




Install Helm:
https://rancher.com/docs/rancher/v2.0-v2.4/en/installation/resources/advanced/helm2/helm-init/

## Credits
Install Helm:
https://gist.github.com/icebob/958b6aeb0703dc24f436ee8945f0794f


## Debug 
kubectl -n kube-system logs aws-cloud-controller-manager-kbjwb



