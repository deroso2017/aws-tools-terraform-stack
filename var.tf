variable "region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_name" {
  type    = string
  default = "aws-tools-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/26"
}

variable "public_subnet_cidr" {
  type    = string
  default = "192.168.0.0/28"
}

variable "public_subnet_2_cidr" {
  type    = string
  default = "192.168.0.16/28"
}

variable "private_subnet_1_cidr" {
  type    = string
  default = "192.168.0.32/28"
}

variable "private_subnet_2_cidr" {
  type    = string
  default = "192.168.0.48/28"
}

variable "az_1" {
  type    = string
  default = "us-west-2a"
}

variable "az_2" {
  type    = string
  default = "us-west-2b"
}

variable "ami_id" {
  type    = string
  default = "ami-0534a0fd33c655746"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_pair" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
}

variable "instance_profile" {
  type    = string
  default = "LabInstanceProfile"
}

variable "db_identifier" {
  type    = string
  default = "orders-postgres"
}

variable "db_name" {
  type    = string
  default = "awstoolsappdb"
}

variable "db_username" {
  type    = string
  default = "adminuser"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "cpu_target_value" {
  description = "Target CPU utilization for autoscaling policy"
  type        = number
  default     = 60.0
}

variable "supabase_url" {
  type      = string
  sensitive = true
}

variable "supabase_amon_key" {
  type      = string
  sensitive = true
}

variable "aws_session_key" {
  type      = string
  sensitive = true
}
