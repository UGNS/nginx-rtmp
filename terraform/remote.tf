data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "undergrid"
    workspaces = {
      name = "vpc-ugns-prod"
    }
  }
}