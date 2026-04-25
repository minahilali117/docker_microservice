# Online Catalog Testing Guide

This guide is for demo execution and grading. It covers only the artifacts completed so far:

1. Containerization (Docker)
2. Infrastructure as Code (Terraform)
3. Configuration as Code (Ansible)
4. Cluster Deployment (Kubernetes)
5. CI/CD (GitHub Actions and Argo CD)

Assumption for this version of the guide:

1. The project owner gives the demo from the owner laptop.
2. The collaborator contributes code and setup work, but demo commands are executed by the owner to keep flow consistent.
3. Collaboration uses one AWS account, separate IAM users, and shared Terraform remote state.

For each step, this guide includes:

1. The tool used
2. The general purpose of the tool
3. The project-specific purpose
4. Commands to run
5. What the step tests
6. Expected results

## Demo Run Order

Use this order in your demo:

1. Docker tests (Artifact 1)
2. Terraform tests (Artifact 2)
3. Ansible tests (Artifact 3)
4. Kubernetes tests (Artifact 4)
5. CI/CD tests (Artifact 5)
6. Safe shutdown and cost cleanup

Pre-demo collaboration sync:

1. Owner pulls latest code from main.
2. Owner confirms no open infra changes are being applied by collaborator.
3. Owner runs Terraform from owner laptop only during demo window.

Sync commands before demo:

```bash
git pull
cd infra/terraform
terraform init
terraform plan
```

## Artifact 1: Docker Testing

### Tool

1. Docker and Docker Compose

### General purpose of the tool

1. Build portable container images.
2. Run multi-service systems in isolated containers.
3. Start and stop many services using one command.

### Purpose in this project

1. Build and run frontend + 3 backend microservices consistently.
2. Verify each service can run from its Dockerfile.

### Commands

Run from project root:

```powershell
cd online_catalog
docker compose build
docker compose up -d
docker ps
```

Endpoint checks:

1. http://localhost:3000
2. http://localhost:8081/products
3. http://localhost:8082/customers
4. http://localhost:8083/orders

### What this tests

1. Dockerfiles are valid and build successfully.
2. Compose wiring for all services is correct.
3. Services are reachable on expected ports.
4. API paths respond correctly.

### Expected results

1. Build finishes without errors.
2. docker ps shows frontend and backend containers running.
3. Frontend page loads at port 3000.
4. API endpoints return valid JSON responses.

### Evidence to capture

1. docker compose build output.
2. docker compose up -d output.
3. docker ps output.
4. Browser and API response screenshots.

## Artifact 2: Terraform Testing

### Tool

1. Terraform
2. AWS provider for Terraform

### General purpose of the tool

1. Provision cloud infrastructure from code.
2. Keep infrastructure reproducible and version controlled.
3. Manage lifecycle (create, update, destroy).

### Purpose in this project

1. Provision AWS EC2 + VPC networking stack.
2. Configure secure SSH access and app ports.

### Commands

Run from Terraform folder:

```powershell
cd online_catalog/infra/terraform
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
terraform output
```

Collaboration safety checks before apply:

```powershell
aws sts get-caller-identity
terraform state pull
```

Expected:

1. Account ID is 186072212411.
2. State pull succeeds from shared backend.

### What this tests

1. Terraform config syntax and provider setup are valid.
2. Resources can be created in AWS from code.
3. Outputs expose required connection details.
4. Shared backend and lock behavior are functioning for collaboration.

### Expected results

1. terraform validate returns success.
2. terraform apply completes without failed resources.
3. terraform output shows:
   1. ec2_public_ip
   2. ec2_public_dns
   3. vpc_id
   4. public_subnet_id
   5. security_group_id
4. AWS Console shows running EC2 and created networking resources.

### Evidence to capture

1. terraform validate success.
2. terraform plan summary.
3. terraform apply success.
4. terraform output values.
5. AWS Console screenshots for EC2, VPC, Subnet, Security Group.

## Artifact 3: Ansible Testing

### Tool

1. Ansible
2. SSH
3. kind and kubectl

### General purpose of the tool

1. Automate server configuration and setup.
2. Make server setup repeatable and idempotent.
3. Avoid manual, error-prone shell setup.

### Purpose in this project

