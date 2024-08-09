output "alb_dns_name" {
  value = module.zdd_application.alb_dns_name
}

output "subnets" {
  value = data.aws_subnets.subnets.ids
}