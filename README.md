# python-api-infra-deploy
Infrastructure deployment for python-api web application to AWS ECS - https://github.com/mransbro/python-api

## Dependency 
* Docker
* [AWS CLI - V2](https://aws.amazon.com/cli/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)

For quick start, We can use CodeSpace follow up by setup script (Docker comes pre-installed in github codespace) - [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/RuchiDhal/python-api-infra-deploy?quickstart=1)

```bash
./setup.sh
```

Or use this exiting DevEnv Setup - 

## Build docker container and push to AWS-ECR

For this following interaction with AWS, make sure the **aws-cli v2** configuration is done for authentication 

Export following ENV - 

```bash
export AWS_ACCESS_KEY_ID=*****************
export AWS_SECRET_ACCESS_KEY=*****************
export AWS_DEFAULT_REGION=*****************
export AWS_ACCOUNT_ID=***************** # to be used in ECR image path
```

Clone the python-api repo to build the docker image

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

![](python-api-aws-ecs-deployment.svg)
