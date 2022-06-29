locals {
  region       = "us-east-1"
  organization = "itba-cloud-g7"
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
            from_port   = 80,
            protocol    = "tcp",
            rule_number = 100,
            to_port     = 80,
            rule_action = "allow",
            cidr_block  = "10.0.1.0/24"
          },
          "rule-101" = {
            from_port   = 80,
            protocol    = "tcp",
            rule_number = 101,
            to_port     = 80,
            rule_action = "allow",
            cidr_block  = "10.0.2.0/24"
          },
          "rule-102" = {
            from_port   = 80,
            protocol    = "tcp",
            rule_number = 102,
            to_port     = 80,
            rule_action = "allow",
            cidr_block  = "10.0.3.0/24"
          },
          "rule-103" = {
            from_port   = 80,
            protocol    = "tcp",
            rule_number = 103,
            to_port     = 80,
            rule_action = "allow",
            cidr_block  = "10.0.4.0/24"
          },
          "rule-200" = {
            from_port   = 443,
            protocol    = "tcp",
            rule_number = 200,
            to_port     = 443,
            rule_action = "allow",
            cidr_block  = "10.0.1.0/24"
          },
          "rule-201" = {
            from_port   = 443,
            protocol    = "tcp",
            rule_number = 201,
            to_port     = 443,
            rule_action = "allow",
            cidr_block  = "10.0.2.0/24"
          }
          "rule-202" = {
            from_port   = 443,
            protocol    = "tcp",
            rule_number = 202,
            to_port     = 443,
            rule_action = "allow",
            cidr_block  = "10.0.3.0/24"
          },
          "rule-203" = {
            from_port   = 443,
            protocol    = "tcp",
            rule_number = 203,
            to_port     = 443,
            rule_action = "allow",
            cidr_block  = "10.0.4.0/24"
          }
        },
        egress = {
          "rule-100" = {
            from_port   = 0,
            protocol    = -1,
            rule_number = 100,
            to_port     = 0,
            rule_action = "allow",
            cidr_block  = "10.0.1.0/24"
          }
          "rule-101" = {
            from_port   = 0,
            protocol    = -1,
            rule_number = 101,
            to_port     = 0,
            rule_action = "allow",
            cidr_block  = "10.0.2.0/24"
          }
          "rule-102" = {
            from_port   = 0,
            protocol    = -1,
            rule_number = 102,
            to_port     = 0,
            rule_action = "allow",
            cidr_block  = "10.0.3.0/24"
          }
          "rule-103" = {
            from_port   = 0,
            protocol    = -1,
            rule_number = 104,
            to_port     = 0,
            rule_action = "allow",
            cidr_block  = "10.0.4.0/24"
          }
        },
        tags = {

        }
      }
      tags = {

      }
    }
  }

  website = {
    name = "${local.organization}-web"
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

  apigateway = {
    name = "${local.organization}-apigateway"

    resources = {
      "courses" = {
        "GET" = {
          type = "AWS_PROXY"
          uri  = aws_lambda_function.this["getCourses"].invoke_arn
        },
        "POST" = {
          type = "AWS_PROXY"
          uri  = aws_lambda_function.this["createCourses"].invoke_arn
        },
      },
      "profiles" = {
        "GET" = {
          type = "AWS_PROXY"
          uri  = aws_lambda_function.this["getProfiles"].invoke_arn
        },
        "POST" = {
          type = "AWS_PROXY"
          uri  = aws_lambda_function.this["createProfiles"].invoke_arn
        },
      },
      "threads" = {
        "GET" = {
          type = "AWS_PROXY"
          uri  = aws_lambda_function.this["getThreads"].invoke_arn
        },
        "POST" = {
          type = "AWS_PROXY"
          uri  = aws_lambda_function.this["createThreads"].invoke_arn
        },
      },
    }

    logging_levels = ["INFO", "ERROR"]
  }

  lambdas = {
    "getCourses" = {
      path      = "lambda/lambda_get_courses.py.zip"
      principal = "apigateway"
      handler   = "lambda_get_courses"
      resource  = "courses"
      method    = "GET"
      #source_arn = aws_api_gateway_stage.this.execution_arn
    },
    "createCourses" = {
      path      = "lambda/lambda_post_courses.py.zip"
      principal = "apigateway"
      handler   = "lambda_post_courses"
      resource  = "courses"
      method    = "POST"
      #source_arn = aws_api_gateway_stage.this.execution_arn
    },
    "getProfiles" = {
      path      = "lambda/lambda_get_profiles.py.zip"
      principal = "apigateway"
      handler   = "lambda_get_profiles"
      resource  = "profiles"
      method    = "GET"
      #source_arn = aws_api_gateway_stage.this.execution_arn
    },
    "createProfiles" = {
      path      = "lambda/lambda_post_profiles.py.zip"
      principal = "apigateway"
      handler   = "lambda_post_profiles"
      resource  = "profiles"
      method    = "POST"
      #source_arn = aws_api_gateway_stage.this.execution_arn
    },
    "getThreads" = {
      path      = "lambda/lambda_get_threads.py.zip"
      principal = "apigateway"
      handler   = "lambda_get_threads"
      resource  = "threads"
      method    = "GET"
      #source_arn = aws_api_gateway_stage.this.execution_arn
    },
    "createThreads" = {
      path      = "lambda/lambda_post_threads.py.zip"
      principal = "apigateway"
      handler   = "lambda_post_threads"
      resource  = "threads"
      method    = "POST"
      #source_arn = aws_api_gateway_stage.this.execution_arn
    }
  }

  dynambodb = {
    "users" = {
      key = "id"
      attributes = [
        { name = "id", type = "S" },
        { name = "name", type = "S" },
      ]
      read_capacity  = 1
      write_capacity = 1
    }
    "courses" = {
      key = "id"
      attributes = [
        { name = "id", type = "S" },
        { name = "name", type = "S" },
      ]
      read_capacity  = 1
      write_capacity = 1
    }
    "recordings" = {
      key = "id"
      attributes = [
        { name = "id", type = "S" },
        { name = "name", type = "S" },
      ]
      read_capacity  = 1
      write_capacity = 1



      ecs = {
        cluster_tags = {

        },
        security_group_tags = {

        },
        task_definition_tags = {

        },
        tags = {


        }
    } }
  }

  ecs = {
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
