# terraform/tailscale/tailscale.tf 예시

data "aws_instances" "k3s_nodes" {
  filter {
    name   = "tag:Name"
    values = ["k3s-*"] # AWS 인프라에서 설정한 태그 이름에 맞게 수정
  }
}

resource "tailscale_acl" "main_acl" {
  acl = jsonencode({
    # ... 생략 ...
    acls = [
      {
        action = "accept",
        src    = ["tag:k3s"],
        # 이제 (known after apply)가 아닌 실시간 ID가 들어갑니다.
        dst    = [for id in data.aws_instances.k3s_nodes.ids : "devices:${id}:*"]
      }
    ]
  })
}