1. Configure Terraform-provisioned EC2 automatically.
2. Install Docker and Kubernetes tooling.
3. Initialize/recreate a local single-node Kubernetes cluster with host port mappings.
4. Pull project repository and bootstrap missing `.env` files from `.env.example`.

### Required files

1. infra/ansible/ansible.cfg
2. infra/ansible/inventory.ini
3. infra/ansible/playbooks/site.yml

### Commands

From WSL:

```bash
cd /mnt/d/university/SEMESTER\ 8/cloud\ computing/project3/online_catalog/infra/ansible
ansible -i inventory.ini ec2 -m ping
ansible-playbook -i inventory.ini playbooks/site.yml
```

If collaborator updated infrastructure before demo, refresh target IP first:

```bash
cd /mnt/d/university/SEMESTER\ 8/cloud\ computing/project3/online_catalog/infra/terraform
terraform output
```

Then update infra/ansible/inventory.ini with the latest ec2_public_ip.

Post-run verification on EC2:

```bash
ssh -i ~/.ssh/online-catalog-key.pem ec2-user@<EC2_PUBLIC_IP>
docker --version
kind get clusters
KUBECONFIG=/home/ec2-user/.kube/config kubectl get nodes -o wide
```

### What this tests

1. SSH connectivity and Ansible host targeting.
2. Automated package and runtime setup on EC2.
3. Local cluster initialization succeeds.
4. Node reaches Ready state.

### Expected results

1. ansible ping returns pong.
2. playbook completes without failed tasks.
3. kind get clusters shows online-catalog.
4. kubectl get nodes shows control-plane node in Ready status.

## Artifact 4: Kubernetes Testing

### Tool

1. Docker Hub
2. Kubernetes manifests (Deployment/Service)
3. kubectl + kind

### General purpose of the tool

1. Run microservices as declarative workloads.
2. Expose workloads through Kubernetes Services.
3. Keep deployment reproducible from versioned YAML.

### Purpose in this project

1. Deploy the active four-service stack (frontend, catalog-management, customer-support, order-processing) to the EC2 kind cluster.
2. Use Docker Hub images built from project Dockerfiles.
3. Validate browser/API access through NodePort.

### Commands

Build and push images from local machine:

```powershell
cd online_catalog
docker login
.\scripts\push-images.ps1 -Tag latest
```

On EC2, ensure old compose stack is down:

```bash
cd /home/ec2-user/online_catalogue_microservice/online_catalog
docker compose down
```

Apply manifests:

```bash
export KUBECONFIG=/home/ec2-user/.kube/config
cd /home/ec2-user/online_catalogue_microservice/online_catalog
kubectl apply -k kubernetes
```

Rollout checks:

```bash
kubectl get pods -n online-catalog
kubectl get svc -n online-catalog
kubectl rollout status deployment/catalog-management -n online-catalog
kubectl rollout status deployment/customer-support -n online-catalog
kubectl rollout status deployment/order-processing -n online-catalog
kubectl rollout status deployment/frontend -n online-catalog
```

NodePort endpoint checks:

1. http://<EC2_PUBLIC_IP>:3000
2. http://<EC2_PUBLIC_IP>:30081/products
3. http://<EC2_PUBLIC_IP>:30082/customers
4. http://<EC2_PUBLIC_IP>:30083/orders

### What this tests

1. Docker Hub images are pullable by the cluster.
2. Deployment manifests schedule pods successfully.
3. Service wiring between frontend and backend works.
4. External NodePort access from browser/API clients works.

### Expected results

1. All 4 deployments show Ready replicas.
2. `kubectl get svc -n online-catalog` lists NodePort services.
3. Frontend page loads at `<EC2_PUBLIC_IP>:3000`.
4. Products, customers, and orders API routes return JSON.

### Evidence to capture

1. Docker Hub push output from `push-images.ps1`.
2. `kubectl get pods -n online-catalog` output.
3. `kubectl get svc -n online-catalog` output with NodePorts.
4. Browser screenshots for frontend and API endpoints.

## Artifact 5: CI/CD Testing (GitHub Actions + Argo CD)

### Tool

1. GitHub Actions
2. Docker Hub
3. Argo CD

### General purpose of the tool

1. Build and publish images automatically from source changes.
2. Keep deployment manifests aligned with image versions.
3. Continuously sync cluster state from Git.

