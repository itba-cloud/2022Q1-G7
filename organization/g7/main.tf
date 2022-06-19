

module "vpc" {
  for_each = local.vpcs

  providers = {
    aws = aws.aws
   }

  source   = "../../modules/vpc_4.0"
  cidr    = each.value.cidr
  subnets = each.value.subnets
  tags = {
    Name = each.key
  }
}
