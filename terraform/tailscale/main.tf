terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.0"
    }
  }
}

provider "tailscale" {
  oauth_client_id     = var.ts_client_id
  oauth_client_secret = var.ts_client_secret
  tailnet             = var.ts_tailnet
}
