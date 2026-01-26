# data "aws_ssoadmin_instances" "sso" {}

# output "sso_infos" {
#   value = data.aws_ssoadmin_instances.sso.arns[0]
# }

# resource "aws_ssoadmin_permission_set" "permission_set" {
#   for_each = {
#     for f in local.permissions : f.name => f
#   }
#   name             = each.value.name
#   description      = each.value.description
#   instance_arn     = local.instance_sso
#   session_duration = each.value.session_duration
# }

# output "instance_arns" {
#   value = local.instance_sso
# }


data "aws_ssoadmin_instances" "sso" {}

resource "aws_ssoadmin_permission_set" "permission_set_cloud" {
  name         = "Permission-Set-Cloud"
  instance_arn = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
}

data "aws_iam_policy_document" "s3-permissions" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  inline_policy      = data.aws_iam_policy_document.s3-permissions.json
  instance_arn       = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_set_cloud.arn
}
