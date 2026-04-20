output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.app.public_dns
}

output "vpc_id" {
  description = "Provisioned VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Provisioned public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security group attached to EC2"
  value       = aws_security_group.app.id
}
