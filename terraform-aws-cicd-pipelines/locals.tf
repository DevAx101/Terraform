## Locals
locals {
  # -- CodeCommit --
  # CodeCommit Repository Names
  module_aws_tf_cicd_repository_name          = "terraform-aws-cicd"
  terraform_aws_cicd_pipelines_repository_name             = "terraform-aws-cicd-pipelines"
  example_production_workload_repository_name = "example-prod-workload"


  # -- CodeBuild --
  # - CodeBuild Project Names -
  # 'terraform-aws-cicd' Build Projects
  tf_test_module_aws_tf_cicd_codebuild_project_name = "TerraformTest-terraform-aws-cicd"
  chevkov_module_aws_tf_cicd_codebuild_project_name = "Checkov-terraform-aws-cicd"
  # 'terraform-aws-cicd-pipelines' Build Projects
  tf_test_terraform_aws_cicd_pipelines_codebuild_project_name = "TerraformTest-terraform-aws-cicd-pipelines"
  chevkov_terraform_aws_cicd_pipelines_codebuild_project_name = "Checkov-terraform-aws-cicd-pipelines"
  # 'example-production-workload' Build Projects
  tf_test_example_production_workload_codebuild_project_name  = "TerraformTest-example-prod-workload"
  chevkov_example_production_workload_codebuild_project_name  = "Checkov-example-prod-workload"
  tf_apply_example_production_workload_codebuild_project_name = "TFApply-example-prod-workload"


  # - CodeBuild buildspec paths -
  tf_test_path_to_buildspec  = "./buildspec/tf-test-buildspec.yml"  # Terraform Test Framework (Test Functionality)
  checkov_path_to_buildspec  = "./buildspec/checkov-buildspec.yml"  # Checkov (Test Security)
  tf_apply_path_to_buildspec = "./buildspec/tf-apply-buildspec.yml" # TF Apply (Provision Resources)


  # -- CodePipeline --
  # - CodePipeline Pipeline Names -
  tf_module_validation_module_aws_tf_cicd_codepipeline_pipeline_name   = "terraform-aws-cicd"
  tf_deployment_example_production_workload_codepipeline_pipeline_name = "example-prod-workload"

  # Images
  checkov_image = "bridgecrew/checkov"
}

