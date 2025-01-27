## Create output values for the module
output "tf_state_s3_buckets_names" {
  value = tomap({
    for k, bucket in aws_s3_bucket.tf_remote_state_s3_buckets : k => bucket.id
  })
}

output "tf_state_ddb_table_names" {
  value = tomap({
    for k, table in aws_dynamodb_table.tf_remote_state_lock_tables : k => table.id
  })
}
