# Verification
1. Run `scripts/build-and-push.sh` after configuring AWS CLI and Docker.
2. Set `container_image` to the printed ECR image URI.
3. Apply Terraform and wait for ECS service stability.
4. Run `curl -i http://$(terraform output -raw alb_dns_name)/`.
5. Inspect ECS service events, task health and CloudWatch logs.

The ALB and Fargate service incur ongoing charges while running. Destroy the stack and verify load balancer, ECS tasks, ECR images and networking resources are cleaned up. For production, use HTTPS, private task subnets, NAT/VPC endpoints, image scanning and secrets management.
