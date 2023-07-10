# python-api-infra-deploy
Infrastructure deployment for python-api web application to AWS ECS - https://github.com/mransbro/python-api

## Dependency 
* [AWS CLI - V2](https://aws.amazon.com/cli/)
* [Terraform CLI](https://developer.hashicorp.com/terraform/cli)

For quick start, We can use CodeSpace follow up by setup script - [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/RuchiDhal/python-api-infra-deploy?quickstart=1)

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
./docker-build-push.sh
```

## Deploy the application to AWS-ECS 

* Replace the 

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

![](python-api-aws-ecs-deployment.svg)
