resource "aws_ssm_parameter" "acm_certificate_arn" { #uploading acm_certificate_arn to aws_ssm_parameter
  name  = "/${var.project_name}/${var.environment}/acm_certificate_arn"
  type  = "String"
  value = aws_acm_certificate.expense.arn
}