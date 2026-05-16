output "jenkins_public_ip" {
  description = "IP pública del servidor de Jenkins"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL de acceso a la interfaz web de Jenkins"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "load_balancer_dns" {
  description = "Dirección DNS del balanceador de carga para acceder a la web"
  value       = aws_lb.alb.dns_name
}

output "s3_bucket_name" {
  description = "Nombre exacto del bucket S3 generado por Terraform"
  value       = aws_s3_bucket.artifacts.id
}

# --- NUEVOS OUTPUTS PARA LA BASE DE DATOS ---

output "rds_endpoint" {
  description = "Punto de conexión (host) de la base de datos PostgreSQL"
  value       = aws_db_instance.db.endpoint
}

output "rds_address" {
  description = "Dirección limpia (sin el puerto) para usar en tu PHP"
  value       = aws_db_instance.db.address
}
