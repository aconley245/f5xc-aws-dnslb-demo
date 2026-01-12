# Output the VPC ID and Subnet IDs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

# Output server public IPs
output "web_server_public_ips" {
  value = aws_eip.web_eip.*.public_ip
}