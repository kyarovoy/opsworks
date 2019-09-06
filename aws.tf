provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# Create AWS VPC
resource "aws_vpc" "main" {
  cidr_block           = var.aws_vpc_block
  enable_dns_hostnames = true
  tags                 = { "Name" = var.nametag }
}

# Create AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { "Name" = var.nametag }
}

# Create AWS Routing table
resource "aws_route_table" "internet_access" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = { "Name" = var.nametag }
}

# Create AWS Subnet
resource "aws_subnet" "swarm_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.aws_subnet}"
  map_public_ip_on_launch = true
  tags   = { "Name" = var.nametag }
}

# Associate routing table with subnet
resource "aws_route_table_association" "eu-west-1-private" {
  subnet_id = "${aws_subnet.swarm_subnet.id}"
  route_table_id = "${aws_route_table.internet_access.id}"
}

# Create AWS Security Group
resource "aws_security_group" "swarm" {
  name   = "swarm"
  vpc_id = aws_vpc.main.id
  tags   = { "Name" = var.nametag }

  # Allow incoming SSH connections
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming HTTP connections
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming HTTPS connections
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming Docker Swarm connections between cluster nodes (to be able to join worker to a Swarm)
  ingress {
    from_port = 2377
    to_port   = 2377
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 7946
    to_port   = 7946
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 7946
    to_port   = 7946
    protocol  = "udp"
    self      = true
  }

  ingress {
    from_port = 4789
    to_port   = 4789
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 4789
    to_port   = 4789
    protocol  = "udp"
    self      = true
  }

  # Allow incoming connections between cluster nodes to exposed Docker Engine port on manager node
  ingress {
    from_port = 4243
    to_port = 4243
    protocol = "tcp"
    self = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Dynamically generate SSH keys
resource "tls_private_key" "opsworks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "kostiantyn_iarovyi_deploy"
  public_key = "${tls_private_key.opsworks.public_key_openssh}"

  # Save private key to a local directory on 'apply'
  provisioner "local-exec" {
    command = "mkdir -p ./keys; echo \"${tls_private_key.opsworks.private_key_pem}\" > ./keys/opsworks_id_rsa; chmod 400 ./keys/opsworks_id_rsa"
  }

  # Delete private keys from local directory on 'destroy'
  provisioner "local-exec" {
    when = "destroy"
    command = "rm -fR ./keys"
  }

}