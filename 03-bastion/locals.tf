locals {
  public_subnet_id = element(split(",", data.aws_ssm_parameter.public_subnet_ids.value), 0)
}

#split() function is used for producing a list by separating a single string using a given delimiter.
#element() function is used to retrieves a single element from a list.