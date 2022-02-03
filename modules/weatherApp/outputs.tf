output "url" {
  value = "https://${aws_elb.main_elb_weatherApp.dns_name}/swagger-ui.html"
}