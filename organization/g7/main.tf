

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

module "presentation" {
  source = "../../modules/presentation_4.0"

  providers = {
    aws = aws.aws
  }

  website_name = local.website.name
  region = local.region
  objects      = local.website.objects
}

