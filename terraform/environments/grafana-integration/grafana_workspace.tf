module "grafana_workspace" {
  source = "./modules/tf-module-grafana-workspace"
  enable = local.in_default_workspace

  git_repository         = var.git_repository
  name                   = "workspace"
  project                = var.project
  stage                  = var.stage
  provider_name          = "provider"
  saml_metadata_document = "saml-metadata.xml"
  additional_policy      = data.aws_iam_policy_document.additional_policy.json
}

data "aws_iam_policy_document" "additional_policy" {
  statement {
    actions = [
      "redshift:DescribeClusters",
      "redshift-data:GetStatementResult",
      "redshift-data:DescribeStatement",
      "secretsmanager:ListSecrets"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "redshift-data:DescribeTable",
      "redshift-data:ExecuteStatement",
      "redshift-data:ListTables",
      "redshift-data:ListSchemas",
      "redshift-data:GetStatementResult",
      "redshift:GetClusterCredentials",
      "redshift-data:DescribeStatement",
      "secretsmanager:ListSecrets"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = ["redshift:GetClusterCredentials"]
    effect  = "Allow"
    resources = ["arn:aws:redshift:*:*:dbname:*/*",
    "arn:aws:redshift:*:*:dbuser:*/redshift_data_api_user"]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    effect    = "Allow"
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "secretsmanager:ResourceTag/RedshiftQueryOwner"
      values   = ["false"]
    }
  }

  statement {
    sid = "AllowAccessToAdditionalKMS"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:DescribeKey",
      "kms:Decrypt"
    ]
    resources = ["arn:aws:kms:*:${var.cap_account_id[var.stage]}:key/*"]
    condition {
      test = "ForAnyValue:StringLike"
      values = ["alias/*cap-monitoring*"]
      variable = "kms:ResourceAliases"
    }
  }
}

