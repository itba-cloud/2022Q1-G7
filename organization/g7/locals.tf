locals {
  vpcs = {
    "vpc-1" = {
      cidr = "10.0.0.0/22"

      subnets = {
        "subnet-1" = {
          cidr = "10.0.1.0/24"
          az   = "us-east-1a"
        },
        "subnet-2" = {
          cidr = "10.0.2.0/24"
          az   = "us-east-1b"
        },

      }
      tags = {

      }
    }
  }

  website = {
    name = "itba-cloud-g7"
    objects = {
      index = {
        filename     = "html/index.html"
        content_type = "text/html"
      }
      error = {
        filename     = "html/error.html"
        content_type = "text/html"
      }
      image1 = {
        filename     = "images/image1.png"
        content_type = "image/png"
      }
      image2 = {
        filename     = "images/image2.jpg"
        content_type = "image/jpeg"
      }
    }

  }

}

