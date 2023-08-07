resource "aws_dynamodb_table" "ecr_fargate" {
  name           = "ecr_fargate"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "MysfitId"

  attribute {
    name = "MysfitId"
    type = "S"
  }

  attribute {
    name = "GoodEvil"
    type = "S"
  }

  attribute {
    name = "LawChaos"
    type = "S"
  }
  
  global_secondary_index {
    name               = "LawChaosIndex"
    hash_key           = "LawChaos"
    range_key          = "MysfitId"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }

  global_secondary_index {
    name               = "GoodEvilIndex"
    hash_key           = "GoodEvil"
    range_key          = "MysfitId"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }

  tags = {
    Name        = var.project
  }
}

# VPC Endpoint for DynamoDB
  # If a container needs to access DynamoDB (coming in module 3) this
  # allows a container in the private subnet to talk to DynamoDB directly
  # without needing to go via the NAT gateway.


resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.ecr_fargate.id
  service_name = "com.amazonaws.eu-west-2.dynamodb"

  tags = {
    name = var.project
  }
}

      