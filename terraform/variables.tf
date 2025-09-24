variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (will be retrieved dynamically)"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Name of the AWS Key Pair for SSH access"
  type        = string
  default     = "marinelangrez-forum-keypair"
}

variable "db_password" {
  description = "Password for PostgreSQL database"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.nano"
}

variable "github_token" {
  description = "GitHub Personal Access Token for Container Registry"
  type        = string
  sensitive   = true
}