# ECR Repositories
resource "aws_ecr_repository" "repositories" {
  for_each = var.repositories

  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name = each.key
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = aws_ecr_repository.repositories

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
} 

# Build and push Docker images once repositories are created
resource "null_resource" "build_and_push" {
  for_each = { for name, repo in aws_ecr_repository.repositories : name => repo if contains(keys(var.build_contexts), name) }

  triggers = {
    repo_url   = each.value.repository_url
    context    = var.build_contexts[each.key]
    image_tag  = var.image_tag
    aws_region = var.aws_region
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -euo pipefail

REGISTRY="$(echo ${each.value.repository_url} | awk -F/ '{print $1}')"
aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin "$REGISTRY"

REPO_URL="${each.value.repository_url}"
REPO_NAME="${each.value.name}"
CONTEXT="${var.build_contexts[each.key]}"
TAG="${var.image_tag}"

if aws ecr batch-get-image --region ${var.aws_region} --repository-name "$REPO_NAME" --image-ids imageTag="$TAG" >/dev/null 2>&1; then
  echo "Image $REPO_URL:$TAG already exists; skipping build/push."
  exit 0
fi

docker build --platform=linux/amd64 -t "$REPO_URL:$TAG" "$CONTEXT"
docker push "$REPO_URL:$TAG"
EOT
  }

  depends_on = [aws_ecr_repository.repositories]
}