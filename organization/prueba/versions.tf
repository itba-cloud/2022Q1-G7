terraform {
  required_version = ">= 1.0.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.10.0"
    }

    #reference: https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
    #reference: https://medium.com/devops-engineer-documentation/terraform-deploying-a-docker-image-to-an-aws-ecs-cluster-3931337e82fb
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}
