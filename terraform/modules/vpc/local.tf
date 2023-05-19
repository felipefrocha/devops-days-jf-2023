locals {
  tags = var.tags

  s3_bucket_name            = format("vpc-flow-logs-bk-%s-", var.environment)
  cloudwatch_log_group_name = format("vpc-flow-logs-cw-%s", var.environment)

  random = random_integer.subnet.result

  subnets = { for k, v in var.azs : v => {
    az    = v
    index = k
    }
  }
}
