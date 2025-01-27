## Outputs
# AWS DevOps Core
output "terraform_aws_cicd_pipelines_s3_bucket_name" {
  value = module.terraform-aws-cicd.tf_state_s3_buckets_names["terraform_aws_cicd_pipelines"]
}
output "terraform_aws_cicd_pipelines_ddb_table_name" {
  value = module.terraform-aws-cicd.tf_state_ddb_table_names["terraform_aws_cicd_pipelines"]
}

# Example Production Workload
output "example_production_workload_s3_bucket_name" {
  value = module.terraform-aws-cicd.tf_state_s3_buckets_names["example_production_workload"]
}
output "example_production_workload_ddb_table_name" {
  value = module.terraform-aws-cicd.tf_state_ddb_table_names["example_production_workload"]
}
