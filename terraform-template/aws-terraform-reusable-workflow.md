# Terraform Reusable Workflow

This repository provides a GitHub Actions reusable workflow that manages infrastructure provisioning within AWS using Terraform.

<!-- TOC -->

- [Terraform Reusable Workflow](#terraform-reusable-workflow)
  - [Usage](#usage)
    - [Determine the Workspace Execution Mode](#determine-the-workspace-execution-mode)
    - [Prerequisites](#prerequisites)
    - [Remote/Agent Execution mode configuration](#remoteagent-execution-mode-configuration)
      - [AWS IAM Terraform Cloud/Enterprise](#aws-iam-terraform-cloudenterprise)
      - [Terraform Cloud/Enterprise](#terraform-cloudenterprise)
      - [Deploy workflow with matrix strategy](#deploy-workflow-with-matrix-strategy)
      - [Optional Destroy workflow with matrix strategy](#optional-destroy-workflow-with-matrix-strategy)
    - [Local Execution mode configuration](#local-execution-mode-configuration)
      - [AWS IAM GitHub Actions](#aws-iam-github-actions)
      - [GitHub Repository](#github-repository)
      - [Sequential Deploy workflow](#sequential-deploy-workflow)
      - [Optional Sequential Destroy workflow](#optional-sequential-destroy-workflow)
  - [Security](#security)
  - [License](#license)

<!-- /TOC -->

## Usage

This section provides the steps required to call this reusable workflow from another repository in order to test and deploy AWS resources with Terraform in multiple accounts. The workflow provided in this repository supports both Terraform Cloud/Enterprise Remote/Agent and Local [Execution Modes](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings#execution-mode).

### Determine the Workspace Execution Mode

The default value is **Remote**, which instructs Terraform Cloud/Enterprise to perform Terraform runs on its own virtual machines. This provides a consistent and reliable run environment, and enables advanced features like Sentinel policy enforcement, cost estimation, notifications, version control integration, and more. The **Agent** mode acts in the same way but performs Terraform runs on isolated, private, or on-premises infrastructure called [Terraform Cloud Agents](https://developer.hashicorp.com/terraform/cloud-docs/agents).

If a Terraform configuration is using providers or modules that require binaries like Python, and you cannot use an agent because none are available in your Terraform Cloud/Enterprise organization, you need to use the **Local** execution mode.

### Prerequisites

- AWS Account for each environment where you want to test and deploy AWS resources
- Terraform Cloud/Enterprise organization
- Terraform Cloud/Enterprise workspace using the CLI-driven workflow type for each AWS account
- Terraform Cloud/Enterprise user or team token that can access all the workspaces
- GitHub Repository with the following configuration:
  - `TF_TOKEN` repository secret
  - Repository variables:
    - `APP_NAME`
    - `TF_HOSTNAME`
    - `TF_ORGANIZATION`
    - `TF_VERSION`
  - Environments
    > Use the *`env`* format for environment names (e.g., `dev`,`test`,`prod`)
  - (Optional) If not using Terraform Cloud, update `TF_TOKEN_app_terraform_io` environment variable in [terraform-reusable.yml](./.github/workflows/terraform-reusable.yml#L64) to use your Terraform Enterprise endpoint hostname, replacing any periods with underscores. Refer to [Running Terraform in automation](https://developer.hashicorp.com/terraform/tutorials/automation/automate-terraform#terraform-cloud) for more information.

### Remote/Agent Execution mode configuration

#### AWS IAM (Terraform Cloud/Enterprise)

- IAM [Terraform Cloud/Enterprise OIDC provider](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration#create-an-oidc-identity-provider) configured in each AWS account
- Terraform Execution IAM plan and apply roles with [Terraform Cloud/Enterprise OIDC trust policy](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration#create-an-oidc-identity-provider) created in each AWS account

#### Terraform Cloud/Enterprise

- Add sensitive variables required by the terraform module to the workspaces
- Create the dynamic provider credentials [environment variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration#optional-environment-variables) in all workspaces:
  - TFC_AWS_PROVIDER_AUTH
  - TFC_AWS_PLAN_ROLE_ARN
  - TFC_AWS_APPLY_ROLE_ARN

#### Deploy workflow with matrix strategy

In the repository where the Terraform code to execute resides, define the caller deploy workflow like in the following example:

```yaml
name: Deploy

permissions:
  id-token: write # This is required for requesting the JWT
  contents: read # This is required for actions/checkout
  pull-requests: write # This is required to add comments to Pull Requests
  deployments: write # This is required to deactivate deployments

on:
  workflow_dispatch:
  pull_request:
    paths:
      - "**.tf*"
      - ".github/workflows/deploy.yml"
  push:
    branches:
      - "main"
    paths:
      - "**.tf*"
      - ".github/workflows/deploy.yml"

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: false

jobs:
  deploy:
    name: Progressive Deployment
    uses: ./terraform-reusable.yml
    strategy:
      max-parallel: 1
      fail-fast: true
      matrix:
        include:
          - environment: dev
            region: us-east-1
          - environment: test
            region: us-west-2
          - environment: prod
            region: us-east-2
    with:
      deploy: true
      tf-version: ${{ vars.TF_VERSION }}
      tf-organization: ${{ vars.TF_ORGANIZATION }}
      tf-hostname: ${{ vars.TF_HOSTNAME }}
      tf-workspace: ${{ vars.APP_NAME }}-${{ matrix.environment }}
      aws-region: ${{ matrix.region }}
      environment: ${{ matrix.environment }}
      ref: v1.2.0
    secrets:
      tf-token: ${{ secrets.TF_TOKEN }}
```

#### (Optional) Destroy workflow with matrix strategy

Create the caller destroy workflow file like in the following example:

```yaml
name: Destroy

permissions:
  id-token: write # This is required for requesting the JWT
  contents: read # This is required for actions/checkout
  pull-requests: write # This is required to add comments to Pull Requests
  deployments: write # This is required to deactivate deployments

on:
  workflow_dispatch:

jobs:
  destroy:
    name: Progressive Destroy
    uses: ./terraform-reusable.yml
    strategy:
      max-parallel: 1
      fail-fast: true
      matrix:
        include:
          - environment: dev
            region: us-east-1
          - environment: test
            region: us-west-2
          - environment: prod
            region: us-east-2
    with:
      deploy: false
      tf-version: ${{ vars.TF_VERSION }}
      tf-organization: ${{ vars.TF_ORGANIZATION }}
      tf-hostname: ${{ vars.TF_HOSTNAME }}
      tf-workspace: FI-AWSCE-${{ vars.APP_NAME }}-${{ matrix.environment }}
      aws-region: ${{ matrix.region }}
      environment: ${{ matrix.environment }}
      ref: v1.2.0
    secrets:
      tf-token: ${{ secrets.TF_TOKEN }}
```

### Local Execution mode configuration

#### AWS IAM (GitHub Actions)

- IAM [GitHub Actions OIDC provider](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) configured in each AWS account
- Terraform Execution IAM plan and apply roles with [GitHub OIDC trust policy](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services#configuring-the-role-and-trust-policy) created in each AWS account

#### GitHub Repository

- Create **Repository secrets** for all the Terraform Execution IAM **plan** role ARNs using the `<ENV>_AWS_PLAN_ROLE_ARN` format
- Create **Environment secrets** for all the Terraform Execution IAM **apply** role ARNs using the `<ENV>_AWS_APPLY_ROLE_ARN` format
- (Optional) Create `<ENV>_EXTRA_ARGS` repository secrets for passing sensitive variables required by the terraform module using the `-var` option like in the following example:

```terraform
-var="secret_password=SuperSecretPassword" \
-var="secret_token=super_secret_token"
```

#### Sequential Deploy workflow

Create the caller deploy workflow file like in the following example:

```yaml
name: Deploy

permissions:
  id-token: write # This is required for requesting the JWT
  contents: read # This is required for actions/checkout
  pull-requests: write # This is required to add comments to Pull Requests
  deployments: write # This is required to deactivate deployments

on:
  workflow_dispatch:
  pull_request:
    paths:
      - "**.tf*"
      - ".github/workflows/deploy.yml"
  push:
    branches:
      - "main"
    paths:
      - "**.tf*"
      - ".github/workflows/deploy.yml"

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: false

jobs:
  deploy-dev:
    name: Dev Deployment
    uses: ./terraform-reusable.yml
    with:
      deploy: true
      tf-version: ${{ vars.TF_VERSION }}
      tf-organization: ${{ vars.TF_ORGANIZATION }}
      tf-hostname: ${{ vars.TF_HOSTNAME }}
      tf-workspace: ${{ vars.APP_NAME }}-dev
      aws-region: "us-east-1"
      environment: "dev"
      ref: v1.2.0
      local-execution-mode: true
      setup-python: true
      python-version: "3.11"
    secrets:
      tf-token: ${{ secrets.TF_TOKEN }}
      terraform-execution-iam-plan-role-arn: ${{ secrets.DEV_AWS_PLAN_ROLE_ARN }}
      terraform-execution-iam-apply-role-arn: ${{ secrets.DEV_AWS_APPLY_ROLE_ARN }}
      extra-args: ${{ secrets.DEV_EXTRA_ARGS }}
  deploy-prod:
    needs: deploy-dev
    name: Prod Deployment
    uses: ./terraform-reusable.yml
    with:
      deploy: true
      tf-version: ${{ vars.TF_VERSION }}
      tf-organization: ${{ vars.TF_ORGANIZATION }}
      tf-hostname: ${{ vars.TF_HOSTNAME }}
      tf-workspace: ${{ vars.APP_NAME }}-prod
      aws-region: "us-east-2"
      environment: "prod"
      ref: v1.2.0
      local-execution-mode: true
      setup-python: true
      python-version: "3.11"
    secrets:
      tf-token: ${{ secrets.TF_TOKEN }}
      terraform-execution-iam-plan-role-arn: ${{ secrets.PROD_AWS_PLAN_ROLE_ARN }}
      terraform-execution-iam-apply-role-arn: ${{ secrets.PROD_AWS_APPLY_ROLE_ARN }}
      extra-args: ${{ secrets.PROD_EXTRA_ARGS }}
```

#### (Optional) Sequential Destroy workflow

Create the caller destroy workflow file like in the following example:

```yaml
name: Destroy

permissions:
  id-token: write # This is required for requesting the JWT
  contents: read # This is required for actions/checkout
  pull-requests: write # This is required to add comments to Pull Requests
  deployments: write # This is required to deactivate deployments

on:
  workflow_dispatch:

concurrency:
  group: ${{ github.ref }}
  cancel-in-progress: false

jobs:
  destroy-dev:
    name: Dev Destroy
    uses: ./terraform-reusable.yml
    with:
      deploy: false
      tf-version: ${{ vars.TF_VERSION }}
      tf-organization: ${{ vars.TF_ORGANIZATION }}
      tf-hostname: ${{ vars.TF_HOSTNAME }}
      tf-workspace: ${{ vars.APP_NAME }}-dev
      aws-region: "us-east-1"
      environment: "dev"
      ref: v1.2.0
      local-execution-mode: true
      setup-python: true
      python-version: "3.10"
    secrets:
      tf-token: ${{ secrets.TF_TOKEN }}
      terraform-execution-iam-plan-role-arn: ${{ secrets.DEV_AWS_PLAN_ROLE_ARN }}
      terraform-execution-iam-apply-role-arn: ${{ secrets.DEV_AWS_APPLY_ROLE_ARN }}
      extra-args: ${{ secrets.DEV_EXTRA_ARGS }}
  destroy-prod:
    needs: destroy-dev
    name: Prod Destroy
    uses: ./terraform-reusable.yml
    with:
      deploy: false
      tf-version: ${{ vars.TF_VERSION }}
      tf-organization: ${{ vars.TF_ORGANIZATION }}
      tf-hostname: ${{ vars.TF_HOSTNAME }}
      tf-workspace: ${{ vars.APP_NAME }}-prod
      aws-region: "us-east-2"
      environment: "prod"
      ref: v1.2.0
      local-execution-mode: true
      setup-python: true
      python-version: "3.10"
    secrets:
      tf-token: ${{ secrets.TF_TOKEN }}
      terraform-execution-iam-plan-role-arn: ${{ secrets.PROD_AWS_PLAN_ROLE_ARN }}
      terraform-execution-iam-apply-role-arn: ${{ secrets.PROD_AWS_APPLY_ROLE_ARN }}
      extra-args: ${{ secrets.PROD_EXTRA_ARGS }}
```
