
#  Secure Two‑Tier AWS Application Infrastructure

A Terraform-based implementation of a highly available, secure two-tier architecture on AWS.  
This project demonstrates real-world infrastructure as code (IaC) practices and can serve as a portfolio piece for cloud, DevOps, and security roles.

## Project Overview

This repository provisions the following in AWS:

- VPC with public and private subnets
- Internet/NAT Gateways for controlled outbound traffic
- Public & private route tables with proper associations
- Security groups for ALB, application EC2 instances, and database
- Application tier: EC2 Auto Scaling Group using a Launch Template
- Load balancing: Application Load Balancer with target groups and listener
- Database tier: RDS instance with subnet group
- IAM role for EC2 instances
- Elastic IP for NAT gateway 
All resources are defined using Terraform modules and configuration files, allowing repeatable, version‑controlled deployments.

## Repository Structure

00-providers.tf

01-vpc.tf

02-int-gateway.tf

03-public-subnet.tf

04-private-subnet.tf

05-public-route-table.tf

06-publuic-route-table-association.tf

07-elastic-ip.tf

08-nat-gateway.tf

09-private-route-table.tf

10-private-route-table-association.tf

11-alb-sg.tf

12-app-sg.tf

13-db-sg.tf

14-ec2.tf

15-target-groups.tf

16-target-group-attach.tf

17-alb.tf

18-listener.tf

19-launch-template.tf

20-auto-scaling-group.tf

21-db-instance.tf

21-db-subnet-group.tf

22-iam role.tf

variables.tf

terraform.tfstate*

images/
 Each file targets a logical component for clarity and modularity.

---

##  Key Features & Best Practices

- **Security‑first design**: 
  - Database and application instances isolated in private subnets.
  - Fine‑grained security groups to restrict traffic.  

- **Scalability**:
  - Auto Scaling Group paired with a Launch Template.
  - ALB distributes traffic across healthy EC2 instances.

- **Reusability & manageability**:
  - Variables centralized in `variables.tf`.
  - Terraform state files tracked (with remote state recommended for production).

- **Documentation**: Diagrams and screenshots in the `images/` directory to illustrate architecture.

##  Getting Started

1. **Clone the repository**  
   git clone https://github.com/yourusername/Secure-two-tier-aws-application.git
   cd Secure-two-tier-aws-application

2. **Configure AWS credentials**  
   Use environment variables, `~/.aws/credentials`, or an AWS provider block.

3. **Initialize & plan**  
   terraform init
   terraform plan -out=tfplan

4. **Apply**  
     terraform apply tfplan
 
5. **Teardown when done**  
    terraform destroy
  
 *Tip:* Use a remote backend (S3 + DynamoDB) for team collaboration and state locking.



![Two-Tier AWS Architecture](images/architecture.png)

 Check `images/` for additional screenshots and diagrams.
