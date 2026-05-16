# ==============================================================================
# PLANTILLA DE LANZAMIENTO (LAUNCH TEMPLATE) PARA LOS SERVIDORES WEB
# ==============================================================================
resource "aws_launch_template" "ciberguard_web_template" {
  name_prefix   = "ciberguard-web-"
  image_id      = data.aws_ami.ubuntu.id  # Utiliza dinámicamente la AMI de Ubuntu de tus filtros
  instance_type = "t2.micro"

  # Asegúrate de mantener tus bloques existentes aquí:
  # iam_instance_profile { name = ... }
  # network_interfaces { ... }

  # ESTO ES LO CRUCIAL: Mapeamos el script inyectando las variables de AWS
  user_data = base64encode(
    templatefile("${path.module}/setup_nginx.sh", {
      efs_id      = aws_efs_file_system.ciberguard_efs.id
      db_endpoint = element(split(":", aws_db_instance.cyberguard_db.endpoint), 0)
    })
  )

  lifecycle {
    create_before_destroy = true
  }
}
