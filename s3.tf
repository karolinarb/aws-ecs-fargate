resource "aws_s3_bucket" "mythical_bucket" {
  bucket = "mythical-bucket-439272626435"
  acl = "public-read"
  policy = data.aws_iam_policy_document.website_policy.json
  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    name = var.project
  }
}

data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    resources = [
      "arn:aws:s3:::mythical-bucket-439272626435/*"
    ]
  }
}