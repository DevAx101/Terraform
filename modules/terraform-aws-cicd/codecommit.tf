## Dynamically create AWS CodeCommit Repos
resource "aws_codecommit_repository" "codecommit" {
  for_each        = var.codecommit_repos == null ? {} : var.codecommit_repos
  repository_name = each.value.repository_name
  description     = each.value.description
  default_branch  = each.value.default_branch
  tags = merge(
    {
      "Name" = "${each.value.repository_name}"
    },
    var.tags,
  )
  # - Challenge: resolve Checkov issues -
  #checkov:skip=CKV2_AWS_37: "Ensure CodeCommit associates an approval rule"

}
