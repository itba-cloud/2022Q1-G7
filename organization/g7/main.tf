

module "vpc" {
  for_each = local.vpcs

  providers = {
    aws = aws.aws
  }

  source  = "../../modules/vpc"
  cidr    = each.value.cidr
  subnets = each.value.subnets
  tags = {
    Name = each.key
  }
}

module "presentation" {
  source = "../../modules/presentation"

  providers = {
    aws = aws.aws
  }

  website_name = local.website.name
  objects      = local.website.objects
}


# module "dynamodb" {
#   source = "../../modules/dynambodb"

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

