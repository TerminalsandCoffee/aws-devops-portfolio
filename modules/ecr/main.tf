# ──────────────────────────────────────────────────────────────
# ECR Repository
# ──────────────────────────────────────────────────────────────
resource "aws_ecr_repository" "repo" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# ──────────────────────────────────────────────────────────────
# Lifecycle Policy – Keep last N images
# ──────────────────────────────────────────────────────────────
resource "aws_ecr_lifecycle_policy" "keep_last_n" {
  count = var.keep_last_n_images > 0 ? 1 : 0

  repository = aws_ecr_repository.repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.keep_last_n_images} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = var.keep_last_n_images
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Expire untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}