## Dynamically create AWS CodeBuild Projects
resource "aws_codebuild_project" "codebuild" {

  for_each = var.codebuild_projects == null ? {} : var.codebuild_projects

  name          = each.value.name
  description   = each.value.description
  build_timeout = each.value.build_timeout
  service_role  = var.codebuild_service_role_arn != null ? var.codebuild_service_role_arn : aws_iam_role.codebuild_service_role[0].arn

  environment {
    compute_type = each.value.env_compute_type
    image        = each.value.env_image
    type         = each.value.env_type
  }

  source {
    type            = each.value.source_type
    location        = each.value.source_location
    git_clone_depth = each.value.source_clone_depth
    buildspec       = each.value.path_to_build_spec != null ? file("${each.value.path_to_build_spec}") : each.value.build_spec
  }

  source_version = each.value.source_version

  artifacts {
    type = "NO_ARTIFACTS"
  }

  tags = merge(
    {
      "Name" = "${each.value.name}"
    },
    var.tags,
  )

  depends_on = [
    aws_codecommit_repository.codecommit
  ]

  # - Challenge: resolve Checkov issues -
  #checkov:skip=CKV_AWS_314: "Ensure CodeBuild project environments have a logging configuration"
}
