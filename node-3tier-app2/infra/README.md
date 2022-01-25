# Node 3tier App infrastructure 

This directory contains [Terraform](https://www.terraform.io) config files (_Infrastructure as Code_) to provision the production infrastructure components to run this app.

The components provisioned include:
- **AWS VPC**: Contains the remaining resources and provide separation of concerns in the AWS account
  - **Internet Gateway**: Allows internet traffic to enter into the VPC via a public IP address.
  - **Elastic IP Address**: Provisions a public IP address to route to this VPC.
  - **NAT Gateway**: Allows resources in a private subnet to connect to the Internet while rewriting the internal IP addresses to a single public Elastic IP for return traffic. 
  - **Subnets**: As per the [EKS VPC docs](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html), we create both public and private subnets so that Kubernetes can create public load balancers in the public subnets that load balance traffic to pods running on nodes that are in private subnets.
  - **Routing Tables, Routes & Associations**:
    - Public: All traffic from anywhere on the internet is routed to the Internet Gateway.
    - Private: Traffic from the private subnets to the internet is routed through the NAT gateway.
  - **Flow Logs**: Log all network traffic to and from the VPC; valuable for a range of security, compliance and investigative requirements.
    - Cloudwatch Log Group: Define a log group and retention period.
    - IAM Role & Policy: Allow flow logs to publish directly to CloudWatch Logs.


- **EKS**: Kubernetes cluster to run the application in, providing capabilities which enable the properties listed further down.
  - **EKS Cluster IAM Role & Policies**: Allows the EKS cluster and Fargate pods to make AWS API calls to manage resources
  - **EKS Cluster IAM Policy CloudWatch**: Allow EKS cluster to publish metric data to CloudWatch
  - **EKS Cluster IAM Policy NLB**: Allow EKS cluster to create network load balancers and security groups
  - **CloudWatch Log Group**: Creates a place to store logs from the kubernetes cluster
  - **EKS Cluster**: Control plane for the Kubernetes cluster
  - **IAM OIDC provider**: [Required](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) to use IAM roles for service accounts
  - **EKS Node Group IAM Role & Policies**: Allows EKS node kubelet daemon to make AWS API calls to manage resources
  - **EKS Node Group**: To automate the provisioning and lifecycle management of EC2 instances as Kubernetes worker nodes
  - **Fargate Pod Execution Role & Policy**: Allows running pods on AWS Fargate
  - **Fargate Profile**: Specifies which pods use Fargate when launched

## Properties

This architecture has been designed to provide the following properties:
- (WIP)

## ⚠️ Note: First-Time Terraform Bootstrap

If you're using terraform for the first time in a clean AWS account, or have no existing S3 bucket for terraform state, you'll need to provision the terraform state S3 bucket and DynamoDB table before using the main module.

- Choose a globally unique name for the S3 bucket, e.g. <AWS account alias>-terraform-state
- Insert your chosen bucket name in the `terraform_state_bucket_name` variable in `remote-tfstate/variables.tf`
- Insert your chosen bucket name in the `backend "s3" -> bucket` config line in `main.tf`
- `cd remote-tfstate`
- `tf init`
- `tf apply`

If you're using this module in an AWS account which has an existing terraform state bucket and DynamoDB lock table:
- Edit the `backend "s3"` config section in `main.tf`, updating `bucket`, `region` and `dynamodb_table` values to match your existing state location.

## Creation of primary resources
- `terraform init`
- `terraform apply`

You can then generate a `kubeconfig` file, allowing you to run kubectl commands locally against the provisioned Kubernetes cluster:
- `aws eks update-kubeconfig --region us-east-1 --name <cluster-name>`

## Destroy / clean up all resources 
- `terraform destroy`
