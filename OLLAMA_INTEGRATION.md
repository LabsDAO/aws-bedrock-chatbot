# 🤖 Ollama Integration for AskLabs.ai

This document describes the Ollama integration for the AskLabs.ai AWS Bedrock chatbot, enabling you to run local models alongside AWS Bedrock models.

## 🏗️ Architecture Overview

The Ollama integration adds a new ECS service to your existing infrastructure:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Open WebUI    │    │  Bedrock Access │    │     Ollama      │
│   (Frontend)    │◄──►│    Gateway      │    │   (Local LLMs)  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Application   │
                    │  Load Balancer  │
                    └─────────────────┘
```

## 🚀 Features

- **Dual Model Support**: Use both AWS Bedrock and local Ollama models
- **Seamless Integration**: Models appear in the same Open WebUI interface
- **Persistent Storage**: Models are stored in EFS for persistence
- **Scalable**: Ollama runs on ECS Fargate with configurable resources
- **Secure**: All communication happens within the VPC

## 📋 Prerequisites

- AWS CLI configured
- Terraform installed (>= 1.9.5)
- Docker installed
- AWS Account with appropriate permissions

## 🛠️ Deployment

### Quick Start

```bash
# Clone the repository
git clone https://github.com/LabsDAO/aws-bedrock-chatbot.git
cd aws-bedrock-chatbot

# Deploy with Ollama integration
./deploy-with-ollama.sh
```

### Manual Deployment

```bash
# Set environment variables
export TF_VAR_account_id=$(aws sts get-caller-identity --query Account --output text)
export TF_VAR_region=$(aws configure get region)
export TF_VAR_profile=${AWS_PROFILE:-default}

# Deploy infrastructure
cd terraform
terraform init
terraform apply -auto-approve
cd ..
```

## 🔧 Configuration

### Ollama Service Configuration

The Ollama service is configured with:

- **Memory**: 64GB (optimized for large models like deepseek-r1:32b)
- **CPU**: 16 vCPU (optimized for performance)
- **Storage**: EFS mount for persistent model storage
- **Network**: Private subnet with service discovery

### Open WebUI Configuration

Open WebUI is configured to connect to Ollama via:

```bash
ENABLE_OLLAMA_API=True
OLLAMA_BASE_URLS=http://ollama.bedrock.local:11434
OLLAMA_API_CONFIGS={"0":{"base_url":"http://ollama.bedrock.local:11434","enable":true}}
```

## 📊 Resource Requirements

### Ollama Service
- **Memory**: 64GB (optimized for large models)
- **CPU**: 16 vCPU
- **Storage**: EFS for model persistence
- **Network**: Private subnet access

### Recommended Models
- **llama2**: 3.8GB
- **llama2:13b**: 7.3GB
- **llama2:70b**: 39GB
- **deepseek-r1:32b**: ~60GB
- **deepseek-coder:33b**: ~65GB
- **codellama**: 3.8GB
- **mistral**: 4.1GB
- **qwen2.5:72b**: ~70GB

## 🎯 Usage

### 1. Access the Application

After deployment, access your application at the provided URL and register an account.

### 2. Configure Ollama Models

1. **Via Open WebUI Admin Panel**:
   - Go to Settings → Connections → Ollama
   - Verify the connection is enabled
   - Models will appear automatically

2. **Via Direct Ollama Commands**:
   ```bash
   # Connect to the Ollama service
   aws ecs execute-command --cluster webui-bedrock-cluster --task <task-id> --container ollama --command "/bin/bash"
   
   # Pull models
   ollama pull llama2
   ollama pull codellama
   ```

### 3. Using Models

- **In Open WebUI**: Select Ollama models from the model dropdown
- **API Access**: Use the OpenAI-compatible API endpoints
- **Model Management**: Use the admin panel for model operations

## 🔍 Monitoring

### CloudWatch Logs

Monitor Ollama service logs:

```bash
# Get log group
aws logs describe-log-groups --log-group-name-prefix "/ecs/webui-bedrock-cluster"

# View logs
aws logs tail "/ecs/webui-bedrock-cluster" --follow
```

### ECS Service Status

```bash
# Check service status
aws ecs describe-services --cluster webui-bedrock-cluster --services ollama

# Check task status
aws ecs describe-tasks --cluster webui-bedrock-cluster --tasks <task-id>
```

## 🛠️ Troubleshooting

### Common Issues

1. **Ollama Service Not Starting**:
   - Check ECS service logs
   - Verify memory allocation (increase if needed)
   - Check EFS mount permissions

2. **Models Not Loading**:
   - Verify Ollama service is running
   - Check network connectivity
   - Verify model files in EFS

3. **Performance Issues**:
   - Increase CPU/memory allocation
   - Use smaller models
   - Consider GPU instances for larger models

### Debug Commands

```bash
# Check Ollama service status
aws ecs describe-services --cluster webui-bedrock-cluster --services ollama

# Execute commands in Ollama container
aws ecs execute-command --cluster webui-bedrock-cluster --task <task-id> --container ollama --command "/bin/bash"

# Check EFS mount
df -h /root/.ollama

# Test Ollama API
curl http://ollama.bedrock.local:11434/api/tags
```

## 🔒 Security

### Network Security
- Ollama service runs in private subnets
- Communication via service discovery
- No direct internet access

### Access Control
- Open WebUI authentication required
- Admin panel for model management
- Audit logging enabled

## 📈 Scaling

### Horizontal Scaling
```bash
# Scale Ollama service
aws ecs update-service --cluster webui-bedrock-cluster --service ollama --desired-count 2
```

### Vertical Scaling
Update the task definition to increase CPU/memory:

```hcl
resource "aws_ecs_task_definition" "task_definition_ollama" {
  memory = 16384  # 16GB
  cpu    = 8192   # 8 vCPU
  # ... rest of configuration
}
```

## 💰 Cost Optimization

### Resource Optimization
- Use appropriate model sizes
- Scale down during off-hours
- Use spot instances for cost savings

### Storage Optimization
- Clean up unused models
- Use model compression
- Monitor EFS usage

## 🔄 Updates

### Updating Ollama
```bash
# Update the Docker image
cd terraform
terraform apply -target=null_resource.build_ollama_image
terraform apply
```

### Updating Models
```bash
# Pull new models
aws ecs execute-command --cluster webui-bedrock-cluster --task <task-id> --container ollama --command "ollama pull llama2:latest"
```

## 📚 Additional Resources

- [Ollama Documentation](https://ollama.ai/docs)
- [Open WebUI Documentation](https://docs.openwebui.com/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform Documentation](https://www.terraform.io/docs)

## 🤝 Support

For issues and questions:
- Check the troubleshooting section
- Review CloudWatch logs
- Open an issue on GitHub
- Contact the LabsDAO team

---

**Happy coding with local LLMs! 🚀** 