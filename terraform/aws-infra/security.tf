# =====================================================
# 1. Server 보안 그룹 (Public Subnet)
# =====================================================
resource "aws_security_group" "server_sg" {
  name        = "server-sg"
  description = "Security group for K3s Server"
  vpc_id      = aws_vpc.main.id

  # SSH 접속 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH Access"
  }

  # K3s API 서버 (외부 kubectl 제어용)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow K3s API Server"
  }

  # Nginx NodePort 접속 허용
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Nginx NodePort Access"
  }

  # Grafana 대시보드 접속 허용
  ingress {
    from_port   = 32000
    to_port     = 32000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Grafana Dashboard Access"
  }

  # Tailscale 직접 연결 (P2P)을 위한 UDP 포트
  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Tailscale UDP port for direct connection"
  }

  # 프라이빗 서브넷(Agent)에서 오는 모든 트래픽 허용
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.private.cidr_block]
    description = "Allow all traffic from Private Subnet"
  }

  # 모든 외부 출력 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# =====================================================
# 2. Agent 보안 그룹 (Private Subnet)
# =====================================================
resource "aws_security_group" "agent_sg" {
  name        = "agent-sg"
  description = "Security group for K3s Agents"
  vpc_id      = aws_vpc.main.id

  # Server(Public)로부터의 내부 통신 허용
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_subnet.public.cidr_block]
    description = "Allow all traffic from Public Subnet"
  }

  # Nginx NodePort 접속 허용
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Nginx NodePort Access"
  }

  # [추가] Agent 노드들도 Tailscale 직접 연결을 위해 UDP 포트 필요
  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Tailscale UDP port for direct connection"
  }

  # 모든 외부 출력 허용 (NAT Gateway 등을 통해 나감)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# =====================================================
# 3. SG Peering: 노드 간 상호 통신 규칙
# =====================================================

# Server <- Agent: 모든 포트 허용
resource "aws_security_group_rule" "allow_agent_to_server" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.server_sg.id
  source_security_group_id = aws_security_group.agent_sg.id
  description              = "Allow all ingress from Agent SG"
}

# Agent <- Server: 모든 포트 허용
resource "aws_security_group_rule" "allow_server_to_agent" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.agent_sg.id
  source_security_group_id = aws_security_group.server_sg.id
  description              = "Allow all ingress from Server SG"
}
