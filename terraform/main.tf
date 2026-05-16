# ==============================================================================
# CONFIGURACIÓN DEL PROVEEDOR Y RECURSOS DE DATOS GLOBALES
# ==============================================================================
provider "aws" { 
  region = var.region 
}

# Obtiene las zonas de disponibilidad dinámicas de la región
data "aws_availability_zones" "available" {}

# Filtra y encuentra la AMI oficial más reciente de Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Genera un sufijo aleatorio único para evitar colisiones de nombres en S3
resource "random_id" "suffix" { 
  byte_length = 4 
}
