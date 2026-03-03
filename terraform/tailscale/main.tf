# =====================================================
# 1. 테라폼 및 프로바이더 설정 (중복 방지를 위해 이곳에만 정의)
# =====================================================
terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.0"
    }
  }
}

provider "tailscale" {
  api_key = var.ts_client_secret 
  tailnet = var.ts_tailnet
}

# =====================================================
# 2. Tailscale ACL 설정 (보안 및 접속 권한)
# =====================================================
resource "tailscale_acl" "main" {
  acl = jsonencode({
    # 1) 그룹 정의 (관리자 그룹)
    groups = {
      "group:admin" = ["your-email@gmail.com"] # 본인의 Tailscale 계정 이메일
    },

    # 2) 태그 정의 (K3s 노드용)
    tagOwners = {
      "tag:k3s" = ["group:admin"]
    },

    # 3) 접속 규칙 (ACL)
    acls = [
      {
        "action": "accept",
        "src":    ["group:admin", "tag:k3s"],
        "dst":    ["*:*"]
      }
    ],

    # 4) Tailscale SSH 설정 (중요: 이걸 해야 패스워드 없이 SSH 가능)
    ssh = [
      {
        "action": "check",
        "src":    ["group:admin"],
        "dst":    ["tag:k3s"],
        "users":  ["ubuntu", "root"]
      }
    ]
  })
}
