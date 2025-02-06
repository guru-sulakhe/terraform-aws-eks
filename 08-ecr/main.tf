#ecr is used central storage in order to store the docker images by creating individual repos to each docker image 
resource "aws_ecr_repository" "backend" { #backend ecr repository
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" { #frontend ecr repository
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}