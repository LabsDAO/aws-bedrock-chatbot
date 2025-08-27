#!/bin/bash

# AskLabs.ai AWS Bedrock Chatbot with Ollama Integration
# Deploy script for AWS Bedrock + Ollama chatbot infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    print_success "All requirements are met!"
}

# Get AWS configuration
get_aws_config() {
    print_status "Getting AWS configuration..."
    
    # Get AWS account ID
    export TF_VAR_account_id=$(aws sts get-caller-identity --query Account --output text)
    if [ -z "$TF_VAR_account_id" ]; then
        print_error "Failed to get AWS account ID. Please check your AWS credentials."
        exit 1
    fi
    
    # Get AWS region
    export TF_VAR_region=$(aws configure get region)
    if [ -z "$TF_VAR_region" ]; then
        print_error "AWS region not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    # Get AWS profile
    export TF_VAR_profile=${AWS_PROFILE:-default}
    
    print_success "AWS Configuration:"
    print_status "  Account ID: $TF_VAR_account_id"
    print_status "  Region: $TF_VAR_region"
    print_status "  Profile: $TF_VAR_profile"
}

# Check Bedrock access
check_bedrock_access() {
    print_status "Checking Amazon Bedrock access..."
    
    if ! aws bedrock list-foundation-models --region $TF_VAR_region &> /dev/null; then
        print_warning "Amazon Bedrock access not available. You may need to request access:"
        print_warning "https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html"
        print_warning "Continuing with Ollama-only deployment..."
    else
        print_success "Amazon Bedrock access confirmed!"
    fi
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan the deployment
    print_status "Planning deployment..."
    terraform plan -var="account_id=$TF_VAR_account_id" -var="region=$TF_VAR_region" -var="profile=$TF_VAR_profile"
    
    # Ask for confirmation
    echo
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Deployment cancelled."
        exit 0
    fi
    
    # Apply the configuration
    print_status "Applying Terraform configuration..."
    terraform apply -var="account_id=$TF_VAR_account_id" -var="region=$TF_VAR_region" -var="profile=$TF_VAR_profile" -auto-approve
    
    cd ..
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Get the ALB DNS name
    ALB_DNS=$(cd terraform && terraform output -raw alb_dns_name && cd ..)
    
    if [ -z "$ALB_DNS" ]; then
        print_error "Failed to get ALB DNS name"
        exit 1
    fi
    
    print_status "Application Load Balancer: $ALB_DNS"
    
    # Wait for the application to be ready
    print_status "Waiting for application to be ready..."
    for i in {1..30}; do
        if curl -s -f "https://$ALB_DNS" > /dev/null 2>&1; then
            print_success "Application is ready!"
            break
        fi
        
        if [ $i -eq 30 ]; then
            print_warning "Application may still be starting up. Please check the URL manually."
        fi
        
        echo -n "."
        sleep 10
    done
    
    echo
    print_success "Deployment completed!"
    print_status "Your AskLabs.ai chatbot is available at: https://$ALB_DNS"
    print_status "Features available:"
    print_status "  ✅ AWS Bedrock models (Claude, Titan, etc.)"
    print_status "  ✅ Ollama local models"
    print_status "  ✅ Open WebUI interface"
    print_status "  ✅ Custom domain support (if configured)"
}

# Main deployment function
main() {
    echo "🚀 AskLabs.ai AWS Bedrock + Ollama Chatbot Deployment"
    echo "=================================================="
    echo
    
    check_requirements
    get_aws_config
    check_bedrock_access
    deploy_infrastructure
    wait_for_services
    
    echo
    echo "🎉 Deployment completed successfully!"
    echo
    echo "Next steps:"
    echo "1. Open your browser and navigate to the provided URL"
    echo "2. Register an account to start using the chatbot"
    echo "3. In the admin panel, you can configure Ollama models"
    echo "4. Pull your favorite models using: ollama pull llama2"
    echo
    echo "For Ollama model management:"
    echo "- Visit the admin panel in Open WebUI"
    echo "- Go to Settings > Connections > Ollama"
    echo "- Configure your preferred models"
    echo
    echo "Happy chatting! 🤖"
}

# Run the main function
main "$@" 