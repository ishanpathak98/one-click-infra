output "alb_dns_name" {
  description = "Public ALB DNS"
  value       = aws_lb.alb.dns_name
}
