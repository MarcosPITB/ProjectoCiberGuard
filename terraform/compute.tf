resource "aws_lb" "alb" {
  name            = "ciberguard-alb"
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "tg" {
  name     = "tg-https"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "lt-ciber-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  network_interfaces {
    security_groups = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/setup_nginx.sh", {
    db_name = var.db_name
    db_user = var.db_user
    db_pass = var.db_password
    db_port = var.db_port
    efs_id  = aws_efs_file_system.shared_code.id
  }))
}

resource "aws_autoscaling_group" "asg" {
  name                = "ciberguard-asg"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.tg.arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  
  # SOLUCIÓN CRÍTICA: Otorga permisos de AWS a la máquina para subir a S3
  iam_instance_profile   = "LabInstanceProfile"

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y openjdk-11-jre wget awscli ruby-full zip
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
              sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              apt-get update -y
              apt-get install -y jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "Jenkins-Master"
  }
}
