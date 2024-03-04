resource "newrelic_cloud_aws_link_account" "newrelic_cloud_integration_push" {
  arn = aws_iam_role.newrelic_aws_role.arn
  metric_collection_mode = "PUSH"
  name = "${var.NEW_RELIC_ACCOUNT_NAME} Push"
  depends_on = [aws_iam_role_policy_attachment.newrelic_aws_policy_attach]
}

resource "aws_cloudwatch_metric_stream" "newrelic_metric_stream" {
  name          = "newrelic-metric-stream"
  role_arn      = aws_iam_role.metric_stream_to_firehose.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.newrelic_firehost_stream.arn
  output_format = "opentelemetry0.7"
  dynamic "include_filter" {
    for_each = var.cloudwatch_metric_stream_include_filter
    content {
      namespace = include_filter["value"]
    }
  }
}

resource "newrelic_cloud_aws_link_account" "newrelic_cloud_integration_pull" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  arn = aws_iam_role.newrelic_aws_role.arn
  metric_collection_mode = "PULL"
  name = "${var.NEW_RELIC_ACCOUNT_NAME} Pull"
  depends_on = [aws_iam_role_policy_attachment.newrelic_aws_policy_attach]
}