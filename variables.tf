variable "nametag" {
  default = "kostiantyn/iarovyi"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_vpc_block" {
  default = "10.95.0.0/16"
}

variable "aws_subnet" {
  default = "10.95.0.0/24"
}

variable "swarm_master_count" {
  default = 1
}

variable "swarm_worker_count" {
  default = 1
}

variable "swarm_instance_type" {
  default = "t2.micro"
}

variable "swarm_instance_ami" {
  default = "ami-01cca82393e531118"
}

# Defined in terraform.tfvars (should not be normally commited to github)
variable "aws_access_key" {}
variable "aws_secret_key" {}
