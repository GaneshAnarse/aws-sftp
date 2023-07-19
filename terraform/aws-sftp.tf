# Make sure to replace the placeholder values such as -
# the S3 bucket name and the SNS topic ARN with your actual values in the provided terraform file.
provider "aws" {
  region = "eu-west-1"
}

# VPC Setup
resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_public_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "example_private_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
}

# SFTP Server
resource "aws_transfer_server" "example_sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  endpoint_type          = "PUBLIC"
  vpc_id                 = aws_vpc.example_vpc.id
  subnet_ids             = [aws_subnet.example_private_subnet.id]
}

# S3 Bucket
resource "aws_s3_bucket" "example_s3_bucket" {
  bucket = "example-data-lake-bucket"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

# VPC Endpoint for S3
resource "aws_vpc_endpoint" "example_s3_endpoint" {
  vpc_id            = aws_vpc.example_vpc.id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"
}

# IAM Roles and Policies
resource "aws_iam_role" "example_sftp_role" {
  name = "example-sftp-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "example_s3_policy_attachment" {
  role       = aws_iam_role.example_sftp_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# CloudWatch Events
resource "aws_cloudwatch_event_rule" "example_s3_event_rule" {
  name        = "example-s3-event-rule"
  description = "Trigger event when new files are uploaded to S3"
  event_pattern = <<EOF
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject",
      "CompleteMultipartUpload"
    ],
    "requestParameters": {
      "bucketName": [
        "${aws_s3_bucket.example_s3_bucket.bucket}"
      ]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "example_s3_event_target" {
  rule      = aws_cloudwatch_event_rule.example_s3_event_rule.name
  target_id = "example-s3-event-target"
  arn       = "arn:aws:sns:eu-west-1:123456789012:example-alerts-topic"  # Replace with your SNS topic
}
