<div align="center">

# 🏗️ AWS Tools Terraform Stack

[![Terraform](https://img.shields.io/badge/Terraform-≥1.x-7B42BC?logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform)
[![AWS](https://img.shields.io/badge/AWS-us--west--2-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com)
[![Docker](https://img.shields.io/badge/Docker-shaahin1359%2Faws--tools--app-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/shaahin1359/aws-tools-app)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)

Production-ready, auto-scaling AWS infrastructure for the **aws-tools-app** — provisioned entirely with Terraform.

</div>

---

## 🗺️ Architecture

```
                        ┌─────────────────────────────────────────────┐
                        │                   AWS VPC                    │
                        │            192.168.0.0/26                    │
                        │                                              │
          Internet      │  ┌──────────────────────────────────────┐   │
             │          │  │           PUBLIC SUBNETS              │   │
             ▼          │  │  us-west-2a (.0/28)  us-west-2b (.16/28) │
    ┌─────────────────┐ │  │                                      │   │
    │  🌐 Internet    │ │  │  ┌──────────────────────────────┐    │   │
    │    Gateway      │─┼──┼─▶│   ⚖️  Application Load       │    │   │
    └─────────────────┘ │  │  │      Balancer (HTTP:80)      │    │   │
                        │  │  └──────────────┬───────────────┘    │   │
                        │  │                 │                     │   │
                        │  │  ┌──────────────▼───────────────┐    │   │
                        │  │  │  🖥️  Auto Scaling Group       │    │   │
                        │  │  │  EC2 t3.small (min:1 max:4)  │    │   │
                        │  │  │  Amazon Linux 2023 + Docker  │    │   │
                        │  │  │  🐳 aws-tools-app:v1.0.5     │    │   │
                        │  │  └──────────────────────────────┘    │   │
                        │  │                                      │   │
                        │  │  ┌──────────────────────────────┐    │   │
                        │  │  │  🔑 Bastion Host (t3.micro)  │    │   │
                        │  │  │  SSH restricted to deployer  │    │   │
                        │  │  └──────────────────────────────┘    │   │
                        │  └──────────────────────────────────────┘   │
                        │                                              │
                        │  ┌──────────────────────────────────────┐   │
                        │  │           PRIVATE SUBNETS             │   │
                        │  │  us-west-2a (.32/28) us-west-2b (.48/28) │
                        │  │                                      │   │
                        │  │  ┌──────────────────────────────┐    │   │
                        │  │  │  🗄️  RDS PostgreSQL 15        │    │   │
                        │  │  │  db.t3.micro · 20GB gp2      │    │   │
                        │  │  │  Encrypted · 7-day backups   │    │   │
                        │  │  └──────────────────────────────┘    │   │
                        │  └──────────────────────────────────────┘   │
                        └─────────────────────────────────────────────┘
```

---

## 🔒 Security Groups

```
┌─────────────────────────────────────────────────────────────┐
│                     Security Group Flow                      │
│                                                             │
│  🌍 0.0.0.0/0 ──▶ [ALB SG] :80 ──▶ [App SG] :80           │
│                                                             │
│  🧑 Deployer IP ──────────────▶ [App SG] :22 (SSH)         │
│                                                             │
│  [App SG] ─────────────────────▶ [RDS SG] :5432            │
│           (via VPC CIDR 192.168.0.0/26)                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Resources Provisioned

| Icon | Resource | Details |
|------|----------|---------|
| 🌐 | **VPC** | `192.168.0.0/26`, DNS hostnames enabled |
| 🔀 | **Public Subnets** | `/28` each in `us-west-2a` and `us-west-2b` |
| 🔒 | **Private Subnets** | `/28` each in `us-west-2a` and `us-west-2b` |
| 🚪 | **Internet Gateway** | Routes public traffic |
| ⚖️ | **ALB** | Internet-facing, HTTP:80, sticky sessions (1-day cookie) |
| 📋 | **Launch Template** | Amazon Linux 2023, t3.small, Docker app on port 80 |
| 📈 | **Auto Scaling Group** | Min 1 / Max 4, CPU target tracking at 60% |
| 🔑 | **Bastion Host** | t3.micro, public IP, SSH locked to deployer IP |
| 🗄️ | **RDS PostgreSQL 15** | db.t3.micro, 20 GB gp2, encrypted, 7-day backups |
| 🛡️ | **Security Groups** | ALB, App, and RDS with least-privilege rules |

---

## ✅ Prerequisites

- ![Terraform](https://img.shields.io/badge/-Terraform_≥_1.x-7B42BC?logo=terraform&logoColor=white&style=flat-square) installed
- ![AWS CLI](https://img.shields.io/badge/-AWS_CLI-FF9900?logo=amazonaws&logoColor=white&style=flat-square) configured (`aws configure` or env vars)
- An EC2 **key pair** created in `us-west-2`
- Docker image `shaahin1359/aws-tools-app:v1.0.5` on DockerHub

---

## 🚀 Usage

### 1. Clone

```bash
git clone <repo-url>
cd aws-tools-terraform-stack
```

### 2. Create `terraform.tfvars`

> ⚠️ This file is **git-ignored**. Never commit secrets.

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

### 4. Access the App

```
http://<alb_dns>
```

### 5. Destroy

```bash
terraform destroy
```

---

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `alb_dns` | Public DNS of the Application Load Balancer |
| `vpc_id` | VPC ID |
| `rds_endpoint` | RDS instance endpoint |
| `asg_name` | Auto Scaling Group name |
| `launch_template_id` | Launch Template ID |
| `rds_connection_string` | Full PostgreSQL connection string *(sensitive)* |

---

## ⚙️ Variables Reference

| Variable | Default | Required | Description |
|----------|---------|----------|-------------|
| `region` | `us-west-2` | | AWS region |
| `vpc_cidr` | `192.168.0.0/26` | | VPC CIDR block |
| `instance_type` | `t3.micro` | | Bastion host instance type |
| `key_pair` | — | ✅ | EC2 key pair name |
| `db_identifier` | `orders-postgres` | | RDS instance identifier |
| `db_name` | `awstoolsappdb` | | Database name |
| `db_username` | — | ✅ 🔐 | Database master username |
| `db_password` | — | ✅ 🔐 | Database password |
| `db_instance_class` | `db.t3.micro` | | RDS instance class |
| `cpu_target_value` | `60.0` | | ASG target CPU utilization (%) |
| `supabase_url` | — | ✅ 🔐 | Supabase project URL |
| `supabase_amon_key` | — | ✅ 🔐 | Supabase anon key |
| `aws_session_key` | — | ✅ 🔐 | App AWS session key |

> 🔐 = marked `sensitive = true` in Terraform

---

## 📁 Project Structure

```
aws-tools-terraform-stack/
│
├── 🔧 provider.tf           # AWS & HTTP provider config, AMI data sources
├── 📝 var.tf                # Variable declarations
├── 🔒 terraform.tfvars      # Variable values (git-ignored)
│
├── 🌐 vpc.tf                # VPC, subnets, IGW, route tables
├── 🛡️  security_groups.tf   # Security groups for ALB, app, and RDS
├── 🖥️  ec2.tf               # Bastion host
├── ⚖️  alb.tf               # Application Load Balancer, target group, listener
├── 📈 autoscaling.tf        # Launch template, ASG, CPU scaling policy
├── 🗄️  rds.tf               # RDS PostgreSQL instance and subnet group
├── 📤 outputs.tf            # Stack outputs
│
└── 📂 scripts/
    └── 🐚 user_data_capstone.sh  # EC2 bootstrap: installs Docker, writes .env, starts container
```

---

## 🔐 Security Notes

- **SSH access** is automatically restricted to the public IP of the machine running `terraform apply` (resolved via `checkip.amazonaws.com`).
- **RDS** lives in private subnets with no public access — reachable only within the VPC CIDR.
- **Sensitive variables** (`db_password`, `db_username`, `supabase_amon_key`, `aws_session_key`) are marked `sensitive = true`.
- **`*.tfvars`** and **`*.tfstate`** files are git-ignored to prevent secret leakage.

---

## 🛠️ Tech Stack

<div align="center">

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/Amazon_AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Amazon EC2](https://img.shields.io/badge/Amazon_EC2-FF9900?style=for-the-badge&logo=amazonec2&logoColor=white)
![Amazon RDS](https://img.shields.io/badge/Amazon_RDS-527FFF?style=for-the-badge&logo=amazonrds&logoColor=white)

</div>
