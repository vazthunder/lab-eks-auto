# resource "aws_security_group" "endpoints" {
#   name        = "${var.name_prefix}-vpc-endpoints"
#   description = "Allow HTTPS from VPC CIDR to VPC endpoints"
#   vpc_id      = aws_vpc.main.id
# 
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [var.vpc_cidr]
#   }
# 
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# 
#   tags = merge(var.tags, {
#     Name = "${var.name_prefix}-vpc-endpoints"
#   })
# }

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [aws_route_table.private.id]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-s3-gateway"
  })
}

# locals {
#   interface_endpoints = {
#     ecr_api              = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
#     ecr_dkr              = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
#     ec2                  = "com.amazonaws.${data.aws_region.current.region}.ec2"
#     sts                  = "com.amazonaws.${data.aws_region.current.region}.sts"
#     elasticloadbalancing = "com.amazonaws.${data.aws_region.current.region}.elasticloadbalancing"
#     logs                 = "com.amazonaws.${data.aws_region.current.region}.logs"
#   }
# }
# 
# resource "aws_vpc_endpoint" "interface" {
#   for_each = local.interface_endpoints
# 
#   vpc_id              = aws_vpc.main.id
#   service_name        = each.value
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.endpoints.id]
#   private_dns_enabled = true
# 
#   tags = merge(var.tags, {
#     Name = "${var.name_prefix}-${each.key}"
#   })
# }

data "aws_region" "current" {}
