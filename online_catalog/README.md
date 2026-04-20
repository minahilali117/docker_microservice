
# Online Catalog - Artifact-Focused Setup and Testing Guide

This README is streamlined for submission evidence. It covers what to run, what to test, and what screenshots to capture for Docker and Terraform.

## Scope Covered

1. Artifact 1: Containerization (Docker)
2. Artifact 2: Infrastructure as Code (Terraform)

## Services and Ports

1. Frontend: 3000
2. Catalog Management: 8081
3. Customer Support: 8082
4. Order Processing: 8083

## Artifact 1 - Docker (Completed)

### Requirement Mapping

1. Unique Dockerfile per microservice: completed.
2. Automated image build: completed via Docker Compose.

### Test Steps

Run from project root:

```powershell
cd online_catalog
docker compose build
docker compose up -d
docker ps
```

Verify endpoints:

1. http://localhost:3000
2. http://localhost:8081/products
3. http://localhost:8082/customers
4. http://localhost:8083/orders

Stop containers:

```powershell
docker compose down
```

### Evidence to Capture

1. Dockerfiles for each microservice.
2. `docker compose build` success output.
3. `docker compose up -d` success output.
4. `docker ps` with running containers.
5. Browser/API checks for ports 3000, 8081, 8082, 8083.

## Artifact 2 - Terraform (In Progress)

### Requirement Mapping

1. AWS Provisioning with Terraform: EC2 resource defined and applied.
2. Networking and Security: VPC, subnet, IGW, route table, and security group defined.

### Prerequisites

1. AWS CLI configured.
2. EC2 key pair exists in `us-east-1`.
3. `terraform.tfvars` has real values, especially `ssh_ingress_cidr = "your.public.ip/32"`.

### Apply Steps

Run from Terraform directory:

```powershell
cd online_catalog/infra/terraform
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
terraform output
```

### What to Test After Apply

1. AWS Console (region `us-east-1`) shows created resources:
	VPC, Subnet, Internet Gateway, Route Table, Security Group, EC2.
2. `terraform output` returns:
	`ec2_public_ip`, `ec2_public_dns`, `vpc_id`, `public_subnet_id`, `security_group_id`.
3. EC2 instance state is `running`.
4. Security group allows SSH only from your IP `/32`.

### Evidence to Capture

1. `terraform validate` success.
2. `terraform plan -out tfplan` output summary.
3. `terraform apply tfplan` completion output.
4. `terraform output` values.
5. AWS Console screenshots for EC2, VPC, Subnet, Security Group.

## Progress Checklist

- [x] Artifact 1 Dockerfiles and containerization completed.
- [x] Artifact 2 Terraform configuration written.
- [x] Terraform validate completed.
- [x] Terraform plan/apply/output executed.
- [ ] Final screenshot bundle captured for submission.

## Cost Cleanup (Free Tier Safety)

Run this when demo/testing is done:

```powershell
cd online_catalog/infra/terraform
terraform destroy
```

Capture one final screenshot of successful destroy for documentation.
