locals {
  region       = "us-east-1"
  organization = "itba-cloud-g7"
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

  # website = {
  #   name = "${local.organization}-web"
  #   objects = {
  #     index = {
  #       filename     = "html/index.html"
  #       content_type = "text/html"
  #     }
  #     error = {
  #       filename     = "html/error.html"
  #       content_type = "text/html"
  #     }
  #     image1 = {
  #       filename     = "images/image1.png"
  #       content_type = "image/png"
  #     }
  #     image2 = {
  #       filename     = "images/image2.jpg"
  #       content_type = "image/jpeg"
  #     }
  #   }

  # }

  # apigateway = {
  #   name = "${local.organization}-apigateway"

  #   resources = {
  #     "courses" = {
  #       "GET" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["getCourses"].invoke_arn
  #       },
  #       "POST" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["createCourses"].invoke_arn
  #       },
  #     },
  #     "profiles" = {
  #       "GET" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["getProfiles"].invoke_arn
  #       },
  #       "POST" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["createProfiles"].invoke_arn
  #       },
  #     },
  #     "threads" = {
  #       "GET" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["getThreads"].invoke_arn
  #       },
  #       "POST" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["createThreads"].invoke_arn
  #       },
  #     },
  #     "courses_by_id" = {
  #       "GET" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["getCoursesById"].invoke_arn
  #         request_parameters = {
  #            "method.request.path.courseId" = true
  #         }
  #       },
  #       "POST" = {
  #         type = "AWS_PROXY"
  #         uri  = module.lambda["createCoursesById"].invoke_arn
  #         request_parameters = {
  #            "method.request.path.courseId" = true
  #         }
  #       },
  #     },
  #   }

  # }

  # lambdas = {
  #   "getCourses" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "createCourses" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "getProfiles" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "createProfiles" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "getThreads" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "createThreads" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "getCoursesById" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  #   "createCoursesById" = {
  #     path      = "lambda/lambda.zip"
  #     principal = "apigateway"
  #   },
  # }
}

