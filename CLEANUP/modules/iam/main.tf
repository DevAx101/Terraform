
data "aws_caller_identity" "current" {}

#-------------------------------------------------------------------------------------------------
#IAM Policy to describe EKS Clusters for Developers only
#--------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "dev_generate_kube_config" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "AmazonEKSDevPolicy")
  description = "Allows role to generate kubeconfig for Kubectl access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#-------------------------------------------------------------------------------------------------
#--------- IAM Policy for Admins
#--------------------------------------------------------------------------------------------------
resource "aws_iam_policy" "admin_generate_kube_config" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "AmazonEKSAdminPolicy")
  description = "Allows role to generate kubeconfig for Kubectl access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
#-------------------------------------------------------------------------------------------------
#--------- RBAC Developer IAM role for default tenant; Mapped this role to EKS Cluster
#--------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "rbac-assume-role-policy-devs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# IAM role mapped to EKS CLUSTER as default:developers
resource "aws_iam_role" "cluster_devs_access" {
  name               = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-rbac-devs")
  assume_role_policy = data.aws_iam_policy_document.rbac-assume-role-policy-devs.json
}

# Allows developers to describe/list clusters
resource "aws_iam_role_policy_attachment" "dev" {
  role       = aws_iam_role.cluster_devs_access.name
  policy_arn = aws_iam_policy.dev_generate_kube_config.arn
}

# EKS IAM Group for developers.
resource "aws_iam_group" "eks_developers_group" {
  name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-dev-group")
}

# Policy data for eks_developers group making use of IAM admin role
data "aws_iam_policy_document" "eks_developers_policy" {
  statement {
    sid = "AllowAssumeOrganizationAccountRole"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${var.account_id}:role/${aws_iam_role.cluster_devs_access.name}"
    ]
  }
}

# iam policy for developers group
resource "aws_iam_policy" "eks_developers_policy" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-dev-policy")
  description = "Required for eks rbac"
  policy      = data.aws_iam_policy_document.eks_developers_policy.json
}


#iam group policy attachment for developers.
resource "aws_iam_group_policy_attachment" "eks_developers_policy_attachement" {
  group      = aws_iam_group.eks_developers_group.name
  policy_arn = aws_iam_policy.eks_developers_policy.arn
}

#-------------------------------------------------------------------------------------------------
#RBAC Admin IAM role; Mapped this role to EKS Cluster
#--------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "rbac-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

# IAM Role mapped to EKS Cluster
resource "aws_iam_role" "cluster_admin_access" {
  name               = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-rbac-admin")
  assume_role_policy = data.aws_iam_policy_document.rbac-assume-role-policy.json

}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.cluster_admin_access.name
  policy_arn = aws_iam_policy.admin_generate_kube_config.arn
}

resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_admin_access.name
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster_admin_access.name
}
resource "aws_iam_role_policy_attachment" "eks_kubectl-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cluster_admin_access.name
}

# IAM Group for EKS Admins
resource "aws_iam_group" "eks_admins_group" {
  name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-admin-group")
}

#Data resource for Attach EKS Mapped IAM ROLE to the IAM Group
data "aws_iam_policy_document" "eks_admins_group_policy" {
  statement {
    sid = "AllowAssumeOrganizationAccountRole"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "arn:aws:iam::${var.account_id}:role/${aws_iam_role.cluster_admin_access.name}"
    ]
  }
}


# Attach EKS Mapped IAM ROLE to the IAM Group
resource "aws_iam_policy" "eks_admins_policy" {
  name        = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-admin-policy")
  description = "Required for eks rbac"
  policy      = data.aws_iam_policy_document.eks_admins_group_policy.json
}

#iam group policy attachment for admins.
resource "aws_iam_group_policy_attachment" "eks_admins_group_policy" {
  group      = aws_iam_group.eks_admins_group.name
  policy_arn = aws_iam_policy.eks_admins_policy.arn
}
//#-------------------------------------------------------------------------------------------------
//#--------- IAM Policy for Cluster autoscalar Deployment; Policy added to eks module
//#--------------------------------------------------------------------------------------------------
//resource "aws_iam_policy" "eks-autoscaler-policy" {
//  name        = "eks-autoscaler-policy"
//  path        = "/"
//  description = "eks autoscaler policy"
//
//  policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Action": [
//        "autoscaling:DescribeAutoScalingGroups",
//        "autoscaling:DescribeAutoScalingInstances",
//        "autoscaling:DescribeLaunchConfigurations",
//        "autoscaling:DescribeTags",
//        "autoscaling:SetDesiredCapacity",
//        "autoscaling:TerminateInstanceInAutoScalingGroup"
//      ],
//      "Resource": "*"
//    }
//  ]
//}
//EOF
//}
#------------------------------------------------------------------------------------------
# Create IAM User and attach user to EKS Admins IAM Group
# Please note that this can be done outside the module so that you can provision more users in future
#------------------------------------------------------------------------------------------
# IAM Admin user for EKS
resource "aws_iam_user" "eks_admin" {
  name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-admin1")
}

#adding admin user to the group.
resource "aws_iam_group_membership" "eks_admins_group_membership" {
  name = "eks_admin_group_membership"

  users = [
    aws_iam_user.eks_admin.name
  ]

  group = aws_iam_group.eks_admins_group.name
}
#------------------------------------------------------------------------------------------
# Create IAM User and attach user to EKS Developers IAM Group
# Please note that this can be done outside the module so that you can provison more users in future
#------------------------------------------------------------------------------------------
resource "aws_iam_user" "eks_developer" {
  name = format("%s-%s-%s-%s", var.tenant, var.environment, var.zone, "eks-dev1")
}

#eks developers group membership
resource "aws_iam_group_membership" "eks_developers_group_membership" {
  name = "eks_developers_group_membership"

  users = [
    aws_iam_user.eks_developer.name
  ]

  group = aws_iam_group.eks_developers_group.name
}
#------------------------------------------------------------------------------------------


