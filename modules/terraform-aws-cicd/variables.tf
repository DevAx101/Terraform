## Create Module Input Variables
## - Conditional Logic Variables -
variable "create_codepipeline_artifacts_bucket" {
  type        = bool
  default     = true
  description = "Conditional creation of CodePipeline artifacts S3 Bucket."

}
variable "create_codepipeline_service_role" {
  type        = bool
  default     = true
  description = "Conditional creation of CodePipeline IAM Role."

}
variable "create_cloudwatch_service_role" {
  type        = bool
  default     = true
  description = "Conditional creation of Cloudwatch IAM Role."

}
variable "create_codebuild_service_role" {
  type        = bool
  default     = true
  description = "Conditional creation of CodeBuild IAM Role."

}
variable "create_s3_remote_backend" {
  type        = bool
  default     = false
  description = "Conditional creation of S3 bucket to store Terraform state file."

}

## - Codecommit -
variable "codecommit_repos" {
  type = map(object({
    repository_name = string
    description     = optional(string, null)
    default_branch  = optional(string, "main")
    tags            = optional(map(any), { "ContentType" = "Terraform Module" })
  }))
  description = "Collection of AWS CodeCommit Repositories you wish to create"
  default     = {}

  validation {
    condition     = alltrue([for repo in values(var.codecommit_repos) : length(repo.repository_name) > 1 && length(repo.repository_name) <= 100])
    error_message = "The name of one of the defined CodeCodecommit Repositories is too long. Repository names can be a maxmium of 100 characters, as the names are used by other resources throughout this module. This can cause deployment failures for AWS resources with smaller character limits for naming. Please ensure all repository names are 100 characters or less, and try again."
  }
}

## - CodeBuild -
variable "codebuild_projects" {
  type = map(object({

    name          = string
    description   = optional(string, null)
    build_timeout = optional(number, 60)

    env_compute_type = optional(string, "BUILD_GENERAL1_SMALL")
    env_image        = optional(string, "hashicorp/terraform:latest")
    env_type         = optional(string, "LINUX_CONTAINER")

    source_version     = optional(string, "main")
    source_type        = optional(string, "NO_SOURCE")
    source_location    = optional(string, null)
    source_clone_depth = optional(number, 1)
    path_to_build_spec = optional(string, null)
    build_spec         = optional(string, null)

    tags = optional(map(any), { "ContentType" = "Terraform Module" })

  }))
  description = "Collection of AWS CodeBuild Projects you wish to create"
  default     = {}

  validation {
    condition     = alltrue([for project in values(var.codebuild_projects) : length(project.name) > 3 && length(project.name) <= 40])
    error_message = "The name of one of the defined CodeBuild Projects is too long. Project names can be a maxmium of 40 characters, as the names are used by other resources throughout this module. This can cause deployment failures for AWS resources with smaller character limits for naming. Please ensure all project names are 40 characters or less, and try again."
  }
}
variable "codebuild_service_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM Role you wish to use with CodeBuild."

}

## - CodePipeline -
variable "codepipeline_pipelines" {
  type = map(object({

    name                    = string
    pipeline_type           = optional(string, "V2")
    stages                  = list(any)
    existing_s3_bucket_name = optional(string, null)
    event_pattern           = optional(string, null)


    tags = optional(map(any), { "Description" = "Pipeline" })

  }))
  description = "Collection of AWS CodePipeline Pipelines you wish to create"
  default     = {}

  validation {
    condition     = alltrue([for pipeline in values(var.codepipeline_pipelines) : length(pipeline.name) > 3 && length(pipeline.name) <= 40])
    error_message = "The name of one of the defined CodePipeline pipelines is too long. Pipeline names can be a maxmium of 40 characters, as the names are used by other resources throughout this module. This can cause deployment failures for AWS resources with smaller character limits for naming. Please ensure all pipeline names are 40 characters or less, and try again."
  }
}
variable "codepipeline_service_role_arn" {
  type        = string
  default     = null
  description = "The ARN of the IAM Role you wish to use with CodePipeline."

}


## - S3 -
variable "existing_s3_bucket_name" {
  type        = string
  default     = null
  description = "The name of the existing S3 bucket you wish to store the CodePipeline artifacts in."

}
variable "s3_public_access_block" {
  type        = bool
  default     = true
  description = "Conditional enabling of S3 Public Access Block."

}

## - EventBridge -
variable "eventbridge_rules_enable_force_destroy" {
  description = "Enable force destroy on all EventBridge rules. This allows the destruction of all events in the rule."
  type        = bool
  default     = true
}

## - IAM -
variable "enable_force_detach_policies" {
  description = "Enable force detaching any policies from IAM roles."
  type        = bool
  default     = true
}


## Terraform Remote State Resources
## - CodeCommit -
variable "tf_remote_state_resource_configs" {
  type = map(object({
    prefix           = optional(string, "my-prefix")
    ddb_billing_mode = optional(string, "PAY_PER_REQUEST")
    ddb_hash_key     = optional(string, "LockID")
  }))
  description = "Configurations for Terraform State Resources"
  default     = {}

  validation {
    condition     = alltrue([for config in values(var.tf_remote_state_resource_configs) : length(config.prefix) > 3 && length(config.prefix) <= 40])
    error_message = "The prefix of one of the defined Terraform Remote State Resource Configs is too long. A prefix can be a maxmium of 40 characters, as the names are used by other resources throughout this module. This can cause deployment failures for AWS resources with smaller character limits for naming. Please ensure all prefixes are 40 characters or less, and try again."
  }

  validation {
    condition     = alltrue([for config in values(var.tf_remote_state_resource_configs) : config.ddb_billing_mode == "PAY_PER_REQUEST" || config.ddb_billing_mode == "PROVISIONED"])
    error_message = "The DynamoDB Billing Mode ('ddb_billing_mode') of one of the defined Terraform Remote State Resource Configs is not an accepted value. Valid values for DynamoDB Billing Mode are 'PAY_PER_REQUEST' or 'PROVISIONED'. Please ensure the 'ddb_billing_mode' is set to one of these values and try again."
  }
}

## - Project Prefix -
variable "project_prefix" {
  type        = string
  default     = "tf-workshop"
  description = "The prefix for the current project"

  validation {
    condition     = length(var.project_prefix) > 1 && length(var.project_prefix) <= 40
    error_message = "The defined 'project_prefix' has too many characters (${length(var.project_prefix)}). This can cause deployment failures for AWS resources with smaller character limits. Please reduce the character count and try again."
  }
}

## - Tags -
variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources."
  default = {
    "IAC_PROVIDER" = "Terraform"
  }
}
