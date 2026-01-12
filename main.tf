# Generate random text for a unique project suffix
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new vpc is defined
    environment_trigger = var.project_prefix
  }

  byte_length = 2
}

# Create AWS VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = format("%s-%s", var.project_prefix, var.aws_vpc)
  cidr = var.aws_cidr

  azs             = var.aws_azs
  public_subnets  = var.aws_public_subnets
  private_subnets = var.aws_private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_support = true
  enable_dns_hostnames = true
}

# SSH key pair for remote access (create and replace "my-key-pair" with your key pair name)
resource "aws_key_pair" "my_key" {
  key_name   = format("%s-my-key-pair-%s", var.project_prefix, random_id.random_id.hex)
  public_key = file("~/.ssh/id_rsa.pub") # Replace with the path of your public key
}

# Security group to allow SSH and HTTP access
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"
  vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_sg.id
  from_port   = 80
  to_port     = 80
  ip_protocol    = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
}

#resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
#  security_group_id = aws_security_group.web_sg.id
#  from_port   = 22
#  to_port     = 22
#  ip_protocol    = "tcp"
#  cidr_ipv4 = "0.0.0.0/0"
#}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Create network interfaces
resource "aws_network_interface" "public" {
  count       = var.aws_server_count
  subnet_id   = element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets)) # Evenly distribute interfaces among public subnets
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "primary_network_interface"
  }
}

# Create elastic IP
resource "aws_eip" "web_eip" {
  count = var.aws_server_count
  domain = "vpc"
  network_interface = aws_network_interface.public[count.index].id
}

# Find the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical owner ID
}

# Create two EC2 instances
resource "aws_instance" "web_servers" {
  count         = var.aws_server_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  
  primary_network_interface {
    network_interface_id = aws_network_interface.public[count.index].id
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "web-server-${count.index + 1}"
  }

  user_data = file("${path.module}/server_config.sh")

  depends_on = [ module.vpc.natgw_ids ]
}

# Create XC DNS Health Monitor 
resource "volterra_dns_lb_health_check" "http_dns_monitor" {
  name      = "${var.project_prefix}-dns-monitor"
  namespace = "system"
  description = "HTTP health monitor for DNS LB"

  http_health_check {
    health_check_port = 80
    send              = "HEAD / HTTP/1.0\r\n\r\n"
    receive           = "HTTP/1."
  }
}

# Create a DNS Load Balancer Pool
resource "volterra_dns_lb_pool" "a_dns_pool" {
  name      = "${var.project_prefix}-dns-pool"
  namespace = "system"
  description = "Pool of backend servers for DNS LB"
  load_balancing_mode = "ROUND_ROBIN"
  ttl = "60"

  a_pool {
    dynamic "members" {
      for_each = aws_eip.web_eip.*.public_ip
      content {
        ip_endpoint = members.value
        priority = 1 # Set appropriate priority
        ratio = 1
        disable = false
      }
    }
    health_check {
          name = volterra_dns_lb_health_check.http_dns_monitor.name
          namespace = "system"
          tenant = var.xc_tenant
        }
    max_answers = 1
  }
  
}

# Create the DNS Load Balancer
resource "volterra_dns_load_balancer" "dns_lb" {
  name        = "${var.project_prefix}-dns-lb"
  namespace   = "system"
  description = "DNS Load Balancer for example.com"
  record_type = "A"
  disable    = false

  # Add the DNS pool to the load balancer configuration
  rule_list{
    rules {
      geo_location_label_selector {
        expressions = ["geoip.ves.io/continet in (NA)"]
      }
      pool {
        name      = volterra_dns_lb_pool.a_dns_pool.name
        namespace = "system"
        tenant = var.xc_tenant
      }
      score = "100"
    } 
  }
}

# Create DNS Zone Record
resource "volterra_dns_zone_record" "lb" {
  dns_zone_name = var.dns_zone_name
  group_name = "terraform"
  rrset {
    description = "description"
    ttl = "60"
    lb_record {
      name = var.dns_hostname
      value {
        tenant = var.xc_tenant
        namespace = "system"
        name = volterra_dns_load_balancer.dns_lb.name
      }
    }
  }
}