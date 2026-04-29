# AWS Tools Terraform Stack

Terraform infrastructure for deploying the **aws-tools-app** on AWS. The stack provisions a production-ready, auto-scaling web application environment backed by a managed PostgreSQL database.

## Architecture

```
Internet
   │
   ▼
[ALB] ── public subnets (us-west-2a / us-west-2b)
   │
   ▼
[Auto Scaling Group] ── EC2 t3.small instances (Amazon Linux 2023)
   │                    runs Docker container: shaahin1359/aws-tools-app
   │
   ▼
[RDS PostgreSQL 15] ── private subnets (multi-AZ subnet group)
```

A **bastion host** (t3.micro) in the public subnet provides SSH access for administration.

## Resources Provisioned

| Resource | Details |
|---|---|
| VPC | `192.168.0.0/26`, DNS hostnames enabled |
| Public Subnets | `/28` each in `us-west-2a` and `us-west-2b` |
| Private Subnets | `/28` each in `us-west-2a` and `us-west-2b` |
| Internet Gateway | Routes public traffic |
| ALB | Internet-facing, HTTP:80, sticky sessions |
| Launch Template | Amazon Linux 2023, t3.small, Docker app on port 80 |
| Auto Scaling Group | Min 1 / Max 4, target CPU tracking at 60% |
| Bastion Host | t3.micro, public IP, SSH restricted to deployer IP |
| RDS PostgreSQL | v15, db.t3.micro, 20 GB gp2, encrypted, 7-day backups |
| Security Groups | ALB (0.0.0.0/0:80), App (ALB:80 + SSH from deployer IP), RDS (VPC CIDR:5432) |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.x
- AWS credentials configured (`aws configure` or environment variables)
- An EC2 key pair in the target region
- Docker image `shaahin1359/aws-tools-app:v1.0.5` accessible from DockerHub

## Usage

### 1. Clone the repository

```bash
git clone <repo-url>
cd aws-tools-terraform-stack
```

### 2. Create a `terraform.tfvars` file

> ⚠️ `terraform.tfvars` is git-ignored. Never commit secrets.

```hcl
region        = "us-west-2"
key_pair      = "your-key-pair-name"
db_password   = "YourSecurePassword!"

supabase_url      = "https://<your-project>.supabase.co"
supabase_amon_key = "<your-supabase-anon-key>"
aws_session_key   = "<your-session-key>"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Outputs

After a successful apply:

| Output | Description |
|---|---|
| `alb_dns` | Public DNS of the Application Load Balancer |
| `vpc_id` | VPC ID |
| `rds_endpoint` | RDS instance endpoint |
| `asg_name` | Auto Scaling Group name |
| `launch_template_id` | Launch Template ID |
| `rds_connection_string` | Full PostgreSQL connection string (sensitive) |

Access the app at `http://<alb_dns>`.

### 5. Destroy

```bash
terraform destroy
```

## Variables Reference

| Variable | Default | Description |
|---|---|---|
| `region` | `us-west-2` | AWS region |
| `vpc_cidr` | `192.168.0.0/26` | VPC CIDR block |
| `instance_type` | `t3.micro` | Bastion host instance type |
| `key_pair` | — | **Required.** EC2 key pair name |
| `db_identifier` | `orders-postgres` | RDS instance identifier |
| `db_name` | `awstoolsappdb` | Database name |
| `db_username` | `adminuser` | Database master username |
| `db_password` | — | **Required (sensitive).** Database password |
| `db_instance_class` | `db.t3.micro` | RDS instance class |
| `cpu_target_value` | `60.0` | ASG target CPU utilization (%) |
| `supabase_url` | — | **Required (sensitive).** Supabase project URL |
| `supabase_amon_key` | — | **Required (sensitive).** Supabase anon key |
| `aws_session_key` | — | **Required (sensitive).** App AWS session key |

## Project Structure

```
.
├── provider.tf          # AWS & HTTP provider config, AMI data sources
├── var.tf               # Variable declarations
├── terraform.tfvars     # Variable values (git-ignored)
├── vpc.tf               # VPC, subnets, IGW, route tables
├── security_groups.tf   # Security groups for ALB, app, and RDS
├── ec2.tf               # Bastion host
├── alb.tf               # Application Load Balancer, target group, listener
├── autoscaling.tf       # Launch template, ASG, CPU scaling policy
├── rds.tf               # RDS PostgreSQL instance and subnet group
├── outputs.tf           # Stack outputs
└── scripts/
    └── user_data_capstone.sh  # EC2 bootstrap: installs Docker, writes .env, starts container
```

## Security Notes

- SSH access to EC2 instances is automatically restricted to the public IP of the machine running `terraform apply` (via `checkip.amazonaws.com`).
- RDS is in private subnets with no public access; only reachable within the VPC CIDR.
- Sensitive variables (`db_password`, `supabase_amon_key`, `aws_session_key`) are marked `sensitive = true` in Terraform.
- `*.tfvars` and `*.tfstate` files are git-ignored to prevent secret leakage.
