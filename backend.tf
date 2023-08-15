terraform {
  backend "s3" {
    bucket = "4392726264355-ecs-fargate-ecr"
    key    = "terraform/teraform.tfstates"
    dynamodb_table = "terraform-lock"
  }
}