provider "aws"{
    region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "4392726264355-ecs-fargate"
    key    = "terraform/teraform.tfstates"
    dynamodb_table = "terraform-lock"
  }
}