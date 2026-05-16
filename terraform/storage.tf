resource "aws_s3_bucket" "artifacts" {
  bucket = "ciberguard-artifacts-${random_id.suffix.hex}"
}

resource "aws_efs_file_system" "shared_code" {
  creation_token = "ciberguard-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "mount" {
  count           = 2
  file_system_id  = aws_efs_file_system.shared_code.id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}
