## Create Data Source to fetch current AWS Region
## Current AWS region
data "aws_region" "current" {}

## Current AWS Caller Identity (IAM info)
data "aws_caller_identity" "current" {}

