# terraform/tailscale/main.tf

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

provider "tailscale" {
  oauth_client_id     = var.ts_client_id
  oauth_client_secret = var.ts_client_secret
  tailnet             = var.ts_tailnet
}

provider "aws" {
  region = "ap-northeast-2"
}

# 1. AWS 데이터 조회 (이건 그대로 두세요)
data "aws_instances" "k3s_nodes" {
  filter {
    name   = "tag:Name"
    values = ["k3s-*"] 
  }
  instance_state_names = ["running"]
}

# 2. Tailscale ACL 설정 (여기를 수정합니다)
resource "tailscale_acl" "main_acl" {
  acl = jsonencode({
    # [수정] group:admin이 정의되지 않아 400 에러가 났었습니다.
    # 본인의 Tailscale 계정 이메일을 넣어주세요.
    groups = {
      "group:admin" = ["your-email@example.com"] 
    },
    
    tagOwners = { "tag:k3s" = ["group:admin"] },
    
    acls = [
      {
        action = "accept",
        src    = ["tag:k3s"],
        # [수정] 콜론(:) 문제를 해결한 표준 태그 문법입니다.
        dst    = ["tag:k3s:*"]
      }
    ]
  })
}
