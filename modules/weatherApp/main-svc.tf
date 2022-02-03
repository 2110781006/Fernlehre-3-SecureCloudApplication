resource "aws_launch_configuration" "weatherApp-config" {
  image_id = data.aws_ami.amazon-2.image_id
  instance_type = "t3.micro"
  user_data = base64encode(templatefile("${path.module}/weatherApp.tpl",
  {WEATHERSTACK_API_TOKEN=var.weatherstackToken, GITHUB_API_TOKEN=var.gitHubToken, PUBLIC_DNS_ADDRESS=aws_elb.main_elb_weatherApp.dns_name,
    GITHUB_USER=var.githubUser, GITHUB_CLIENT_ID=var.githubClientId, GITHUB_CLIENT_SECRET=var.githubClientSecret}))
  security_groups = [aws_security_group.ingress-all-ssh-weatherApp.id, aws_security_group.ingress-all-weatherAppHttps443.id,aws_security_group.ingress-all-weatherAppHttp80.id]
  name_prefix = "${var.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg-weatherApp" {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  desired_capacity   = var.desired_instances
  max_size           = var.max_instances
  min_size           = var.min_instances
  name = "${var.name}-asg"

  launch_configuration = aws_launch_configuration.weatherApp-config.name

  health_check_type    = "ELB"
  load_balancers = [
    aws_elb.main_elb_weatherApp.id
  ]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup = "60"
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-weatherApp"
    propagate_at_launch = true
  }

}

resource "aws_elb" "main_elb_weatherApp" {
  name = "${var.name}-elb-weatherApp"
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  security_groups = [
    aws_security_group.elb_weatherAppWeb.id
  ]

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 10
    timeout = 10
    interval = 15
    target = "TCP:8080"
  }

  listener {
    lb_port = 443
    lb_protocol = "tcp"
    instance_port = "443"
    instance_protocol = "tcp"
  }

  listener {
    lb_port = 80
    lb_protocol = "tcp"
    instance_port = "80"
    instance_protocol = "tcp"
  }
}