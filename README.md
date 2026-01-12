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
git clone git@github.com:megamattzilla/terraform-examples.git
cd terraform-examples/azure/ubuntu-docker-host
```
### Setup Secrets

### Before running terraform
Set Environment variables for your AWS environment (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN)

Download an F5 Distributed Cloud p12 API certificate and save it to the directory credentials

Set Environment variable for your p12 cerfiticate password (VES_P12_PASSWORD)

