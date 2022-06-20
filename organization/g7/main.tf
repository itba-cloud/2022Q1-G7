

module "vpc" {
  for_each = local.vpcs

  providers = {
    aws = aws.aws
  }

  source  = "../../modules/vpc_4.0"
  cidr    = each.value.cidr
  subnets = each.value.subnets
  tags = {
    Name = each.key
  }
}

module "ecs" {

  depends_on = [
    module.vpc
  ]

  source             = "../../modules/ecs_4.0"
  name               = "${local.organization}-ecs"
  container_cpu      = "256"
  container_memory   = "512"
  task_role_arn      = "arn:aws:iam::974558964901:role/LabRole"
  execution_role_arn = "arn:aws:iam::974558964901:role/LabRole"
  services = [
    {
      name          = "ecs-service-1"
      image         = "strm/helloworld-http"
      replicas      = 3
      containerPort = 80
    }
  ]
  vpc_id     = module.vpc["vpc-1"].vpc_id
  subnet_ids = values(module.vpc["vpc-1"].subnet_ids)
}

# module "presentation" {
#   source = "../../modules/presentation_4.0"

#   providers = {
#     aws = aws.aws
#   }

#   website_name = local.website.name
#   objects      = local.website.objects
# }

# module "lambda"{
#   for_each = local.lambdas
#   source = "../../modules/lambda_4.0"

#   providers = {
#     aws = aws.aws
#   }

#   name = each.key
#   path = each.value.path
#   principal = each.value.principal
# }

# module "dynamodb" {
#   source = "../../modules/dynambodb_4.0"

#   name        = "users"
#   hash_key    = "id"
#   range_key   = "username"
#   table_class = "STANDARD"

#   attributes = [
#     {
#       name = "id"
#       type = "S"
#     },
#     {
#       name = "username"
#       type = "S"
#     },
#     {
#       name = "age"
#       type = "N"
#     },
#     {
#       name = "is_instructor"
#       type = "BOOL"
#     },
#     {
#       name = "created_at"
#       type = "S"
#     },
#     {
#       name = "updated_at"
#       type = "S"
#     },
#     {
#       name = "deleted_at"
#       type = "S"
#     },
#     {
#       name = "deleted"
#       type = "BOOL"
#     },
#     {
#       name = "courses"
#       type = "SS"
#     },

#   ]

#   global_secondary_indexes = [
#     {
#       name               = "NameIndex"
#       hash_key           = "name"
#       range_key          = "age"
#       projection_type    = "INCLUDE"
#       non_key_attributes = ["id"]
#     }
#   ]

#   tags = {
#     Terraform   = "true"
#     Environment = "staging"
#   }
# }

