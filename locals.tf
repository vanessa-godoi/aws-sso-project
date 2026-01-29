locals {
  permission_files = fileset("${path.module}/permissions.d", "*.yml")
  permissions = [
    for f in local.permission_files :
    yamldecode(file("${path.module}/permissions.d/${f}"))
  ]
  instance_sso = data.aws_ssoadmin_instances.sso.arns[0]
  managed_policies_attachment = flatten([
    for p in local.permissions : [
      for arn_policies in p.policies.managed_policies : {
        permission_set_name = p.name
        managed_policy_arn  = arn_policies
      }
    ]
    if p.policies.managed_policies != null
  ])
  customer_policies_attachment = flatten([
    for p in local.permissions : [
      for name_policies in p.policies.customer_managed_policies : {
        permission_set_name = p.name
        managed_policy_name = name_policies
      }
    ]
    if p.policies.customer_managed_policies != null
  ])
}

