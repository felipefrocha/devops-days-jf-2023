



resource "random_integer" "subnet" {
  min = 1
  max = length(var.azs)
}

/**
 * VPC
 */

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_main_cidr_block
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = format("%s-vpc-main-%s", var.project, var.environment)
  })
}

/**
 * Subnets - privates and public
 */

resource "aws_subnet" "privates" {
  for_each = local.subnets

  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, var.subnet_size, each.value.index)
  availability_zone = each.value.az

  vpc_id = aws_vpc.main.id


  tags = merge(local.tags, {
    Name = format("%s-subnet-private-%s-%s", var.project, substr(each.value.az, -2, 2), var.environment)
  })
}

resource "aws_subnet" "publics" {
  for_each = local.subnets

  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, var.subnet_size, (length(var.azs) + each.value.index))
  availability_zone       = each.value.az
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = format("%s-subnet-public-%s-%s", var.project, substr(each.value.az, -2, 2), var.environment)
  })
}


/**
 * Internet Gateway
 */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = format("%s-igw-%s", var.project, var.environment)
  })
}


/**
 * Route Main
 */

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.main.main_route_table_id

  tags = merge(local.tags, {
    Name = format("%s-route-main-%s", var.project, var.environment)
  })
}

resource "aws_route" "internet_access" {
  route_table_id = aws_vpc.main.main_route_table_id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.tags, {
    Name = format("%s-public-rt-%s", var.project, var.environment)
  })
}

resource "aws_route_table" "private" {
  for_each = toset(var.azs)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw[each.value].id
  }
  tags = merge(local.tags, {
    Name = format("%s-private-rt-%s", var.project, var.environment)
  })
}

resource "aws_route_table_association" "publics" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.publics[each.value].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "privates" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.privates[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}



/**
 * NAT
 *
 */

resource "aws_eip" "nat" {
  for_each = toset(var.azs)
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  for_each      = toset(var.azs)
  allocation_id = aws_eip.nat[each.value].id
  subnet_id     = aws_subnet.publics[each.value].id

  tags = merge(local.tags, {
    Name = format("nat-%s", aws_subnet.publics[each.value].tags.Name)
  })
}


/**
 * VPC - support enable
 */

resource "aws_flow_log" "vpc_logs" {
  log_destination      = module.s3_bucket.s3_bucket_arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  depends_on = [
    module.s3_bucket
  ]
}

resource "random_pet" "this" {
  length = 2
}

# S3 Bucket
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = local.s3_bucket_name
  policy        = data.aws_iam_policy_document.flow_log_s3.json
  force_destroy = true

  tags = {
    Name = "vpc-flow-logs-s3-bucket"
  }
}

data "aws_iam_policy_document" "flow_log_s3" {
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${local.s3_bucket_name}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = ["s3:GetBucketAcl"]

    resources = ["arn:aws:s3:::${local.s3_bucket_name}"]
  }
}

# Cloudwatch logs
resource "aws_cloudwatch_log_group" "flow_log" {
  name_prefix = local.cloudwatch_log_group_name
}

resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  name_prefix        = "vpc-flow-log-role-"
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  role       = aws_iam_role.vpc_flow_log_cloudwatch.name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch.arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  name_prefix = "vpc-flow-log-cloudwatch-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch.json
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  statement {
    sid = "AWSVPCFlowLogsPushToCloudWatch"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}
