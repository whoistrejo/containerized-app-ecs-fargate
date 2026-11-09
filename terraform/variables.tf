variable "aws_region" { type = string, default = "us-east-1" }
variable "project_name" { type = string, default = "portfolio-ecs-web" }
variable "container_image" { type = string, description = "ECR image URI, including tag." }
