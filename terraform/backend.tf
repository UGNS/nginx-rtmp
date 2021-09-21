terraform {
  backend "remote" {
    organization = "undergrid"

    workspaces {
      name = "nginx-rtmp"
    }
  }
}