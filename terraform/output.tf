output "alb_url" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.alb.dns_name
}

output "custom_domain" {
  description = "Custom domain URL"
  value       = "https://${var.domain_name}"
}

output "nameservers" {
  description = "Nameservers for the hosted zone (add these to your domain registrar)"
  value       = aws_route53_zone.main.name_servers
}
