#!/bin/bash

docker build -t 940432861086.dkr.ecr.eu-west-2.amazonaws.com/ms-users .
aws ecr get-login-password --region eu-west-2 --profile pierreraffa-deploy | docker login --username AWS --password-stdin 940432861086.dkr.ecr.eu-west-2.amazonaws.com 
docker push  940432861086.dkr.ecr.eu-west-2.amazonaws.com/ms-users