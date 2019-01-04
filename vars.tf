variable "region" {
  default = "us-east-2"
  }

variable "aws_instance_type" {
  default = "t2.micro"
  }

variable "amis" {
  type = "map"
   default = {
#Ubuntu    "us-east-1" = "ami-b374d5a5"
#Ubuntu    "us-east-2" = "ami-5e8bb23b"
#Ubuntu    "us-west-2" = "ami-4b32be2b"
    "us-east-1" = "ami-9887c6e7"
    "us-east-2" = "ami-9c0638f9"
    "us-west-1" = "ami-4826c22b"
    "us-west-2" = "ami-3ecc8f46"
  } 
}

variable "vpc_id" {
  description = "ID of VPC"
  default = ""
  }

variable "pri_net_id" {
  description = "Private Network ID"
  default = ""
  }

variable "pub_subnet_id" {
  description = "Public Subnet ID"
  default = ""
  }

variable "secgrp_frntnd_id" {
  description = "Security Group FrontEnd ID"
  default = ""
}

variable "RDSPWD" {
  default = "Password"
  }

variable "vpc-cidr" {
  default = "172.128.0.0/16"
  }

variable "vpcsubn-pub-cidr" {
  default = "172.128.0.0/24"
  }

variable "vpcsubn-pri-cidr" {
  default = "172.128.3.0/24"
  }

variable "DnsZoneName" {
  default = "NET.int"
  description = "the internal dns name"
  }

variable "environment" {
  default = "TFP"
  }

