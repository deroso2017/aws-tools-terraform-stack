# AWS Tools Terraform Stack

## Overview
This repository contains Terraform configurations to deploy a robust and secure AWS infrastructure stack. It incorporates critical components such as Application Load Balancer (ALB), Auto Scaling groups, Amazon RDS, Virtual Private Cloud (VPC), and security groups. The goal is to provide a standardized way to set up and manage AWS resources using Terraform.

## Architecture
The architecture of the deployed infrastructure consists of:
- **VPC**: A logically isolated section of the AWS cloud where resources are launched.
- **Subnets**: Public and private subnets designed for hosting EC2 instances and RDS databases.
- **Application Load Balancer (ALB)**: Distributes incoming application traffic across multiple targets, such as EC2 instances.
- **Auto Scaling Group**: Automatically adjusts the number of EC2 instances in response to demand.
- **Amazon RDS**: A managed relational database service that handles routine database tasks.

## Prerequisites
Before deploying the stack, ensure you have the following prerequisites:
- An AWS account.
- Terraform installed on your local machine. (Version 1.0 or above)
- AWS CLI installed and configured with your credentials.

## Quick Start Guide
1. Clone the repository:
   ```bash
   git clone https://github.com/deroso2017/aws-tools-terraform-stack.git
   cd aws-tools-terraform-stack
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the configurations (optional):
   ```bash
   terraform plan
   ```
4. Deploy the stack:
   ```bash
   terraform apply
   ```
5. Confirm the apply action when prompted.

## Configuration
The following configuration files are critical:
- **`variables.tf`**: Defines the input variables used in the Terraform setup.
- **`outputs.tf`**: Specifies the outputs of the stack that will help in understanding the created resources.
- **`main.tf`**: Contains the primary configurations and resource definitions for the infrastructure.

## File Structure
```
aws-tools-terraform-stack/
├── main.tf          # Main configuration file
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── README.md        # Documentation
└── .gitignore       # Git ignore file
``` 

## Deployment Steps
1. Ensure you have completed the Prerequisites.
2. Modify any variable values in `variables.tf` as necessary for your use case.
3. Run `terraform init` to initialize the Terraform configuration.
4. Execute `terraform plan` to preview changes Terraform will make.
5. Deploy your infrastructure with `terraform apply`.
6. Monitor the deployment process and check the outputs for any necessary information.

## Outputs
After a successful deployment, the following outputs are available:
- ALB DNS Name
- RDS Endpoint
- VPC ID
- Security Group IDs

These outputs provide essential information for connecting to your AWS resources.

## Cleanup
To destroy all the resources created by this Terraform stack, run:
```bash
tf destroy
```
Confirm the action to remove all resources from your AWS account.

## Troubleshooting
- If you encounter any issues, check the Terraform logs for errors.
- Ensure your AWS account has the necessary permissions to create the specified resources.
- Validate that there are no existing resources with conflicting configurations.

## Contributing Guidelines
Contributions are welcome! If you would like to contribute to this repository, please fork the repo and create a pull request with the proposed changes. Ensure that your changes are well-documented and tested.

---
This README provides guidelines for deploying AWS infrastructure using Terraform, facilitating ease of use and understanding for users and contributors alike.