#!/bin/bash
set -e

if [ -z ${AWS_ACCESS_KEY_ID} ]; then echo "Please set AWS_ACCESS_KEY_ID" && exit 1; fi
if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then echo "Please set AWS_SECRET_ACCESS_KEY" && exit 1; fi
if [ -z ${ENV} ]; then echo 'Please set ENV' && exit 1; fi
 
rm -rf .terraform

WORKSPACE="${ENV}-global"

terraform init && \
 
terraform workspace select $WORKSPACE

terraform plan \
    -out terraform.plan \
    -var="env=${ENV}" \
    -var="domain=${DOMAIN}" \
    -var="aws_access_key=${AWS_ACCESS_KEY_ID}" \
    -var="aws_secret_key=${AWS_SECRET_ACCESS_KEY}"
 
say "plan done"

while true; do
    read -p "Do you want to apply the terraform configuration? (yn):" yn
    case $yn in
        [Yy]* ) terraform apply terraform.plan; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

say "apply done"