# python-api-infra-deploy
Infrastructure deployment for python-api web application to AWS ECS - https://github.com/mransbro/python-api

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