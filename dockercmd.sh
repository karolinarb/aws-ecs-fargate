#!/bin/bash

aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 863534173996.dkr.ecr.eu-west-2.amazonaws.com
docker build -t ecs-fargate-proj1-repo .
docker tag ecs-fargate-proj1-repo:latest 863534173996.dkr.ecr.eu-west-2.amazonaws.com/ecs-fargate-proj1-repo:latest
docker push 863534173996.dkr.ecr.eu-west-2.amazonaws.com/ecs-fargate-proj1-repo:latest