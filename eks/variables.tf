variable "env" {
  description = "Environment Name"
  type = "string"
  default = "dev"
}

variable "vpcenv" {
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
  default = "10.0.0.0/16"
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

variable "NodeAMI" {
  description = "AMI ID for Node Instance"
  type    = "string"
  default = "ami-08198f90fe8bc57f0"
}

variable "NodeInstanceType" {
  description = "Node Instance Type"
  type    = "string"
  default = "t2.medium"
}

variable "KeyPair" {
  description = "Node Instance Key Pair"
  type    = "string"
  default = "poc"
}

