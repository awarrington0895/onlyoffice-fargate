locals {
  output = {
    "/network/subnet/public_d_id"       = aws_subnet.public_d.id
    "/network/subnet/public_e_id"       = aws_subnet.public_e.id
    "/network/subnet/private_d_id"      = aws_subnet.private_d.id
    "/network/subnet/private_e_id"      = aws_subnet.private_e.id
    "/network/security_group/nfs_id"    = aws_security_group.nfs.id
    "/network/security_group/http_id"   = aws_security_group.http.id
    "/network/security_group/amqp_id"   = aws_security_group.amqp.id
    "/network/security_group/https_id"  = aws_security_group.https.id
    "/network/security_group/egress_id" = aws_security_group.egress_all.id
    "/network/vpc_id"                   = aws_vpc.app_vpc.id
  }
}

resource "aws_ssm_parameter" "public_d_id" {
  for_each = local.output
  name     = each.key
  type     = "String"
  value    = each.value
}