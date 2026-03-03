# =====================================================
# Tailscale API 인증 및 설정을 위한 변수
# =====================================================

# Tailscale OAuth Client ID
variable "ts_client_id" {
  type        = string
  description = "Tailscale OAuth Client ID"
  sensitive   = true
}

# Tailscale OAuth Client Secret
variable "ts_client_secret" {
  type        = string
  description = "Tailscale OAuth Client Secret"
  sensitive   = true
}

# Tailscale Tailnet 이름 (예: your-email@gmail.com)
variable "ts_tailnet" {
  type        = string
  description = "Tailscale Tailnet name"
}

# =====================================================
# 노드 및 보안 그룹 관련 변수
# =====================================================

# K3s 노드들에 부여할 Tailscale 태그
variable "tailscale_tags" {
  type        = list(string)
  default     = ["tag:k3s"]
  description = "Tags to be applied to the K3s nodes"
}
