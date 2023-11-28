#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

function _logger() {
    echo -e "$(date) ${YELLOW}[*] $@ ${NC}"
}

source ./.env
param=${1:--env=dev}
parsed=(${param//=/ })
env=$(echo ${parsed[1]})
env=${env:-dev}
TF_ENV="./environment/$env"
source ${TF_ENV}/.env

echo
echo "#########################################################"
echo "Verify the environment"
echo "#########################################################"
echo
kubectl version --short --client
helm version
echo $(aws sts get-caller-identity)


started_time=$(date '+%d/%m/%Y %H:%M:%S')
echo
echo "#########################################################"
echo "Infrastructure Provisioning started at ${started_time}"
echo "#########################################################"
echo

echo
echo "#########################################################"
_logger "[+] 1. Create S3 Bucket with Versioning Enabled to store Terraform State files & locks ..."
echo "#########################################################"
echo

echo "TF_STATE_S3_BUCKET=${TF_STATE_S3_BUCKET} + AWS_REGION=${AWS_REGION}"
## Note: us-east-1 does not require a `location-constraint`:
aws s3api create-bucket --bucket ${TF_STATE_S3_BUCKET} --region ${AWS_REGION} --create-bucket-configuration \
    LocationConstraint=${AWS_REGION} 2>/dev/null || true
aws s3api put-bucket-versioning --bucket ${TF_STATE_S3_BUCKET} --versioning-configuration Status=Enabled 2>/dev/null || true

echo
echo "#########################################################"
_logger "[+] 2.1. [Networking] Provisioning Modern-VPC Stack: teraform/stacks/vpc-*/variables.tf"
_logger "2.1.1. Standard VPC >> Public/Private Subnet"
_logger "2.1.2. Private  VPC >> Private Subnet Only"
_logger "2.1.3. Advanced VPC >> Public/Private/Database/Cache Subnet, Flow Log, VPC Endpoint S3"
echo "#########################################################"
echo
vpc_options=("Standard VPC" "Private VPC" "Advanced VPC - Flow Log to S3" "Advanced VPC - Flow Log to CloudWatch")
PS3='Please enter your choice: '
select opt in "${vpc_options[@]}"
do
    case $REPLY in
        1)
        echo "Provisioning $opt..."
        # export TF_VAR_vpc_name="CICD-VPC"
        export TF_VAR_vpc_type=$VPC_TYPE_STANDARD
        cd ${WORKING_DIR}/modules/vpc
        ;;
        2)
        echo "Provisioning $opt..."
        # export TF_VAR_vpc_name="EKS-VPC"
        export TF_VAR_vpc_type=$VPC_TYPE_PRIVATE
        cd ${WORKING_DIR}/modules/vpc-private
        ;;
        3)
        echo "Provisioning $opt..."
        # export TF_VAR_vpc_name="EKS-Prod-VPC"
        export TF_VAR_vpc_type=$VPC_TYPE_ADVANCED
        cd ${WORKING_DIR}/modules/vpc-advanced
        ;;
        4)
        echo "Provisioning $opt..."
        export TF_VAR_vpc_type=$VPC_TYPE_ADVANCED
        export TF_VAR_vpc_flow_log_destination="cloud-watch-logs"
        cd ${WORKING_DIR}/modules/vpc-advanced
        ;;
    esac
    break
done

terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-vpc-stack.tfstate" && \
terraform plan -out tfplan && \
# terraform show tfplan && \
terraform apply -input=false -auto-approve tfplan


echo
echo "#########################################################"
_logger "[+] 2.2. VPC Interface/Gateway Endpoints"
echo "#########################################################"
echo
cd ${WORKING_DIR}/modules/vpc-endpoint
terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-vpc-endpoint.tfstate" && \
terraform plan -out tfplan && \
# terraform show tfplan && \
terraform apply -input=false -auto-approve tfplan


echo
echo "#########################################################"
_logger "[+] 2.3. VPC Peering: modules/vpc-peering"
echo " [DevTest]      AWS-Account1-VPC1: CI/CD Pipeline - Code*, Jenkins, GitLab
echo " [Staging/Prod] AWS-Account2-VPC2: EKS Cluster Staging/Prod
echo "#########################################################"
echo

cd  ${WORKING_DIR}/modules/vpc-peering &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-vpc-peering.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan


echo
echo "#########################################################"
_logger "[+] 2.4. Provisioning EFS Stack: teraform/stacks/efs/terraform.tfvars"
echo "#########################################################"
echo

cd  ${WORKING_DIR}/modules/efs &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-efs-${TF_VAR_vpc_name}.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan


echo
echo "#########################################################"
_logger "[+] 2.5. AWS EC2 Image Builder Pipeline: teraform/stacks/ec2-image-builder/terraform.tfvars"
echo "#########################################################"
echo

export TF_VAR_ec2_image_builder_component_file="../../environment/$env/ec2-component.yml"

cd  ${WORKING_DIR}/modules/ec2-image-builder &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-ec2-image-builder.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

echo
echo "#########################################################"
_logger "[+] 3. AWS EKS"
echo "#########################################################"
echo
cd  ${WORKING_DIR}/modules/eks-cluster &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-eks-cluster.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

echo
echo "#########################################################"
_logger "[+] 4. Metrics Server"
echo "#########################################################"
echo
cd  ${WORKING_DIR}/modules/metrics-server &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-metrics-server.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

echo
echo "#########################################################"
_logger "[+] 5. Cluster Autoscaler"
echo "#########################################################"
echo
cd  ${WORKING_DIR}/modules/autoscaler &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-cluster-autoscaler.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

echo
echo "#########################################################"
_logger "[+] 6. Node Termination Handler"
echo "#########################################################"
echo
cd  ${WORKING_DIR}/modules/node-termination-handler &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-node-termination-handler.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

echo
echo "#########################################################"
_logger "[+] 7. AWS ALB"
echo "#########################################################"
echo
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
cd  ${WORKING_DIR}/modules/alb &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-alb.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

echo
echo "#########################################################"
_logger "[+] 8. AWS NLB"
echo "#########################################################"
echo
cd  ${WORKING_DIR}/modules/nlb &&           \
    terraform init -reconfigure -backend-config="region=${AWS_REGION}" -backend-config="bucket=${TF_STATE_S3_BUCKET}" -backend-config="key=${PROJECT_ID}-nlb.tfstate"
    terraform plan -out tfplan &&  \
    terraform apply -input=false -auto-approve tfplan

ended_time=$(date '+%d/%m/%Y %H:%M:%S')
echo
echo "#########################################################"
echo -e "${RED} Infrastructure Provisioning ended at ${ended_time} - ${started_time} ${NC}"
