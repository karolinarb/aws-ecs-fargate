provider "aws" {
  region = "eu-west-2"
}


resource "aws_ecr_repository" "static_web_ecr_repo" {
  name = "${var.project}-repo"
}

resource "aws_ecr_repository_policy" "static_web_ecr_repo-policy" {
  repository = aws_ecr_repository.static_web_ecr_repo.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "null_resource" "build_push_dkr_img" {

  provisioner "local-exec" {
    command =  "bash ./dockercmd.sh"
  }
  depends_on = [aws_ecr_repository.static_web_ecr_repo]
} 