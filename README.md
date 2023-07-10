# python-api-infra-deploy
Infrastructure deployment for [python-api](https://github.com/mransbro/python-api) web application to AWS ECS using Terraform. Also automates building of docker image and pushing to ECR.

## Dependency 
* Docker
* [AWS CLI - V2](https://aws.amazon.com/cli/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)

For quick start, We can use CodeSpace follow up by setup script - [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/RuchiDhal/python-api-infra-deploy?quickstart=1)

> Docker comes pre-installed in github codespace

```bash
./setup.sh
```

## Build docker container and push to AWS-ECR

Export following ENV to configure AWS - 

```bash
export AWS_ACCESS_KEY_ID=*****************
export AWS_SECRET_ACCESS_KEY=*****************
export AWS_DEFAULT_REGION=*****************
export AWS_ACCOUNT_ID=***************** # to be used in ECR image path
```

Clone the python-api repo to build the docker image for the web application

```bash
git clone https://github.com/RuchiDhal/python-api-infra-deploy
cd python-api-infra-deploy
./docker-build-push.sh | tee docker-build-push.log
```

## Deploy the application to AWS-ECS 

Deploy the application using the docker image we build above 

Get the ECR docker image URI we just build

```bash
export AWS_ECR_DOCKER_IMAGE_URI=$(cat docker-build-push.log | grep -oP '(?<=repositoryUri": ").*?(?=")')
```

Run the terrafrom scripts with above `AWS_ECR_DOCKER_IMAGE_URI`

```bash
terraform init
terraform plan -var 'AWS_ECR_DOCKER_IMAGE_URI='"$AWS_ECR_DOCKER_IMAGE_URI"
terraform apply -var 'AWS_ECR_DOCKER_IMAGE_URI='"$AWS_ECR_DOCKER_IMAGE_URI" -auto-approve
```

## Outline of the Deployment

![](python-api-aws-ecs-deployment.svg)
