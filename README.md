In this project, I built a static website with Docker image stored in ECR. Docker is run in an ECS cluster on Fargate.

![diagram](diagram.png)

## About
Terraform creates a ECR repository and runs a bash script to push the static-site Docker image. Then it creates an ECS cluster using the Fargate launch type. 

You can access the deployed static website using the DNS name associated with your load balancer that shows up as output after the deployment.

## Alternatives
1. You don't need to store the docker image in ECR, you can pull it from DockerHub directly. Change the image value for aws_ecs_task_definition to "dockersamples/static-site".
2. You can use a VCP endpoint instead of NAT Gateway from Fargate to ECR. You will need 3 endpoints for: S3, ECR and Logs. 

## Sources:
- https://erik-ekberg.medium.com/terraform-ecs-fargate-example-1397d3ab7f02
- https://catalog.us-east-1.prod.workshops.aws/workshops/ed1a8610-c721-43be-b8e7-0f300f74684e/en-US/mythicalintro
- https://dev.to/kieranjen/ecs-fargate-service-auto-scaling-with-terraform-2ld


