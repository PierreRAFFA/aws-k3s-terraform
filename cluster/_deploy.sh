#!/bin/bash

helm lint aws-k3s 
helm install --kubeconfig ./kubeconfig.yaml --dry-run --debug aws-k3s ./aws-k3s