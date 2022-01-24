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

- (WIP)
- 

## Properties

This architecture has been designed to provide the following properties:
- (WIP)
- 

### Spot instances

Note, this EKS cluster is configured to use Spot Instances, to save up to 90% vs. On-Demand prices.

This cost saving comes with the acceptance that nodes may be interrupted by AWS at any time with a two-minute warning before instances are terminated.

These interruptions are handled by the AWS Node Termination Handler, providing a connection between termination requests from AWS to Kubernetes nodes. This allows us to gracefully drain nodes before termination.

## First-Time Terraform Bootstrap

If you're using terraform for the first time in a clean AWS account, or have no existing S3 bucket for terraform state, you'll need to provision the terraform state S3 bucket and DynamoDB table before using the main module.

- Choose a globally unique name for the S3 bucket, e.g. <AWS account alias>-terraform-state
- Insert your chosen bucket name in the `terraform_state_bucket_name` variable in `remote-tfstate/variables.tf`
- Insert your chosen bucket name in the `backend "s3" -> bucket` config line in `main.tf`
- `cd remote-tfstate`
- `tf init`
- `tf apply`

## Creation of primary resources

Run terraform:
```
terraform init
terraform apply
```

You can use the `-var-file` option to pass in customized parameters to terraform plan/apply:
```
terraform plan -var-file default.tfvars
terraform apply -var-file default.tfvars
```

## Clean up
Run terraform:
```
terraform destroy
```

Again, use the `-var-file` option to pass in customized parameters to terraform destroy:
```
terraform destroy -var-file default.tfvars
```

## ⚠️ Warning: Terraform state file!

The Terraform state file is critical to you being able to reliably modify or delete these resources, and contains secrets (e.g. the plaintext database password).

This Terraform module is currently configured to output that state file to the default location, which is `terraform.tfstate` in the current working directory.

Ideally this state file should be stored and updated in a secure location, such as a carefully restricted S3 bucket using the S3 backend for 

