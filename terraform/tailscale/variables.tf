terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Providers 설정
provider "tailscale" {
  oauth_client_id     = var.ts_client_id
  oauth_client_secret = var.ts_client_secret
  tailnet             = var.ts_tailnet
}

provider "aws" {
  region = "ap-northeast-2" # 실제 사용하시는 리전
}

# 2. AWS 데이터 조회 (중복 없이 여기서 딱 한 번만 실행)
data "aws_instances" "k3s_nodes" {
  filter {
    name   = "tag:Name"
    values = ["k3s-*"] 
  }
  instance_state_names = ["running"]
}

# 3. Tailscale ACL 설정
resource "tailscale_acl" "main_acl" {
  acl = jsonencode({
    tagOwners = {
      "tag:k3s" = ["group:admin"]
    },
    acls = [
      {
        action = "accept",
        src    = ["tag:k3s"],
        # 실시간으로 조회된 AWS 인스턴스 ID 주입
        dst    = [for id in data.aws_instances.k3s_nodes.ids : "devices:${id}:*"]
      }
    ]
  })
}
