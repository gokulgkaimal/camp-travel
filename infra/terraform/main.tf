locals {
  tags = {
    Project = var.project_name
    Env     = "dev"
    Owner   = "you"
  }
}

# ---------- VPC (public only) ----------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs            = ["${var.region}a", "${var.region}b"]
  public_subnets = [var.public_a_cidr, var.public_b_cidr]

  # ✅ Correct flag for this module version
  map_public_ip_on_launch = true

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  single_nat_gateway   = false

  tags = local.tags
}



# ---------- ECR repos ----------
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags                 = local.tags
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags                 = local.tags
}

# ---------- EKS cluster ----------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name                   = "${var.project_name}-eks"
  cluster_version                = var.eks_version
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.public_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance]
      desired_size   = var.desired_size
      min_size       = var.min_size
      max_size       = var.max_size
      subnets        = module.vpc.public_subnets
    }
  }

  tags = local.tags
}

# ---------- Grant IAM user admin access to EKS ----------
# Registers your IAM user with the cluster
resource "aws_eks_access_entry" "me" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::218435950846:user/gokulgkaimal"
  type          = "STANDARD"
}

# Associates the user with the EKS Cluster Admin managed policy
resource "aws_eks_access_policy_association" "me_admin" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.me.principal_arn

  access_scope {
    type = "cluster"
  }
}



# ---------- Security Group for tools EC2 ----------
resource "aws_security_group" "tools_sg" {
  name        = "${var.project_name}-tools-sg"
  description = "Allow SSH & DevOps tools"
  vpc_id      = module.vpc.vpc_id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten later to your IP
  }

  # Jenkins
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SonarQube
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nexus
  ingress {
    description = "Nexus"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Blackbox exporter
  ingress {
    description = "Blackbox"
    from_port   = 9115
    to_port     = 9115
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins agent
  ingress {
    description = "Jenkins agent"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# ---------- IAM role for tools EC2 (ECR access) ----------
data "aws_iam_policy_document" "tools_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tools_role" {
  name               = "${var.project_name}-tools-role"
  assume_role_policy = data.aws_iam_policy_document.tools_assume.json
  tags               = local.tags
}

# Attach ECR Power User (demo)
resource "aws_iam_role_policy_attachment" "tools_ecr" {
  role       = aws_iam_role.tools_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "tools_profile" {
  name = "${var.project_name}-tools-profile"
  role = aws_iam_role.tools_role.name
}

# ---------- Find a recent Ubuntu 22.04 AMI ----------
data "aws_ami" "ubuntu_2204" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ---------- Tools EC2 instance ----------
resource "aws_instance" "tools" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.tools_instance_type
  key_name                    = var.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tools_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.tools_profile.name

  user_data = <<-EOF
    #!/usr/bin/env bash
    set -e
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release

    # Docker
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker ubuntu
    systemctl enable --now docker

    # Simple folder for tool compose (you'll SCP your files here)
    mkdir -p /opt/tools
    chown -R ubuntu:ubuntu /opt/tools
  EOF

  tags = merge(local.tags, { Name = "${var.project_name}-tools" })
}
