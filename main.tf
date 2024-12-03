terraform {
  required_version = "1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.79.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_dynamodb_table" "usage_metrics" {
  name         = "usage-metrics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "date"
  range_key    = "scrapedAt"

  attribute {
    name = "date"
    type = "S"
  }

  attribute {
    name = "scrapedAt"
    type = "S"
  }
}

resource "aws_iam_user" "metrics_user" {
  name = "metrics-service-user"
}

resource "aws_iam_access_key" "metrics_user_key" {
  user = aws_iam_user.metrics_user.name
}

resource "aws_iam_user_policy" "metrics_user_policy" {
  name = "metrics-access"
  user = aws_iam_user.metrics_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.usage_metrics.arn
        ]
      }
    ]
  })
}
