module "vpc" {
  for_each = local.vpcs

  providers = {
    aws = aws.aws
  }

  source  = "../../modules/vpc"
  cidr    = each.value.cidr
  subnets = each.value.subnets
  network_acl = each.value.network_acl
  tags = {
    Name = each.key
  }
}



# module "ecs" {

#   depends_on = [
#     module.vpc
#   ]

#   providers = {
#     aws = aws.aws 
#    }

#   source             = "../../modules/ecs"
#   name               = "${local.organization}-ecs"
#   container_cpu      = "256"
#   container_memory   = "512"
#   task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#   execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#   services = [
#     {
#       name          = "ecs-service-1"
#       image         = "strm/helloworld-http"
#       replicas      = 3
#       containerPort = 80
#     }
#   ]
#   vpc_id     = module.vpc["vpc-1"].vpc_id
#   subnet_ids = values(module.vpc["vpc-1"].subnet_ids)
# }

module "presentation" {
  source = "../../modules/presentation"

  providers = {
    aws = aws.aws
  }

  website_name = local.website.name
  objects      = local.website.objects
}
