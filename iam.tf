 #### ECS
 # This is an IAM role which authorizes ECS to manage resources on your
  # account on your behalf, such as updating your load balancer with the
  # details of where your containers are, so that traffic can reach your
  # containers.

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name               = "ecs_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "ecs_policy"
  role = aws_iam_role.ecs_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            # Rules which allow ECS to attach network interfaces to instances
            # on your behalf in order for awsvpc networking mode to work right
              "ec2:AttachNetworkInterface",
              "ec2:CreateNetworkInterface",
              "ec2:CreateNetworkInterfacePermission",
              "ec2:DeleteNetworkInterface",
              "ec2:DeleteNetworkInterfacePermission",
              "ec2:Describe*",
              "ec2:DetachNetworkInterface",

            # Rules which allow ECS to update load balancers on your behalf
            # with the information sabout how to send traffic to your containers
              "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
              "elasticloadbalancing:DeregisterTargets",
              "elasticloadbalancing:Describe*",
              "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
              "elasticloadbalancing:RegisterTargets",

              # Rules which allow ECS to run tasks that have IAM roles assigned to them.
              "iam:PassRole",

              # Rules that let ECS interact with container images.
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",

              # Rules that let ECS create and push logs to CloudWatch.
              "logs:DescribeLogStreams",
              "logs:CreateLogStream",
              "logs:CreateLogGroup",
              "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
####ECS_TASK
  # This is a role which is used by the ECS tasks. Tasks in Amazon ECS define
  # the containers that should be deployed togehter and the resources they
  # require from a compute/memory perspective. So, the policies below will define
  # the IAM permissions that our Mythical Mysfits docker containers will have.
  # If you attempted to write any code for the Mythical Mysfits service that
  # interacted with different AWS service APIs, these roles would need to include
  # those as allowed actions.


data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}


resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "ecs_task_policy"
  role = aws_iam_role.ecs_task_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [

            # Allow the ECS Tasks to download images from ECR
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",

            # Allow the ECS tasks to upload logs to CloudWatch
               "logs:CreateLogStream",
               "logs:CreateLogGroup",
               "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
          Action = [
            # Allows the ECS tasks to interact with only the MysfitsTable
            # in DynamoDB
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem",
                "dynamodb:GetItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.ecr_fargate.arn
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ecs_task_profile" {
  name = "ecs_task_profile"
  role = aws_iam_role.ecs_task_role.name
}