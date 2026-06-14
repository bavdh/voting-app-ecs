terraform {
  backend "s3" {
    bucket = "voting-app-terraform-state-653236170203"
    key    = "voting-app/bootstrap/terraform.tfstate"
    region = "ap-southeast-1" # value should be hardcoded
  }
}
