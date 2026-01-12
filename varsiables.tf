variable "project_prefix" {
    ## String to prepend to created objects
    type = string
    default = "my-project"
}

variable "aws_region" {
    ## AWS Region to create objects in
    type = string
    default = "us-west-1"
}

variable "aws_owner" {
    ## AWS Owner for created objects
    type = string
    default = "my.user@email.com"
}

variable "aws_environment" {
    ## AWS environment
    type = string
    default = "Non-Prod"
}

variable "aws_vpc" {
  ## AWS VPC name
  type = string
  default = "vpc"
}

variable "aws_cidr" {
  ## AWS CIDR block to use for the VPC
  type = string
  default = "10.0.0.0/16"
}

variable "aws_azs" {
    ## AWS availability zones
    type = list(string)
    default = ["us-west-1a", "us-west-1c"]
}

variable "aws_public_subnets" {
    ## AWS public subnets
    type = list(string)
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_private_subnets" {
    ## AWS public subnets
    type = list(string)
    default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "aws_server_count" {
    ## Number of servers to create
    type = number
    default = 2
}

variable "xc_api_p12_file" {
  description = "Path to the F5XC API certificate file"
  type        = string
}

variable "xc_tenant" {
  description = "XC Tenant full name"
  type        = string
}

variable "xc_api_url" {
  description = "F5XC API URL (e.g., https://<tenant>.console.ves.volterra.io/api)"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the DNS load balancer (must be managed in F5XC)"
  type        = string
  default     = "example.com"
}

variable "xc_lb_method" {
    description = "The DNS loab balancing method to use options are: ROUND_ROBIN, RATIO_MEMBER, STATIC_PERSIST, PRIORITY"
    type = string
}

variable "backend_ips" {
  description = "List of backend server IP addresses"
  type        = list(string)
  default     = ["10.0.1.10", "10.0.1.11"]
}

variable "dns_zone_name" {
  default = "Name of DNS zone"
  type = string
}

variable "dns_hostname" {
  description = "DNS hostname without the domain"
  type = string
}