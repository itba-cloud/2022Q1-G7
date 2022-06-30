terraform {
  required_version = ">= 1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}