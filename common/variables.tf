variable "env" {
  description = "Environment Name"
  type = "string"
  default = "dev"
}

variable "region" {
  description = "Region Name"
  type = "string"
  default = "us-east-1"
}

variable "app" {
  description = "Application Name"
  type = "string"
  default = "pytapp"
}

variable "vpc_cidr" {
  description = "VPC CIDR value"
  type = "string"
  default = "10.0.0.0/24"
}

variable "pub_subnet_1" {
  description = "Public subnet 1 CIDR value"
  type = "string"
  default = "10.0.1.0/24"
}

variable "pub_subnet_2" {
  description = "Public subnet 2 CIDR value"
  type = "string"
  default = "10.0.2.0/24"
}

variable "pub_subnet_3" {
  description = "Public subnet 3 CIDR value"
  type = "string"
  default = "10.0.3.0/24"
}

variable "priv_subnet_1" {
  description = "Private subnet 1 CIDR value"
  type = "string"
  default = "10.0.4.0/24"
}

variable "priv_subnet_2" {
  description = "Private subnet 2 CIDR value"
  type = "string"
  default = "10.0.5.0/24"
}

variable "priv_subnet_3" {
  description = "Private subnet 3 CIDR value"
  type = "string"
  default = "10.0.6.0/24"
}

variable "bastion_ami" {
  description = "AMI ID for Bastion Instance"
  type    = "string"
  default = "ami-0b69ea66ff7391e80"
}

variable "bastion_size" {
  description = "Bastion Instance Type"
  type    = "string"
  default = "t2.small"
}

variable "KeyPair" {
  description = "Node Instance Key Pair"
  type    = "string"
  default = "poc"
}
