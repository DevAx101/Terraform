## Dynamically create AWS CodePipeline pipelines
resource "aws_codepipeline" "codepipeline" {
  for_each = var.codepipeline_pipelines == null ? {} : var.codepipeline_pipelines

  name          = each.value.name
  pipeline_type = each.value.pipeline_type
  role_arn      = var.codepipeline_service_role_arn != null ? var.codepipeline_service_role_arn : aws_iam_role.codepipeline_service_role[0].arn

  artifact_store {
    location = each.value.existing_s3_bucket_name != null ? each.value.existing_s3_bucket_name : aws_s3_bucket.codepipeline_artifacts_buckets[each.key].id
    type     = "S3"
  }


  dynamic "stage" {
    for_each = [for s in each.value.stages : {
      name   = s.name
      action = s.action
    } if(lookup(s, "enabled", true))]

    content {
      name = stage.value.name
      dynamic "action" {
        for_each = stage.value.action
        content {
          name             = action.value["name"]
          owner            = action.value["owner"]
          version          = action.value["version"]
          category         = action.value["category"]
          provider         = action.value["provider"]
          input_artifacts  = lookup(action.value, "input_artifacts", [])
          output_artifacts = lookup(action.value, "output_artifacts", [])
          configuration    = lookup(action.value, "configuration", {})
          role_arn         = lookup(action.value, "role_arn", null)
          run_order        = lookup(action.value, "run_order", null)
          region           = lookup(action.value, "region", data.aws_region.current.name)
        }
      }
    }
  }

  tags = merge(
    {
      "Name" = "${each.value.name}"
    },
    var.tags,
  )

  ## - Challenge: resolve Checkov issues -
  #checkov:skip=CKV_AWS_219: "Ensure Code Pipeline Artifact store is using a KMS CMK"
}
