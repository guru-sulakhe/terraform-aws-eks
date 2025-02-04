module "db" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for DB MySQL Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "db"
}

module "ingress" {
  source         = "git::https://github.com/guru-sulakhe/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for Ingress controller"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "ingress"
}

module "cluster" {
  source         = "git::https://github.com/guru-sulakhe/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for EKS Control plane"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "eks-control-plane"
}

module "node" {
  source         = "git::https://github.com/guru-sulakhe/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for EKS node"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "eks-node"
}

module "bastion" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for Bastion Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "bastion"
}

module "vpn" {
  source = "../../terraform-aws-securitygroup"
  project_name = var.project_name
  environment = var.environment
  sg_description = "SG for VPN Instances"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  common_tags = var.common_tags
  sg_name = "vpn"
  ingress_rules = var.vpn_sg_rules
}

#Here we create inbound rules in order to create communication between two resources of the project by allowing ports to the particular resource

# bastion host will be accessed to public so that anyone can able to login in it and can access bastion
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}

# EKS cluster can be accessed from bastion host, here in bastion we can able to fetch cluster data
resource "aws_security_group_rule" "cluster_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.cluster.sg_id
}

# EKS control plane accepting all traffic from nodes, nodes can access cluster
resource "aws_security_group_rule" "cluster_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1" # All traffic
  source_security_group_id = module.node.sg_id
  security_group_id = module.cluster.sg_id
}


# EKS nodes accepting all traffic from control plane, cluster can access node
resource "aws_security_group_rule" "node_cluster" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1" # All traffic
  source_security_group_id = module.cluster.sg_id
  security_group_id = module.node.sg_id
}

# EKS nodes should accept all traffic from nodes with in VPC CIDR range, vpc can access node info
resource "aws_security_group_rule" "node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1" # All traffic
  cidr_blocks = ["10.0.0.0/16"] #your vpc CIDR
  security_group_id = module.node.sg_id
}

# RDS accepting connections from bastion, bastion can access db info
resource "aws_security_group_rule" "db_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP" # All traffic
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.db.sg_id
}

# DB should accept connections from EKS nodes which consists of pods, node can access db info
resource "aws_security_group_rule" "db_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "TCP" # All traffic
  source_security_group_id = module.node.sg_id
  security_group_id = module.db.sg_id
}

# Ingress ALB accepting traffic on 443, any public user can access ingress ALB with https port
resource "aws_security_group_rule" "ingress_public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP" # All traffic
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ingress.sg_id
}

# Ingress ALB accepting traffic on 80, any public user can access ingress ALB with http port
resource "aws_security_group_rule" "ingress_public_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP" # All traffic
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ingress.sg_id
}

# Ingress ALB accepting traffic from nodes, ingress can access any node of the cluster
resource "aws_security_group_rule" "node_ingress" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32768
  protocol          = "TCP" # All traffic
  source_security_group_id = module.ingress.sg_id
  security_group_id = module.node.sg_id
}