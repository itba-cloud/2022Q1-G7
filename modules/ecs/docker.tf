resource "aws_ecr_repository" "this" {
  count = length(var.services)

  name                 = "ecr-${element(var.services, count.index).name}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = length(var.services)
  repository = aws_ecr_repository.this[count.index].name

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


#reference: https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs
#reference: https://medium.com/devops-engineer-documentation/terraform-deploying-a-docker-image-to-an-aws-ecs-cluster-3931337e82fb
resource "docker_registry_image" "this" {
  count = length(var.services)
  name  = "${aws_ecr_repository.this[count.index].repository_url}:latest"

  build {
    context = "../../resources/services/${element(var.services, count.index).location}"
  }
}
