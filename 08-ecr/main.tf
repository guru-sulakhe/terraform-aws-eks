#ecr  It can be used to store and manage Docker images by creating individual repositories in AWS
resource "aws_ecr_repository" "backend" { #backend ecr repository
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "IMMUTABLE" #IMMUTABLE will update the docker image if the tags are updated to the dockerfile

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" { #frontend ecr repository
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "IMMUTABLE" #IMMUTABLE will update the docker image if the tags are updated to the dockerfile

  image_scanning_configuration {
    scan_on_push = true
  }
}