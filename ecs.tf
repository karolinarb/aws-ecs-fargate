resource "aws_ecr_repository" "mythicalmysfits" {
  name                 = "mythicalmysfits"
}

resource "aws_ecs_cluster" "mythicalmysfits" {
  name = "Cluster-MythicalMysfits"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_cloudwatch_log_group" "ecr_fargate" {
  name = "mythicalmysfits"
}

resource "aws_ecs_task_definition" "mythicalmysfits" {
  family                = "mythicalmysfits"
  container_definitions = <<TASK_DEFINITION
[ 
   {
    "name": "monolith-service",
    "image": "nginx:latest",
    "memory":512,
    "portMappings": [
       {
          "containerPort": 80,
          "protocol": "http"
       }
    ],
    "environment": [
       {
          "name": "DDB_TABLE_NAME",
          "value": "ecr_fargate"
       }
    ],
    "essential": true
 }
]
TASK_DEFINITION

  volume {
    name = "mythicalmysfits-storage"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
    }
  }
}