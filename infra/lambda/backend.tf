terraform {
  backend "s3" {
    bucket  = "s3-backend-remote1"
    key     = "lambda/terraform.tfstate"
    region  = "us-east-1"   # ✅ MUST match bucket region
    encrypt = true
  }
}
