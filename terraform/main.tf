data "aws_availability_zones" "available" { state = "available" }
data "aws_caller_identity" "current" {}
resource "aws_vpc" "main" { cidr_block = "10.40.0.0/16", enable_dns_support = true, enable_dns_hostnames = true }
resource "aws_internet_gateway" "main" { vpc_id = aws_vpc.main.id }
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = ["10.40.1.0/24", "10.40.2.0/24"][count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0", gateway_id = aws_internet_gateway.main.id }
}
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "alb" {
  name = "${var.project_name}-alb"
  vpc_id = aws_vpc.main.id
  ingress { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}
resource "aws_security_group" "task" {
  name = "${var.project_name}-task"
  vpc_id = aws_vpc.main.id
  ingress { from_port = 8080, to_port = 8080, protocol = "tcp", security_groups = [aws_security_group.alb.id] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}
resource "aws_lb" "main" {
  name = substr(var.project_name, 0, 28)
  load_balancer_type = "application"
  subnets = aws_subnet.public[*].id
  security_groups = [aws_security_group.alb.id]
}
resource "aws_lb_target_group" "app" {
  name = substr("${var.project_name}-tg", 0, 32)
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  target_type = "ip"
  health_check { path = "/", matcher = "200" }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port = 80
  protocol = "HTTP"
  default_action { type = "forward", target_group_arn = aws_lb_target_group.app.arn }
}
resource "aws_ecs_cluster" "main" { name = var.project_name }
resource "aws_iam_role" "execution" {
  name = "${var.project_name}-execution"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_ecs_task_definition" "app" {
  family = var.project_name
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  execution_role_arn = aws_iam_role.execution.arn
  container_definitions = jsonencode([{
    name = "web", image = var.container_image, essential = true,
    portMappings = [{ containerPort = 8080, hostPort = 8080, protocol = "tcp" }]
  }])
}
resource "aws_ecs_service" "app" {
  name = var.project_name
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    subnets = aws_subnet.public[*].id
    security_groups = [aws_security_group.task.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name = "web"
    container_port = 8080
  }
  depends_on = [aws_lb_listener.http, aws_iam_role_policy_attachment.execution]
}
output "alb_dns_name" { value = aws_lb.main.dns_name }
