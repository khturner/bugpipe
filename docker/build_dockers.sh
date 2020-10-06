#!/usr/bin/env bash

ECR_URL=185642567037.dkr.ecr.us-east-1.amazonaws.com
IMAGE_PFX=bugpipe

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Shovill
IMAGE_NAME=shovill
docker build --no-cache -t $ECR_URL/$IMAGE_PFX/$IMAGE_NAME -f $IMAGE_NAME/Dockerfile.$IMAGE_NAME $IMAGE_NAME
aws ecr create-repository --repository-name $IMAGE_PFX/$IMAGE_NAME
docker push $ECR_URL/$IMAGE_PFX/$IMAGE_NAME

# Prokka
IMAGE_NAME=prokka
docker build --no-cache -t $ECR_URL/$IMAGE_PFX/$IMAGE_NAME -f $IMAGE_NAME/Dockerfile.$IMAGE_NAME $IMAGE_NAME
aws ecr create-repository --repository-name $IMAGE_PFX/$IMAGE_NAME
docker push $ECR_URL/$IMAGE_PFX/$IMAGE_NAME
