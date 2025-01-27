# AWS-Terraform Module Template

[![Checkov](https://github.com/nnthanh101/devops/actions/workflows/checkov.yml/badge.svg)](https://github.com/nnthanh101/devops/actions/workflows/checkov.yml)
[![TFLint](https://github.com/nnthanh101/devops/actions/workflows/tflint.yml/badge.svg)](https://github.com/nnthanh101/devops/actions/workflows/tflint.yml)
[![Terraform-Docs](https://github.com/nnthanh101/devops/actions/workflows/terraform-docs.yml/badge.svg)](https://github.com/nnthanh101/devops/actions/workflows/terraform-docs.yml)
[![Terraform Test PR](https://github.com/nnthanh101/devops/actions/workflows/terraform-test-pr.yml/badge.svg)](https://github.com/nnthanh101/devops/actions/workflows/terraform-test-pr.yml)

This repository provides the template to use for all Terraform Modules.

> Perform the steps identified as **(Reusable module)** when using this template to create a repository that will contain a reusable module. Ignore these steps when creating a standard module.

## 1. Local Development Setup:

  * [x] Install [Visual Studio Code](https://code.visualstudio.com/) [recommended extensions](https://code.visualstudio.com/docs/editor/extension-marketplace#_recommended-extensions) defined in [.vscode/extensions.json](.vscode/extensions.json) to improve you productivity and increase code quality.
  * [x] DevContainer: Docker Desktop and `nnthanh101/terraform:devops`
  The following tools need to be installed on your local machine:

    - [x] [tflint](https://github.com/terraform-linters/tflint)
    - [x] [terraform-docs](https://github.com/terraform-docs/terraform-docs)
    - [x] [checkov](https://github.com/bridgecrewio/checkov)

    ---

    - [x] [starship](https://starship.rs/)
    - [ ] [oh-my-zsh](https://ohmyz.sh/)
    - [ ] [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
    - [ ] [spaceship-prompt](https://github.com/spaceship-prompt/spaceship-prompt)

## 2. Terraform Reusable Workflow

  * [ ] Create the repository secrets, variables and environments as documented in the [Terraform Reusable Workflow Prerequisites](./aws-terraform-reusable-workflow.md).
  * [x] Update the [Deploy workflow](./.github/workflows/deploy.yml) with your environment, regions, and workflow triggers.
  * [ ] Update the [Destroy workflow](./.github/workflows/destroy.yml).


## 3. Repository Configuration Checklist

- [ ] (Reusable module) Update the content of the `locals.tf` file to what is needed by the reusable module. Usually, `tags` are not created by reusable modules, but rather by modules that call the reusable module.
- [ ] (Reusable module) Delete the [envs](./envs/) folder.
- [ ] (Reusable module) Delete the [terraform.tfvars](./terraform.tfvars) file.
- [ ] (Reusable module) Create an `examples` folder at the root of the repository where to put an example module calling the reusable module. Use a [Git URL](https://developer.hashicorp.com/terraform/language/modules/sources#generic-git-repository) selecting the latest [revision](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision) to source the reusable module.
- [ ] Delete this checklist and start coding!

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.84.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >=3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_pet.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment where to deploy the solution | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where to deploy the resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hello_world"></a> [hello\_world](#output\_hello\_world) | Test output used by Terrastest |
| <a name="output_random_pet"></a> [random\_pet](#output\_random\_pet) | Dummy output |
<!-- END_TF_DOCS -->
