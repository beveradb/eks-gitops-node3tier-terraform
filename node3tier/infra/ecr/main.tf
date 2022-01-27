data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "allowlocals" {
  statement {
    sid = "AllowPushPull"

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

module "ecr_nested" {
  source           = "JamesWoolfenden/ecr/aws"
  version          = "0.2.84"
  common_tags      = {
    name = "terraform-aws-ecr-${var.name}"
  }
  name             = var.name
  repositorypolicy = data.aws_iam_policy_document.allowlocals.json
  kms_key          = ""
}

resource "aws_iam_user" "ecr_user" {
  name = "${var.name}-ecr-user"
  path = "/system/"
}

resource "aws_iam_access_key" "ecr_key" {
  user = aws_iam_user.ecr_user.name
}

resource "aws_iam_user_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  user       = aws_iam_user.ecr_user.name
}

output "ecr_access_key_id" {
  value = aws_iam_access_key.ecr_key.id
}

output "ecr_access_key_secret" {
  value = aws_iam_access_key.ecr_key.secret
}

output "ecr_repo_name" {
  description = "The name of the repository"
  value       = module.ecr_nested.ecr_repo_name
}

output "ecr_arn" {
  description = "The Amazon resource name for the repository"
  value       = module.ecr_nested.ecr_arn
}

output "ecr_repository_url" {
  description = "The URL of your new registry"
  value       = module.ecr_nested.ecr_repository_url
}

output "ecr" {
  description = "The full details of the repo"
  value       = module.ecr_nested.ecr
}
