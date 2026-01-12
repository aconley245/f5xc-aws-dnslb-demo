# Deploy n-number Ubuntu servers with NGINX in AWS along with F5 XC DNS Load Balancers

## Overview

This is example code for deploying Ubuntu servers running NGINX along with a F5 Distributed Cloud
DNS Load Balancer to distribute traffic between the web servers.

### Requirements:  
- Have a linux machine with terraform installed. 
- Active AWS cloud subscription
- Active F5 Tenant

### Clone Repo
```bash
git clone https://github.com/aconley245/f5xc-aws-dnslb-demo.git
```

### Before running terraform
Set Environment variables for your AWS environment (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN)

Download an F5 Distributed Cloud p12 API certificate and save it to a directory accessible by Terraform

Set Environment variable for your p12 cerfiticate password (VES_P12_PASSWORD)

### Run Terraform

Review variables in `variables.tf` and customize as needed.
- project_prefix: String to prepend to created objects
- aws_region: AWS Region to create objects in
- aws_owner: AWS Owner tag for created objects
- aws_environment: AWS environment tag
- aws_vpc: AWS VPC name
- aws_cidr: AWS CIDR block to use for the VPC
- aws_azs: AWS availability zones
- aws_public_subnets: AWS public subnets
- aws_private_subnets: AWS public subnets
- aws_server_count: Number of servers to create
- xc_api_p12_file: Path to the F5XC API certificate file
- xc_tenant: XC Tenant full name
- xc_api_url: F5XC API URL (e.g., https://<tenant>.console.ves.volterra.io/api)
- xc_lb_method: The DNS loab balancing method to use options are: ROUND_ROBIN, RATIO_MEMBER, STATIC_PERSIST, PRIORITY
- dns_zone_name: Name of DNS zone to create LB record in
- dns_hostname: DNS hostname for LB record without the domain suffix


Initalize providers
```bash
terraform init
```

Apply the changes
```bash
terraform apply
```

Delete everything:
```bash
terraform destroy
```