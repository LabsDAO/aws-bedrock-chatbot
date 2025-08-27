#!/bin/bash

# Ollama Model Management Script for AskLabs.ai
# This script helps manage Ollama models in the deployed ECS infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Get ECS task ID for Ollama service
get_ollama_task_id() {
    local cluster_name="webui-bedrock-cluster"
    local service_name="ollama"
    
    local task_arn=$(aws ecs list-tasks \
        --cluster $cluster_name \
        --service-name $service_name \
        --query 'taskArns[0]' \
        --output text 2>/dev/null)
    
    if [ "$task_arn" = "None" ] || [ -z "$task_arn" ]; then
        print_error "No running Ollama tasks found"
        return 1
    fi
    
    # Extract task ID from ARN
    echo $task_arn | sed 's/.*\///'
}

# Execute command in Ollama container
execute_in_ollama() {
    local task_id=$1
    local command=$2
    
    aws ecs execute-command \
        --cluster webui-bedrock-cluster \
        --task $task_id \
        --container ollama \
        --command "$command" \
        --interactive
}

# List available models
list_models() {
    print_status "Listing available models..."
    
    local task_id=$(get_ollama_task_id)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    print_status "Connected to Ollama task: $task_id"
    execute_in_ollama $task_id "ollama list"
}

# Pull a model
pull_model() {
    local model_name=$1
    
    if [ -z "$model_name" ]; then
        print_error "Model name is required"
        echo "Usage: $0 pull <model_name>"
        echo "Examples:"
        echo "  $0 pull llama2"
        echo "  $0 pull codellama"
        echo "  $0 pull mistral"
        return 1
    fi
    
    print_status "Pulling model: $model_name"
    
    local task_id=$(get_ollama_task_id)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    execute_in_ollama $task_id "ollama pull $model_name"
}

# Remove a model
remove_model() {
    local model_name=$1
    
    if [ -z "$model_name" ]; then
        print_error "Model name is required"
        echo "Usage: $0 remove <model_name>"
        return 1
    fi
    
    print_warning "Removing model: $model_name"
    
    local task_id=$(get_ollama_task_id)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    execute_in_ollama $task_id "ollama rm $model_name"
}

# Show model information
show_model() {
    local model_name=$1
    
    if [ -z "$model_name" ]; then
        print_error "Model name is required"
        echo "Usage: $0 show <model_name>"
        return 1
    fi
    
    print_status "Showing model information: $model_name"
    
    local task_id=$(get_ollama_task_id)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    execute_in_ollama $task_id "ollama show $model_name"
}

# Get Ollama service status
get_status() {
    print_status "Getting Ollama service status..."
    
    aws ecs describe-services \
        --cluster webui-bedrock-cluster \
        --services ollama \
        --query 'services[0].{Status:status,DesiredCount:desiredCount,RunningCount:runningCount,PendingCount:pendingCount}' \
        --output table
}

# Get Ollama logs
get_logs() {
    local lines=${1:-50}
    
    print_status "Getting Ollama logs (last $lines lines)..."
    
    aws logs tail "/ecs/webui-bedrock-cluster" \
        --follow \
        --since 1h \
        --filter-pattern "ollama" \
        --max-items $lines
}

# Interactive shell
shell() {
    print_status "Opening interactive shell in Ollama container..."
    
    local task_id=$(get_ollama_task_id)
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    execute_in_ollama $task_id "/bin/bash"
}

# Show usage
show_usage() {
    echo "🤖 Ollama Model Management Script"
    echo "================================="
    echo
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  list                    List all available models"
    echo "  pull <model_name>       Pull a model (e.g., llama2, codellama)"
    echo "  remove <model_name>     Remove a model"
    echo "  show <model_name>       Show model information"
    echo "  status                  Show Ollama service status"
    echo "  logs [lines]            Show Ollama logs (default: 50 lines)"
    echo "  shell                   Open interactive shell in Ollama container"
    echo "  help                    Show this help message"
    echo
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 pull llama2"
    echo "  $0 pull codellama:7b"
    echo "  $0 remove llama2"
    echo "  $0 show llama2"
    echo "  $0 status"
    echo "  $0 logs 100"
    echo "  $0 shell"
    echo
    echo "Popular Models:"
    echo "  - llama2 (3.8GB)"
    echo "  - llama2:13b (7.3GB)"
    echo "  - codellama (3.8GB)"
    echo "  - mistral (4.1GB)"
    echo "  - phi (1.3GB)"
    echo "  - neural-chat (3.8GB)"
}

# Main function
main() {
    local command=$1
    local model_name=$2
    
    case $command in
        "list")
            list_models
            ;;
        "pull")
            pull_model $model_name
            ;;
        "remove")
            remove_model $model_name
            ;;
        "show")
            show_model $model_name
            ;;
        "status")
            get_status
            ;;
        "logs")
            get_logs $model_name
            ;;
        "shell")
            shell
            ;;
        "help"|"--help"|"-h"|"")
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 