### Purpose in this project

1. Build/push all 4 service images after backend/frontend code changes.
2. Automatically update Kubernetes image tags in repo manifests.
3. Automatically deploy updated manifests to kind cluster using Argo CD.

### One-time setup

In GitHub repository settings, add:

1. `DOCKERHUB_TOKEN` secret
2. Workflow Docker Hub namespace is fixed to `ayaankhan17`
3. Actions workflow permission set to read and write repository contents

### Commands

Install/setup Argo CD through Ansible:

```bash
cd /mnt/d/university/SEMESTER\ 8/cloud\ computing/project3/online_catalog/infra/ansible
ansible-playbook -i inventory.ini playbooks/site.yml
```

Trigger CI by pushing a backend/frontend change:

```bash
git add .
git commit -m "test: trigger ci pipeline"
git push origin master
```

Verify Argo CD sync status on EC2:

```bash
export KUBECONFIG=/home/ec2-user/.kube/config
kubectl get application -n argocd
kubectl describe application online-catalog -n argocd
kubectl get pods -n online-catalog
```

Get Argo CD admin password (first login):

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

Argo CD UI URL:

1. `https://<EC2_PUBLIC_IP>:30443`

### What this tests

1. CI pipeline triggers correctly on code push.
2. Docker images are published successfully.
3. Kubernetes manifests are updated with new image tags.
4. Argo CD detects Git changes and auto-syncs deployments.

### Expected results

1. GitHub Actions workflow passes both jobs.
2. New `sha-*` image tags are visible in Docker Hub.
3. Kubernetes manifest files in repo show updated image tags.
4. Argo CD Application shows `Synced` and `Healthy`.

### Evidence to capture

1. GitHub Actions run summary (success).
2. Commit containing updated manifest image tags.
3. `kubectl get application -n argocd` output.
4. Argo CD UI screenshot showing synced application.

## Safe Stop and Cost Cleanup

Use this section after demo to avoid charges.

### Step 1: Stop local Docker containers

Run from project root:

```powershell
cd online_catalog
docker compose down
```

What this does:

1. Stops and removes local project containers.
2. Prevents unnecessary local resource usage.

### Step 2: Remove kind cluster on EC2 (optional but recommended)

From local machine:

```bash
ssh -i ~/.ssh/online-catalog-key.pem ec2-user@<EC2_PUBLIC_IP> "kind delete cluster --name online-catalog"
```

What this does:

1. Removes local Kubernetes cluster resources on EC2.
2. Frees memory and disk on the instance.

### Step 3: Destroy AWS infrastructure (main cost saver)

Run from Terraform folder:

```powershell
cd online_catalog/infra/terraform
terraform destroy
```

What this does:

1. Deletes Terraform-managed AWS resources.
2. Stops EC2 billing from this stack.

### Step 4: Verify no paid resources remain

Check in AWS Console:

1. EC2 Instances: no running instances from this project.
2. EBS Volumes: no leftover unattached project volumes.
3. Elastic IPs: no allocated but unassociated addresses.
4. VPC resources from this project are removed.

## Quick Demo Script

1. Show docker compose build and running services.
2. Show Terraform apply and output values.
3. Show Ansible ping and playbook run.
4. Show Kubernetes apply output and rollout success.
5. Push one backend/frontend change and show successful GitHub Actions run.
6. Show Argo CD application auto-sync to latest manifest commit.
7. Open frontend and API NodePort URLs from browser.
8. Show cleanup command terraform destroy at the end.

## Collaboration Validation (Run Before Final Demo Day)

Use this once to prove both teammates are correctly configured.

1. Identity check (both users):

```bash
aws sts get-caller-identity
```

Pass criteria:

1. Both users show account 186072212411.
2. Both users are IAM users (not root).

2. Terraform backend check (both users):

```bash
cd infra/terraform
terraform init
terraform plan
```

Pass criteria:

1. Both users can initialize backend.
2. Both users can read the same shared state.

3. Locking check (controlled test):

1. User A starts a terraform apply.
2. User B runs terraform plan while apply is in progress.

Pass criteria:

1. User B waits or receives lock-related message.
2. No concurrent state write occurs.


This sequence demonstrates implementation, validation, and responsible cost control.
