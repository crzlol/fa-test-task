output "alb_url" {
  value = "http://${aws_alb.eks.dns_name}"
}
