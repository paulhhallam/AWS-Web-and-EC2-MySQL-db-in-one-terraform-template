<<<<<<< HEAD
variable "region" {
# NV
  default = "us-east-1"
# Ohia
#  default = "us-east-2"
  }

variable "aws_instance_type" {
  default = "t2.micro"
  }

variable "amis" {
  type = "map"
   default = {
#     "us-east-1" = "ami-b374d5a5"
# Ubuntu
    "us-east-1" = "ami-0ac019f4fcb7cb7e6"	
	"us-east-2" = "ami-5e8bb23b"
    "us-west-2" = "ami-4b32be2b"
  } 
}
#CENTOS
#variable "amis" {
#  type = "map"
#   default = {
#    "us-east-1" = "ami-4bf3d731"
#	 "us-east-2" = "ami-e1496384"
#    "us-west-2" = "ami-a042f4d8"
#  } 
#}
# https://wiki.centos.org/Cloud/AWS#head-cc841c2a7d874025ae24d427776e05c7447024b2
#
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

=======
variable "region" {
# NV
  default = "us-east-1"
# Ohio
#  default = "us-east-2"
  }

variable "aws_instance_type" {
  default = "t2.micro"
  }

variable "amis" {
  type = "map"
   default = {
#     "us-east-1" = "ami-b374d5a5"
# Ubuntu
    "us-east-1" = "ami-0ac019f4fcb7cb7e6"	
	"us-east-2" = "ami-5e8bb23b"
    "us-west-2" = "ami-4b32be2b"
  } 
}
#CENTOS
#variable "amis" {
#  type = "map"
#   default = {
#    "us-east-1" = "ami-4bf3d731"
#	 "us-east-2" = "ami-e1496384"
#    "us-west-2" = "ami-a042f4d8"
#  } 
#}
# https://wiki.centos.org/Cloud/AWS#head-cc841c2a7d874025ae24d427776e05c7447024b2
#
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

>>>>>>> 4cf8f1bff5475f49f8c4e53b611239fd946e1617
