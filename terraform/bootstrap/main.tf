# trust relationship for ecr role
data "aws_iam_policy_document" "github_actions_oidc_trust_document" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account}:role/GitHubActionsOIDCRole"]
    }
  }
}

# permissions for ecr role
data "aws_iam_policy_document" "ecr_permissions" {
  statement {
    sid    = "RepoManagement"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:ListTagsForResource",
      "ecr:PutImageTagMutability"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "SecretManagement"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:TagResource"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "RDSServiceLinkedRole"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::${var.aws_account}:role/aws-service-role/rds.amazonaws.com/AWSServiceRoleForRDS"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["rds.amazonaws.com"]
    }
  }

  statement {
    sid       = "ElastiCacheServiceLinkedRole"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:aws:iam::${var.aws_account}:role/aws-service-role/elasticache.amazonaws.com/AWSServiceRoleForElastiCache"]

    condition {
      test     = "StringLike"
      variable = "iam:AWSServiceName"
      values   = ["elasticache.amazonaws.com"]
    }
  }

  statement {
    sid    = "KMSPermissions"
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSInfrastructure"
    effect = "Allow"
    actions = [
      "ecs:*",
      "autoscaling:*",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:PassRole",
      "iam:TagRole",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "MiscPermissions"
    effect = "Allow"
    actions = [
      "ec2:*",
      "rds:*"
    ]
    resources = ["*"]
  }
}


# ecr role with trust policty
resource "aws_iam_role" "voting_app_deployment_role" {
  name               = "VotingAppDeploymentRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_document.json
}

# attach policy for ecr role
resource "aws_iam_role_policy" "voting_app_deployment_policy" {
  name   = "VotingAppDeploymentECRPolicy"
  role   = aws_iam_role.voting_app_deployment_role.id
  policy = data.aws_iam_policy_document.ecr_permissions.json
}

# Trust Policy - Allows OIDC role to trust this role 
data "aws_iam_policy_document" "ecr_push_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account}:role/GitHubActionsOIDCRole"]
    }
  }
}

# Permissions policy — allows for ecr repository push image 
data "aws_iam_policy_document" "ecr_push_permissions" {
  statement {
    sid    = "ECRAuth"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPushPull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${var.aws_account}:repository/voting-app/*"]
  }
}

# The role itself — uses the TRUST policy for assume_role_policy
resource "aws_iam_role" "ecr_image_push_role" {
  name               = "ECRImagePushRole"
  assume_role_policy = data.aws_iam_policy_document.ecr_push_trust.json
}

# Attach the PERMISSIONS policy to the role separately
resource "aws_iam_role_policy" "ecr_image_push_policy" {
  name   = "ECRImagePushPolicy"
  role   = aws_iam_role.ecr_image_push_role.id
  policy = data.aws_iam_policy_document.ecr_push_permissions.json
}

# bucket for storing tfstate
resource "aws_s3_bucket" "tf_state" {
  bucket = "voting-app-terraform-state-${var.aws_account}"
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "terraform_state_access" {
  statement {
    sid    = "StateBucketList"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::voting-app-terraform-state-${var.aws_account}"
    ]
  }

  statement {
    sid    = "StateObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::voting-app-terraform-state-${var.aws_account}/voting-app/infrastructures/*"
    ]
  }
}

resource "aws_iam_role_policy" "terraform_state_access" {
  name   = "terraform-state-access"
  role   = aws_iam_role.voting_app_deployment_role.id
  policy = data.aws_iam_policy_document.terraform_state_access.json
}
