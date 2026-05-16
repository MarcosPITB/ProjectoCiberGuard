# Buscamos el rol que el laboratorio ya creó para nosotros
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_codedeploy_app" "web_app" {
  compute_platform = "Server"
  name             = "CiberGuard-App"
}

resource "aws_codedeploy_deployment_group" "web_dg" {
  app_name               = aws_codedeploy_app.web_app.name
  deployment_group_name  = "web-servers-dg"
  
  # Usamos el ARN del rol del laboratorio
  service_role_arn       = data.aws_iam_role.lab_role.arn
  
  autoscaling_groups     = [aws_autoscaling_group.asg.name]
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.tg.name
    }
  }
}
