#!/bin/bash

# ExpenseTracker Deployment Script
set -e

# Configuration
APP_NAME="expense-tracker"
DOCKER_IMAGE="$APP_NAME:latest"
CONTAINER_NAME="$APP_NAME-app"
NETWORK_NAME="$APP_NAME-network"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Build the application
build_app() {
    log_info "Building the application..."
    ./gradlew build -x test
    log_info "Application built successfully"
}

# Build Docker image
build_image() {
    log_info "Building Docker image..."
    docker build -t $DOCKER_IMAGE .
    log_info "Docker image built successfully"
}

# Stop and remove existing container
cleanup_container() {
    if docker ps -a --format 'table {{.Names}}' | grep -q $CONTAINER_NAME; then
        log_warn "Stopping existing container..."
        docker stop $CONTAINER_NAME || true
        docker rm $CONTAINER_NAME || true
    fi
}

# Deploy using Docker Compose
deploy_compose() {
    log_info "Deploying with Docker Compose..."
    
    # Check if .env file exists
    if [ ! -f .env ]; then
        log_warn "Creating .env file with default values..."
        cat > .env << EOF
DB_USERNAME=expenseuser
DB_PASSWORD=changeme123
EOF
        log_warn "Please update the .env file with your actual database credentials"
    fi
    
    docker-compose -f docker-compose.prod.yml up -d
    log_info "Application deployed successfully"
}

# Deploy single container (alternative to compose)
deploy_container() {
    log_info "Deploying single container..."
    
    # Create network if it doesn't exist
    docker network create $NETWORK_NAME 2>/dev/null || true
    
    # Start PostgreSQL container
    docker run -d \
        --name ${APP_NAME}-postgres \
        --network $NETWORK_NAME \
        -e POSTGRES_DB=expensetracker \
        -e POSTGRES_USER=expenseuser \
        -e POSTGRES_PASSWORD=changeme123 \
        -v postgres_data:/var/lib/postgresql/data \
        -p 5432:5432 \
        postgres:15-alpine
    
    # Wait for PostgreSQL to be ready
    log_info "Waiting for PostgreSQL to be ready..."
    sleep 30
    
    # Start application container
    docker run -d \
        --name $CONTAINER_NAME \
        --network $NETWORK_NAME \
        -e SPRING_PROFILES_ACTIVE=prod \
        -e SPRING_DATASOURCE_URL=jdbc:postgresql://${APP_NAME}-postgres:5432/expensetracker \
        -e SPRING_DATASOURCE_USERNAME=expenseuser \
        -e SPRING_DATASOURCE_PASSWORD=changeme123 \
        -p 8080:8080 \
        $DOCKER_IMAGE
    
    log_info "Application deployed successfully"
}

# Health check
health_check() {
    log_info "Performing health check..."
    
    # Wait for application to start
    sleep 60
    
    # Check if application is responding
    if curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; then
        log_info "Health check passed - Application is running"
    else
        log_error "Health check failed - Application may not be running properly"
        exit 1
    fi
}

# Show logs
show_logs() {
    log_info "Showing application logs..."
    docker logs $CONTAINER_NAME --tail 50 -f
}

# Main deployment function
deploy() {
    check_docker
    build_app
    build_image
    cleanup_container
    
    # Choose deployment method
    if [ "$1" = "compose" ]; then
        deploy_compose
    else
        deploy_container
    fi
    
    health_check
    
    log_info "Deployment completed successfully!"
    log_info "Application is available at: http://localhost:8080"
    log_info "Health check endpoint: http://localhost:8080/actuator/health"
}

# Script usage
usage() {
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  deploy [compose]  - Deploy the application (optionally with docker-compose)"
    echo "  logs             - Show application logs"
    echo "  stop             - Stop the application"
    echo "  restart          - Restart the application"
    echo "  health           - Check application health"
}

# Stop application
stop_app() {
    log_info "Stopping application..."
    docker-compose -f docker-compose.prod.yml down 2>/dev/null || true
    cleanup_container
    docker stop ${APP_NAME}-postgres 2>/dev/null || true
    docker rm ${APP_NAME}-postgres 2>/dev/null || true
    log_info "Application stopped"
}

# Main script logic
case "$1" in
    deploy)
        deploy $2
        ;;
    logs)
        show_logs
        ;;
    stop)
        stop_app
        ;;
    restart)
        stop_app
        deploy $2
        ;;
    health)
        health_check
        ;;
    *)
        usage
        exit 1
        ;;
esac
