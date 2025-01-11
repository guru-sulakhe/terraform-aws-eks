data "aws_ssm_parameter" "vpc_id" { #this is used to query vpc_id from provider
  name = "/${var.project_name}/${var.environment}/vpc_id"
}