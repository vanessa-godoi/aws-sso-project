locals {
  permission_files = fileset("${path.module}/permissions.d", "*.yml")
  permissions = [
    for f in local.permission_files :
    yamldecode(file("${path.module}/permissions.d/${f}"))
  ]
  instance_sso        = data.aws_ssoadmin_instances.sso.arns[0]
  permission_set_arns = data.aws_ssoadmin_permission_sets.arns.arns[0]
}

