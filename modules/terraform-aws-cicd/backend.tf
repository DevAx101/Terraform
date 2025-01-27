## Dynamically create resources for S3 Remote Backend (Amazon S3 and DynamoDB)
resource "random_string" "tf_remote_state_s3_buckets" {
  for_each = var.tf_remote_state_resource_configs == null ? {} : var.tf_remote_state_resource_configs
  length   = 4
  special  = false
  upper    = false
}

resource "aws_s3_bucket" "tf_remote_state_s3_buckets" {
  for_each      = var.tf_remote_state_resource_configs == null ? {} : var.tf_remote_state_resource_configs
  bucket        = "${each.value.prefix}-tf-state-${random_string.tf_remote_state_s3_buckets[each.key].result}"
  force_destroy = true

  # - Challenge: resolve Checkov issues -
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #
}

resource "aws_s3_bucket_versioning" "tf_remote_state_s3_buckets" {
  for_each = var.tf_remote_state_resource_configs == null ? {} : var.tf_remote_state_resource_configs
  bucket   = aws_s3_bucket.tf_remote_state_s3_buckets[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_remote_state_s3_buckets_pabs" {
  for_each = var.tf_remote_state_resource_configs == null ? {} : var.tf_remote_state_resource_configs
  bucket   = aws_s3_bucket.tf_remote_state_s3_buckets[each.key].id

  block_public_acls       = var.s3_public_access_block
  block_public_policy     = var.s3_public_access_block
  ignore_public_acls      = var.s3_public_access_block
  restrict_public_buckets = var.s3_public_access_block
}

# Terraform State Locking
resource "random_string" "tf_remote_state_lock_tables" {
  for_each = var.tf_remote_state_resource_configs == null ? {} : var.tf_remote_state_resource_configs
  length   = 4
  special  = false
  upper    = false
}
resource "aws_dynamodb_table" "tf_remote_state_lock_tables" {
  for_each     = var.tf_remote_state_resource_configs == null ? {} : var.tf_remote_state_resource_configs
  name         = "${each.value.prefix}-tf-state-lock-${random_string.tf_remote_state_lock_tables[each.key].result}"
  billing_mode = each.value.ddb_billing_mode
  hash_key     = each.value.ddb_hash_key

  attribute {
    name = each.value.ddb_hash_key
    type = "S"
  }

  # - Challenge: resolve Checkov issues -
  #checkov:skip=CKV_AWS_28: "Ensure DynamoDB point in time recovery (backup) is enabled"
  #checkov:skip=CKV_AWS_119: "Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
  #checkov:skip=CKV2_AWS_16: "Ensure that Auto Scaling is enabled on your DynamoDB tables"
}
