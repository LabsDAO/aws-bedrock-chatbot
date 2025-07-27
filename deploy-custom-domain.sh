#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying OpenWebUI with custom domain setup...${NC}"

# Check if required tools are installed
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}❌ Terraform is not installed. Please install Terraform first.${NC}" >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo -e "${RED}❌ AWS CLI is not installed. Please install AWS CLI first.${NC}" >&2; exit 1; }

# Check if AWS credentials are configured
aws sts get-caller-identity >/dev/null 2>&1 || { echo -e "${RED}❌ AWS credentials are not configured. Please run 'aws configure' first.${NC}" >&2; exit 1; }

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account ID: ${ACCOUNT_ID}${NC}"

# Get AWS Region
REGION=$(aws configure get region)
echo -e "${GREEN}✅ AWS Region: ${REGION}${NC}"

# Clone Bedrock Access Gateway repository
if [ ! -d "terraform/assets/bedrock-access-gateway" ]; then
  echo -e "${YELLOW}📥 Cloning Bedrock Access Gateway repository...${NC}"
  git clone https://github.com/aws-samples/bedrock-access-gateway terraform/assets/bedrock-access-gateway
fi

# Clone Open WebUI repository
if [ ! -d "terraform/assets/open-webui" ]; then
  echo -e "${YELLOW}📥 Cloning Open WebUI repository...${NC}"
  git clone https://github.com/open-webui/open-webui terraform/assets/open-webui
  # Fix memory issue in Dockerfile
  sed -i '' 's|RUN npm run build|RUN NODE_OPTIONS="--max-old-space-size=4096" npm run build|' terraform/assets/open-webui/Dockerfile
fi

# Create terraform.tfvars file
echo -e "${YELLOW}📝 Creating terraform.tfvars file...${NC}"
cat > terraform/terraform.tfvars << EOF
account_id = "${ACCOUNT_ID}"
region     = "${REGION}"
profile    = "default"
domain_name = "asklabs.ai"
EOF

# Init and apply Terraform configuration
echo -e "${YELLOW}🔧 Initializing Terraform...${NC}"
cd terraform && terraform init

echo -e "${YELLOW}🚀 Applying Terraform configuration...${NC}"
terraform apply -auto-approve

# Get outputs
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo -e "${YELLOW}📋 Deployment Information:${NC}"
echo -e "ALB URL: $(terraform output -raw alb_url)"
echo -e "Custom Domain: $(terraform output -raw custom_domain)"
echo -e "${RED}⚠️  IMPORTANT: Add these nameservers to your domain registrar (asklabs.ai):${NC}"
terraform output -raw nameservers | tr -d '[]"' | tr ',' '\n' | sed 's/^/  /'

echo -e "${GREEN}🎉 Your OpenWebUI is now deployed!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo -e "1. Add the nameservers above to your domain registrar for asklabs.ai"
echo -e "2. Wait for DNS propagation (can take up to 48 hours)"
echo -e "3. Visit https://asklabs.ai to access your application"
echo -e "4. Register an account and start chatting with Bedrock LLMs!" 