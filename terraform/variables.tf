variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_port" {
  default = "5432"
}

variable "region" {
  default = "us-east-1"
}
