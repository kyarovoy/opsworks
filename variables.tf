variable "nametag" {
  default = "kostiantyn/iarovyi"
  description = "Name tag to apply to each AWS resource"
}

variable "aws_region" {
  default = "eu-west-1"
  description = "AWS Region"
}

variable "aws_vpc_block" {
  default = "10.95.0.0/16"
  description = "AWS VPC Block"
}

variable "aws_subnet" {
  default = "10.95.0.0/24"
  description = "AWS Subnet"
}

variable "swarm_master_count" {
  default = 1
  description = "Amount of Docker Swarm Manager nodes"
}

variable "swarm_worker_count" {
  default = 1
  description = "Amount of Docker Swarm worker nodes"
}

variable "swarm_instance_type" {
  default = "t2.micro"
  description = "AWS Instance Type"
}

variable "swarm_instance_ami" {
  default = "ami-01cca82393e531118"
  description = "AWS Instance AMI"
}

# Defined in terraform.tfvars (should not be normally commited to github)
variable "aws_access_key" {}
variable "aws_secret_key" {}
