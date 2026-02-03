resource "aws_ssoadmin_permission_set" "permission_set" {
  for_each = {
    for f in local.permissions : f.name => f
  }
  name             = each.value.name
  description      = each.value.description
  instance_arn     = local.instance_sso
  session_duration = each.value.session_duration
}
resource "aws_ssoadmin_permission_set_inline_policy" "attach-inline-policy" {
  for_each = {
    for p in local.permissions : p.name => p
    if p.policies.inline_policies != null
  }

  inline_policy      = each.value.policies.inline_policies
  instance_arn       = local.instance_sso
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.key].arn
}
resource "aws_ssoadmin_managed_policy_attachment" "attach-aws-policies" {

  for_each = {
    for p in local.managed_policies_attachment : "${p.permission_set_name}-${basename(p.managed_policy_arn)}" => p
  }

  instance_arn       = local.instance_sso
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value.permission_set_name].arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "attach-customer-policies" {
  for_each = {
    for p in local.customer_policies_attachment : "${p.permission_set_name}-${p.managed_policy_name}" => p
  }
  instance_arn       = local.instance_sso
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value.permission_set_name].arn
  customer_managed_policy_reference {
    name = each.value.managed_policy_name
  }
}
resource "aws_iam_group" "create-groups" {
  for_each = {
    for g in local.groups : g.name => g
  }
  name = each.value.name
  path = each.value.path
}

