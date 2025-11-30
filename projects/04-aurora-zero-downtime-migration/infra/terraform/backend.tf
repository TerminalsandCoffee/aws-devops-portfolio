terraform {
  backend "s3" {
    bucket         = "terraform-state-portfolio-01"
    key            = "projects/04-aurora/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
