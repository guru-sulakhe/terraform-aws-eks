variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project = "expense"
    Environment = "dev"
    Terraform = "true"
    Component = "ingress-alb"
  }
}

variable "zone_name" {
  default = "guru97s.cloud"
}

variable "zone_id" { #your zone ID
  default = "Z08884492QFPW45HM4UQO"
}