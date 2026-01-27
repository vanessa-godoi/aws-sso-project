data "aws_ssoadmin_instances" "sso" {}

# output "sso_infos" {
#   value = data.aws_ssoadmin_instances.sso.arns[0]
# }

resource "aws_ssoadmin_permission_set" "permission_set" {
  for_each = {
    for f in local.permissions : f.name => f
  }
  name             = each.value.name
  description      = each.value.description
  instance_arn     = local.instance_sso
  session_duration = each.value.session_duration
}

# output "instance_arns" {
#   value = local.instance_sso
# }

# resource "aws_ssoadmin_permission_set_inline_policy" "attach-inline-policy" {
#   for_each = {
#     for p in local.permissions : p.policies.inline_policies => p...
#   }

#   inline_policy      = each.value[0].policies.inline_policies
#   instance_arn       = local.instance_sso
#   permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value[0].name].arn
# }

resource "aws_ssoadmin_permissions_boundary_attachment" "attach-managed-policies" {
  for_each = {
    for x in local.permissions : x.description => x...
  }

  instance_arn       = local.instance_sso
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value[0].name].arn
  permissions_boundary {
    managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  }
}
