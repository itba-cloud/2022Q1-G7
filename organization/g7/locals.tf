locals {
  region       = "us-east-1"
  organization = "final-cc-test"

  cognito = {
    name                  = "${local.organization}-cognito"
    domain                = "${local.organization}-auth-domain"
    callback_url_endpoint = "/cognito/callback"
    logout_url_endpoint   = "/cognito/logout"
  }
  vpcs = {
    "vpc-1" = {
      cidr = "10.0.0.0/20"

      private_subnets = {
        "subnet-1-private" = {
          cidr = "10.0.1.0/24"
          az   = "us-east-1a"
          tags = {

          }
        },
        "subnet-2-private" = {
          cidr = "10.0.2.0/24"
          az   = "us-east-1b"
          tags = {

          }
        }
      },

      public_subnets = {
        "subnet-1-public" = {
          cidr = "10.0.3.0/24"
          az   = "us-east-1a"
          tags = {

          }
        },
        "subnet-2-public" = {
          cidr = "10.0.4.0/24"
          az   = "us-east-1b"
          tags = {

          }
        }
      },
      network_acl = {
        ingress = {
          "rule-100" = {
            from_port   = 0,
            protocol    = -1,
            rule_number = 100,
            to_port     = 0,
            rule_action = "allow",
            cidr_block  = "0.0.0.0/0"
          },
        },
        egress = {
          "rule-100" = {
            from_port   = 0,
            protocol    = -1,
            rule_number = 100,
            to_port     = 0,
            rule_action = "allow",
            cidr_block  = "0.0.0.0/0"
          }
        },
        tags = {

        }
      }
      enable_dns_hostnames = true
      enable_dns_support   = true
      tags = {

      }
    }
  }

  website = {
    name = "${local.organization}-web.aleph51.com.ar"
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
    },
    official_tags = {

    },
    www_tags = {

    },
    log_tags = {

    },
    tags = {

    }
  }

  services = {
    users-service = {
      name          = "users"
      image         = "users:latest"
      location      = "users"
      replicas      = 3
      containerPort = 80
    },
    courses-service = {
      name          = "courses"
      image         = "courses:latest"
      location      = "courses"
      replicas      = 3
      containerPort = 80
    },
  }

  lambdas = {
    "auth" = {
      path      = "lambda/auth_handler.zip"
      principal = "apigateway"
      handler   = "auth_handler"
      resource  = "auth"
      method    = "ANY"
      env = {
        PRIVATE_KEY = tls_private_key.ssh.private_key_openssh
      }
      #source_arn = aws_api_gateway_stage.this.execution_arn
    },
  }
  authorizer_name = "${local.organization}-api-auth"

  dynambodb = {
    "users" = {
      key = "id"
      attributes = [
        { name = "id", type = "S" },
      ]
      read_capacity  = 1
      write_capacity = 1
    }
    "courses" = {
      key       = "PK"
      range_key = "SK"
      attributes = [
        { name = "PK", type = "S" },
        { name = "SK", type = "S" },
      ]
      read_capacity  = 1
      write_capacity = 1
    }
  }

  ecs = {
    health_check_path = "health-check"
    task_definition_tags = {

    },
    cluster_tags = {

    },
    security_group_tags = {

    },
    tags = {

    },
    alb = {
      tags = {
        security_group_tags = {

        },
        load_balancer_tags = {

        },
        target_group_tags = {

        },
        listener_tags = {

        },
        tags = {

        }
      }
    }

  }

}
