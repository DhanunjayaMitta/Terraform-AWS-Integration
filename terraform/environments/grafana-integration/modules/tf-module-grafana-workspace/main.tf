data "aws_caller_identity" "current" {}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  in_default_workspace       = terraform.workspace == "default"
  count_in_default_workspace = local.in_default_workspace ? 1 : 0
}

resource "aws_grafana_workspace" "grafana_workspace" {
  count                    = local.count_in_default_workspace
  name                     = module.labels.id
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["SAML"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.grafana_workspace.arn
}

resource "aws_iam_saml_provider" "saml_provider" {
  count = var.enable ? 1 : 0

  depends_on             = [aws_grafana_workspace.grafana_workspace]
  name                   = module.labels.resource[var.provider_name].id
  saml_metadata_document = file(var.saml_metadata_document)
}

resource "aws_iam_role" "grafana_workspace" {
  assume_role_policy = data.aws_iam_policy_document.grafana_workspace_assume.json
  name               = module.labels.resource["role"].id
  tags               = module.labels.resource["role"].tags
  path               = "/service-role/"
}

//Grafana purposes
data "aws_iam_policy_document" "grafana_workspace_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["grafana.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      //values   = ["arn:aws:grafana:eu-west-1:${var.cap_account_id[var.stage]}:/workspaces/*"]
      values   = ["arn:aws:grafana:eu-west-1:${local.account_id}:/workspaces/*"]
    }
  }
}

//Grafana purposes for EC2, CloudWatch and logs
data "aws_iam_policy_document" "grafana" {
  statement {
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    actions = [
      "tag:GetResources"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "grafana_cloudwatch" {
  policy = data.aws_iam_policy_document.grafana.json
  role   = aws_iam_role.grafana_workspace.id
}

resource "aws_iam_role_policy" "additional_policy" {
  policy = var.additional_policy
  role   = aws_iam_role.grafana_workspace.id
}
