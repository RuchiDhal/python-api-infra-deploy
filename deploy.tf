# Configure the AWS provider
provider "aws" {
  region = var.AWS_DEFAULT_REGION 
}

# Create a VPC and subnets
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" 
}

# Create public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

# Create the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create the route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route for internet traffic
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create an ECS cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "python-api-cluster" 
}

# Create a security group for the ECS tasks
resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an IAM role for the ECS task execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create an ECS task definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family = "my-task"
  cpu = "1024"
  memory = "2048"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions    = jsonencode([
  {
    "name": "python-api-container",
    "image": var.AWS_ECR_DOCKER_IMAGE_URI,
    "portMappings": [
      {
        "name": "python-api-container-80-tcp",
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "healthCheck": {
      "command": ["CMD-SHELL", "curl -f http://localhost/ || exit 1"],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    }
  }
])

  requires_compatibilities = ["FARGATE"]  # Used Fargate launch type

  network_mode            = "awsvpc"
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
}

# Create an ECS service to run the task
resource "aws_ecs_service" "my_service" {
  name            = "python-api-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count   = 1 
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true
  }
}