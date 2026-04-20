variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "project_name" {
  description = "Project name prefix used in tags and names"
  type        = string
  default     = "online-catalog"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH to EC2 (use your IP/32)"
  type        = string
}
