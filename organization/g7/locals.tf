locals {
  vpcs = {
    "vpc-1" = {
      cidr = "10.0.0.0/22"

      subnets = {
        "subnet-1" ={
          cidr = "10.0.1.0/24"
          az   = "us-east-1a"
        },
        "subnet-2" = {
          cidr = "10.0.2.0/24"
          az   = "us-east-1b"
        },

      }
      tags = {
        Name = "vpc-1"
      }
    }
  }
}
