variable "aws_resource_prefix" {
  description = "Prefix for the AWS Resources"
  default = "eu"
}

variable "NEW_RELIC_ACCOUNT_ID" {
  type = string
  default = "3815665"
}
variable "NEW_RELIC_API_KEY"{
  type = string
  default = "NRAK-UT9G7G3FEHQWFWYNNKGOSNM0D3A"
}

variable "NEW_RELIC_ACCOUNT_NAME" {
  description = "Account Name"
  default = "Account 3815665"
}

variable "NEW_RELIC_CLOUDWATCH_ENDPOINT" {
  type = string
  # Depending on where your New Relic Account is located you need to change the default
  #default = "https://aws-api.newrelic.com/cloudwatch-metrics/v1" # US Datacenter
  default = "https://aws-api.eu01.nr-data.net/cloudwatch-metrics/v1" # EU Datacenter
}

variable "region" {
  description = "Default Region"
  default     = "eu-west-1"
}

variable "cloudwatch_metric_stream_include_filter"{
  default = ["AWS/EC2", "AWS/S3", "AWS/IAM", "AWS/SageMaker", "AWS/Redshift", "AWS/ALB", "AWS/DynamoDB"]
}