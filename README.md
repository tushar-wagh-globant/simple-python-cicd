# AWS Python sample

A sample python FastAPI application designed for deployment to AWS ECS using containers.


## Features

- FastAPI web framework
- Pydantic for data validation
- Docker containerization
- GitHub Actions CI/CD pipeline
- AWS ECS deployment
- Uses `uv` as package manager


## Local Development

### Prerequisites

- Python 3.12+
- Docker
- uv package manager

### Setup

1. Install uv:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

2. Install dependencies:
```bash
uv sync --dev
```

3. Run the application:
```bash
uv run python -m app.main
```

Or run directly with uvicorn:
```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Testing

Run tests with pytest:
```bash
uv run pytest
```

## Docker

Build the Docker image:
```bash
docker build -t aws-python-sample .
```

Run the container:
```bash
docker run -p 8000:8000 aws-python-sample
```

## AWS Deployment

### Infrastructure Setup

1. Install AWS CLI and configure your credentials
2. Run the infrastructure setup script:
```bash
chmod +x infrastructure/ecs-setup.sh
./infrastructure/ecs-setup.sh
```

### GitHub Actions

Add the following repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

When you push to the `main` branch, the GitHub Actions workflow will:
1. Run tests
2. Build the Docker image
3. Push to Amazon ECR
4. Deploy to ECS

### Manual Deployment Steps

1. Replace `YOUR_ACCOUNT_ID` in `.aws/task-definition.json` with your AWS account ID
2. Create ECS service:
```bash
aws ecs create-service \
  --cluster aws-python-sample-cluster \
  --service-name aws-python-sample-service \
  --task-definition aws-python-sample \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}"
```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check
- `GET /items` - List all items
- `POST /items` - Create a new item
- `GET /items/{item_id}` - Get a specific item

## Environment Variables

- `PORT` - Application port (default: 8000)
- `ENVIRONMENT` - Environment name (default: development)

## Project Structure

```
├── app/
│   └── main.py              # FastAPI application
├── tests/
│   └── test_main.py         # Tests
├── .github/
│   └── workflows/
│       └── docker.yml       # GitHub Actions workflow
├── .aws/
│   └── task-definition.json # ECS task definition
├── infrastructure/
│   └── ecs-setup.sh        # Infrastructure setup script
├── Dockerfile               # Docker configuration
├── pyproject.toml          # Project configuration with uv
└── README.md
```