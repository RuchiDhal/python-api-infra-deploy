#!/bin/bash

# Get the Python API repo and build the docker image
GITHUB_REPO_URL="https://github.com/mransbro/python-api"
REPO_NAME=$(basename "$GITHUB_REPO_URL")
DOCKER_IMAGE_NAME=$REPO_NAME
DOCKER_IMAGE_VERSION="latest"
git clone $GITHUB_URL
cd $REPO_NAME
docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION .
echo "Image build successful"

# login to ecr, needs to make sure the aws-cli v2 configuration is done for authentication 
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
# create the ecr repo
ECR_REPO_NAME=$DOCKER_IMAGE_NAME
aws ecr describe-repositories --repository-names $ECR_REPO_NAME || aws ecr create-repository --repository-name $ECR_REPO_NAME
# re-tag
docker tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:$DOCKER_IMAGE_VERSION
# push
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO_NAME:$DOCKER_IMAGE_VERSION
