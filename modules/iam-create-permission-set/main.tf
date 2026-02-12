data "aws_ssoadmin_instances" "sso" {}

resource "aws_ssoadmin_permission_set" "permission_set" {
  for_each = {
    for f in local.permissions : f.name => f
  }
  name             = each.value.name
  description      = each.value.description
  instance_arn     = local.instance_sso
  session_duration = each.value.session_duration
}
