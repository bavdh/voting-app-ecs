# trust relationship for ecr role
data "aws_iam_policy_document" "github_actions_oidc_trust_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

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
}


# ecr role with trust policty
resource "aws_iam_role" "voting-app-deployment-role" {
  name               = "VotingAppDeploymentRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_trust_document.json
}

# attach policy for ecr role
resource "aws_iam_role_policy" "voting-app-deployment-policy" {
  name   = "VotingAppDeploymentECRPolicy"
  role   = aws_iam_role.voting-app-deployment-role.id
  policy = data.aws_iam_policy_document.ecr_permissions.json
}

# Trust Policy - Allows OIDC role to trust this role 
data "aws_iam_policy_document" "ecr_push_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

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
