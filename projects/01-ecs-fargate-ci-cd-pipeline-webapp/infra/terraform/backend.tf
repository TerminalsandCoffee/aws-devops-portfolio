terraform {
  backend "s3" {
    bucket         = "terraform-state-portfolio-01"
    key            = "projects/01-ecs-fargate/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
