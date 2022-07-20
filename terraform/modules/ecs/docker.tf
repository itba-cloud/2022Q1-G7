resource "aws_ecr_repository" "this" {
  for_each = { for idx, service in keys(var.services) :
    idx => var.services[service]
  }

  name                 = "ecr-${each.value.name}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = { for idx, service in keys(var.services) :
    idx => var.services[service]
  }
  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
    }]
  })
}
