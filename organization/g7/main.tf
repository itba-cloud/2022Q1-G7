module "vpc" {
  for_each = local.vpcs

  providers = {
    aws = aws.aws
  }

  source           = "../../modules/vpc"
  cidr             = each.value.cidr
  private_subnets  = each.value.private_subnets
  public_subnets   = each.value.public_subnets
  network_acl      = each.value.network_acl
  network_acl_tags = each.value.network_acl.tags
  vpc_tags         = each.value.tags

}

# module "ecs" {

#   depends_on = [
#     module.vpc
#   ]

#   providers = {
#     aws = aws.aws
#   }

#   source             = "../../modules/ecs"
#   name               = "${local.organization}-ecs"
#   container_cpu      = "256"
#   container_memory   = "512"
#   task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#   execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#   services = [
#     {
#       name          = "ecs-service-1"
#       image         = "chats:latest"
#       location      = "chats/Dockerfile"
#       replicas      = 3
#       containerPort = 80
#     }
#   ]
#   vpc_id     = module.vpc["vpc-1"].vpc_id
#   subnet_ids = values(module.vpc["vpc-1"].subnet_ids)

#   task_definition_tags = local.ecs.task_definition_tags
#   cluster_tags        = local.ecs.cluster_tags
#   security_group_tags = local.ecs.security_group_tags
#   alb_tags = local.ecs.alb.tags

# }

module "presentation" {
  source = "../../modules/presentation"

  providers = {
    aws = aws.aws
  }

  website_name = local.website.name
  objects      = local.website.objects

  www_bucket_tags = local.website.www_tags
  bucket_tags     = local.website.official_tags
  bucket_log_tags = local.website.log_tags
}
