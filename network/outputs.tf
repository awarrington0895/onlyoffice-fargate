locals {
  output = {
    "public_d_id"  = { name = "/network/subnet/public_d_id", val = aws_subnet.public_d.id }
    "public_e_id"  = { name = "/network/subnet/public_e_id", val = aws_subnet.public_e.id }
    "private_d_id" = { name = "/network/subnet/private_d_id", val = aws_subnet.private_d.id }
    "private_e_id" = { name = "/network/subnet/private_e_id", val = aws_subnet.private_e.id }
    "sg_nfs"       = { name = "/network/security_group/nfs_id", val = aws_security_group.nfs.id }
    "sg_http"      = { name = "/network/security_group/http_id", val = aws_security_group.http.id }
    "sg_amqp"      = { name = "/network/security_group/amqp_id", val = aws_security_group.amqp.id }
    "sg_https"     = { name = "/network/security_group/https_id", val = aws_security_group.https.id }
    "sg_egress"    = { name = "/network/security_group/egress_id", val = aws_security_group.egress_all.id }
    "vpc_id"       = { name = "/network/vpc_id", val = aws_vpc.app_vpc.id }
  }
}

resource "aws_ssm_parameter" "public_d_id" {
  for_each = local.output
  name     = each.value.name
  type     = "String"
  value    = each.value.val
}