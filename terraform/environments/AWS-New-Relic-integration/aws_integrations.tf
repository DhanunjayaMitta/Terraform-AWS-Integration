resource "newrelic_cloud_aws_integrations" "foo" {
  account_id = var.NEW_RELIC_ACCOUNT_ID
  linked_account_id = newrelic_cloud_aws_link_account.newrelic_cloud_integration_pull.id
  billing {}
  cloudtrail {}
  health {}
  trusted_advisor {}
  vpc {}
  x_ray {}
}