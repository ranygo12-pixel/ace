
#Tailscale key 추가 설정
variable "ts_client_id" {
  type      = string
  sensitive = true
}

variable "ts_client_secret" {
  type      = string
  sensitive = true
}

variable "ts_tailnet" { 
  type = string 
}
