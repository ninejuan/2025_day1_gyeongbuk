terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  default_tags {
    tags = local.common_tags
  }
}
data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  token                  = data.aws_eks_cluster_auth.main.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

module "hub_vpc" {
  source = "./modules/vpc"

  vpc_name = "skills-hub-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  public_subnets = {
    "skills-hub-subnet-a" = { cidr = "10.0.0.0/24", az = "a" }
    "skills-hub-subnet-b" = { cidr = "10.0.1.0/24", az = "b" }
  }
  
  inspection_subnets = {
    "skills-inspect-subnet-a" = { cidr = "10.0.2.0/24", az = "a" }
    "skills-inspect-subnet-b" = { cidr = "10.0.3.0/24", az = "b" }
  }



  environment = var.environment
  project     = var.project
}

module "app_vpc" {
  source = "./modules/vpc"

  vpc_name = "skills-app-vpc"
  vpc_cidr = "192.168.0.0/16"
  
  public_subnets = {
    "skills-app-subnet-a" = { cidr = "192.168.0.0/24", az = "a" }
    "skills-app-subnet-b" = { cidr = "192.168.1.0/24", az = "b" }
  }
  
  workload_subnets = {
    "skills-workload-subnet-a" = { cidr = "192.168.2.0/24", az = "a" }
    "skills-workload-subnet-b" = { cidr = "192.168.3.0/24", az = "b" }
  }
  
  db_subnets = {
    "skills-db-subnet-a" = { cidr = "192.168.4.0/24", az = "a" }
    "skills-db-subnet-b" = { cidr = "192.168.5.0/24", az = "b" }
  }

  create_nat_gateway = true

  environment = var.environment
  project     = var.project
}

module "vpc_peering" {
  source = "./modules/vpc_peering"

  hub_vpc_id = module.hub_vpc.vpc_id
  app_vpc_id = module.app_vpc.vpc_id
  
  hub_vpc_cidr = module.hub_vpc.vpc_cidr
  app_vpc_cidr = module.app_vpc.vpc_cidr
  
  hub_route_table_ids = [
    module.hub_vpc.inspection_route_table_id,
    module.hub_vpc.public_az_a_route_table_id,
    module.hub_vpc.public_az_b_route_table_id
  ]
  app_route_table_ids = [
    module.app_vpc.public_route_table_id,
    module.app_vpc.private_route_table_id
  ]
  
  peering_name = "skills-peering"
  
  environment = var.environment
  project     = var.project
}

module "network_firewall" {
  source = "./modules/network_firewall"

  vpc_id = module.hub_vpc.vpc_id
  
  inspection_subnet_ids = module.hub_vpc.inspection_subnet_ids
  public_subnet_ids     = module.hub_vpc.public_subnet_ids
  internet_gateway_id   = module.hub_vpc.internet_gateway_id
  
  firewall_name = "skills-firewall"
  policy_name   = "skills-firewall-policy"
  
  environment = var.environment
  project     = var.project
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id = module.hub_vpc.vpc_id
  subnet_id = module.hub_vpc.public_subnet_ids[0]
  
  instance_name = "skills-bastion"
  instance_type = "t3.small"
  
  security_group_name = "skills-bastion-sg"
  iam_role_name      = "skills-bastion-role"
  
  login_password = "Skill53##"
  ssh_port       = 2025
  
  environment = var.environment
  project     = var.project
}

# module "secrets" {
#   source = "./modules/secrets"

#   secret_name = "skills-secrets"
  
#   secrets = {
#     DB_USER   = "admin"
#     DB_PASSWD = "Skill53##"
#     DB_URL    = module.rds.cluster_endpoint
#   }
  
#   environment = var.environment
#   project     = var.project
# }

module "rds" {
  source = "./modules/rds"

  vpc_id = module.app_vpc.vpc_id
  subnet_ids = module.app_vpc.db_subnet_ids
  
  cluster_name = "skills-db-cluster"
  db_name      = "day1"
  
  master_username = "admin"
  master_password = "Skill53##"
  
  instance_class = "db.t3.medium"
  
  environment = var.environment
  project     = var.project
}

module "s3" {
  source = "./modules/s3"

  bucket_name = "skills-chart-bucket-sija"
  
  environment = var.environment
  project     = var.project
}

module "ecr" {
  source = "./modules/ecr"

  repositories = {
    "skills-green-repo" = {}
    "skills-red-repo"   = {}
  }
  
  environment = var.environment
  project     = var.project
  aws_region  = var.aws_region

  build_contexts = {
    "skills-green-repo" = "${path.root}/app-files/docker/1.0.0/green"
    "skills-red-repo"   = "${path.root}/app-files/docker/1.0.0/red"
  }

  image_tag = "v1.0.0"
}

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id = module.app_vpc.vpc_id
  subnet_ids = module.app_vpc.workload_subnet_ids
  
  project = var.project
  
  depends_on = [module.eks]
}

module "eks" {
  source = "./modules/eks"

  vpc_id = module.app_vpc.vpc_id
  
  workload_subnet_ids = module.app_vpc.workload_subnet_ids
  public_subnet_ids   = module.app_vpc.public_subnet_ids
  
  cluster_name    = "skills-eks-cluster"
  cluster_version = "1.32"
  
  app_nodegroup_name = "skills-app-nodegroup"
  app_instance_type  = "t3.medium"
  
  addon_nodegroup_name = "skills-addon-nodegroup"
  addon_instance_type  = "t3.medium"
  
  fargate_profile_name = "skills-fargate-profile"
  
  environment = var.environment
  project     = var.project


}



module "load_balancers" {
  source = "./modules/load_balancers"

  hub_vpc_id = module.hub_vpc.vpc_id
  app_vpc_id = module.app_vpc.vpc_id
  
  hub_public_subnet_ids = module.hub_vpc.public_subnet_ids
  app_workload_subnet_ids = module.app_vpc.workload_subnet_ids
  
  environment = var.environment
  project     = var.project
  
  depends_on = [module.eks, module.vpc_endpoints]
}

module "opensearch" {
  source = "./modules/opensearch"

  domain_name = "skills-opensearch"
  engine_version = "OpenSearch_2.19"
  
  data_node_instance_type = "r7g.medium.search"
  data_node_count         = 2
  master_node_count       = 3
  
  master_username = "admin"
  master_password = "Skill53##"
  
  depends_on = [module.eks]
  
  environment = var.environment
  project     = var.project
}

module "monitoring" {
  source = "./modules/monitoring"

  cluster_name = module.eks.cluster_name
  
  depends_on = [module.eks]
  
  environment = var.environment
  project     = var.project
} 