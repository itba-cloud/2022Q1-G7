module "vpc" {
  for_each = local.vpcs

  providers = {
    aws = aws.aws
  }

  source               = "../../modules/vpc"
  cidr                 = each.value.cidr
  private_subnets      = each.value.private_subnets
  public_subnets       = each.value.public_subnets
  network_acl          = each.value.network_acl
  network_acl_tags     = each.value.network_acl.tags
  vpc_tags             = each.value.tags
  enable_dns_hostnames = each.value.enable_dns_hostnames
  enable_dns_support   = each.value.enable_dns_support

}

# Generate a new SSH key
resource "tls_private_key" "ssh" {
  provider  = tls
  algorithm = "RSA"
  rsa_bits  = "4096"
}

module "ecs" {

  depends_on = [
    module.vpc

  ]

  providers = {
    aws = aws.aws
  }

  source             = "../../modules/ecs"
  name               = "${local.organization}-ecs"
  container_cpu      = "256"
  container_memory   = "512"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  client_id     = aws_cognito_user_pool_client.userpool_client.id
  client_secret = aws_cognito_user_pool_client.userpool_client.client_secret
  auth_domain   = "https://${local.organization}-auth-domain.auth.${data.aws_region.current.name}.amazoncognito.com"
  redirect_uri  = local.cognito.callback_url_endpoint
  private_key   = tls_private_key.ssh.public_key_fingerprint_sha256

  services           = local.services
  vpc_id             = module.vpc["vpc-1"].vpc_id
  vpc_cidr           = module.vpc["vpc-1"].vpc_cidr
  public_subnet_ids  = values(module.vpc["vpc-1"].public_subnet_ids)
  private_subnet_ids = values(module.vpc["vpc-1"].private_subnet_ids)

  task_definition_tags = local.ecs.task_definition_tags
  cluster_tags         = local.ecs.cluster_tags
  security_group_tags  = local.ecs.security_group_tags
  private_alb_tags     = local.ecs.alb.tags
  logs_region          = local.region
  health_check_path    = local.ecs.health_check_path
}

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


# module "chat" {
#   source = "../../modules/chat"
#   providers = {
#     aws = aws.aws
#   }
# }
