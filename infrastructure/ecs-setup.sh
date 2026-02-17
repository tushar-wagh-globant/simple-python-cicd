#!/bin/bash

AWS_REGION=${1:-us-east-1}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPOSITORY="aws-python-sample"
ECS_CLUSTER="aws-python-sample-cluster"
ECS_SERVICE="aws-python-sample-service"

echo "Setting up AWS ECS infrastructure..."

# Create ECR repository
echo "Creating ECR repository..."
aws ecr create-repository --repository-name $ECR_REPOSITORY --region $AWS_REGION || echo "ECR repository already exists"

# Create ECS cluster
echo "Creating ECS cluster..."
aws ecs create-cluster --cluster-name $ECS_CLUSTER --region $AWS_REGION || echo "ECS cluster already exists"

# Create task execution role
echo "Creating task execution role..."
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}' || echo "Role already exists"

aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Update task definition with your account ID
sed -i.tmp "s/YOUR_ACCOUNT_ID/$ACCOUNT_ID/g" .aws/task-definition.json

# Create CloudWatch log group
echo "Creating CloudWatch log group..."
aws logs create-log-group --log-group-name /ecs/$ECR_REPOSITORY --region $AWS_REGION || echo "Log group already exists"

echo "Infrastructure setup complete!"
echo "Next steps:"
echo "1. Update GitHub repository secrets:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo "2. Run: aws ecs create-service --cluster $ECS_CLUSTER --service-name $ECS_SERVICE --task-definition aws-python-sample --desired-count 1 --launch-type FARGATE --network-configuration 'awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}'"