resource "tailscale_acl" "main_acl" {
  acl = jsonencode({
    # 태그 소유권 설정 (GHA와 서버에 부여할 권한)
    tagOwners = {
      "tag:k3s" = ["group:admin"]
    },
    # 접근 제어 규칙: k3s 태그 노드끼리, 그리고 GHA(tag:k3s)와의 통신 허용
    acls = [
      {
        "action" = "accept",
        "src"    = ["tag:k3s"],
        "dst"    = ["tag:k3s:*"]
      }
    ]
  })
}
