#!/bin/bash

# AlphaMind Project - Deployment Script (Template)

# --- Configuration --- 
# !!! IMPORTANT: Configure these variables for your target environment !!!
TARGET_HOST="user@your_server_ip_or_domain" # SSH target host (e.g., user@1.2.3.4)
TARGET_BASE_DIR="/path/to/deploy/alphamind" # Base directory on the target server

# Optional: SSH key path if not using default
# SSH_KEY_PATH="~/.ssh/your_private_key"
SSH_OPTIONS=""
# if [ -n "$SSH_KEY_PATH" ]; then
#   SSH_OPTIONS="-i $SSH_KEY_PATH"
# fi

# --- Define colors for output --- 
COLOR_RESET=\e[0m
COLOR_GREEN=\e[32m
COLOR_RED=\e[31m
COLOR_YELLOW=\e[33m
COLOR_BLUE=\e[34m
COLOR_CYAN=\e[36m

# --- Helper Functions --- 

# Function to check if a command exists locally
command_exists_local() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print section headers
print_header() {
    echo -e "\n${COLOR_BLUE}==================================================${COLOR_RESET}"
    echo -e "${COLOR_BLUE} $1 ${COLOR_RESET}"
    echo -e "${COLOR_BLUE}==================================================${COLOR_RESET}"
}

# Function to print success messages
print_success() {
    echo -e "${COLOR_GREEN}[SUCCESS] $1${COLOR_RESET}"
}

# Function to print error messages
print_error() {
    echo -e "${COLOR_RED}[ERROR] $1${COLOR_RESET}" >&2
}

# Function to print warning messages
print_warning() {
    echo -e "${COLOR_YELLOW}[WARNING] $1${COLOR_RESET}"
}

# Function to print info messages
print_info() {
    echo -e "${COLOR_CYAN}[INFO] $1${COLOR_RESET}"
}

# Function to run a command locally
run_local() {
    print_info "Running locally: $1"
    eval "$1"
    if [ $? -ne 0 ]; then
        print_error "Local command failed: $1"
        exit 1
    fi
}

# Function to run a command remotely via SSH
run_remote() {
    print_info "Running on $TARGET_HOST: $1"
    ssh $SSH_OPTIONS "$TARGET_HOST" "$1"
    if [ $? -ne 0 ]; then
        print_error "Remote command failed: $1"
        # Decide if failure is critical
        # exit 1 
    fi
}

# Function to transfer files/dirs using scp (requires scp locally)
# Usage: transfer_files "local_path" "remote_path"
transfer_files() {
    local local_path="$1"
    local remote_path="$2"
    print_info "Transferring 
\"$local_path\" to 
\"$TARGET_HOST:$remote_path\"..."
    scp $SSH_OPTIONS -r "$local_path" "$TARGET_HOST:$remote_path"
    if [ $? -ne 0 ]; then
        print_error "Failed to transfer 
\"$local_path\""
        exit 1
    fi
}

# --- Initialization --- 

# Exit immediately if a command exits with a non-zero status.
set -e

# Define project root directory (assuming the script is in the project root)
PROJECT_ROOT="$(pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

# --- Local Prerequisite Checks --- 
print_header "Performing Local Prerequisite Checks"

CHECKS_PASSED=1
if ! command_exists_local ssh; then
    print_error "ssh command not found locally. Please install an SSH client."
    CHECKS_PASSED=0
fi
if ! command_exists_local scp; then
    print_error "scp command not found locally. Please install scp (usually part of SSH client)."
    CHECKS_PASSED=0
fi
# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    print_error "Build directory 
\"$BUILD_DIR\" not found. Please run the build script first."
    CHECKS_PASSED=0
fi

if [ $CHECKS_PASSED -eq 0 ]; then
    print_error "Local prerequisite checks failed."
    exit 1
else
    print_success "Local prerequisite checks passed."
fi

# --- Remote Prerequisite Checks & Setup --- 
print_header "Performing Remote Prerequisite Checks & Setup on $TARGET_HOST"

# Check SSH connection
print_info "Testing SSH connection to $TARGET_HOST..."
ssh $SSH_OPTIONS "$TARGET_HOST" "echo 
\"SSH connection successful.\""
if [ $? -ne 0 ]; then
    print_error "Failed to connect to $TARGET_HOST via SSH. Check TARGET_HOST, user, permissions, and SSH_KEY_PATH (if used)."
    exit 1
fi
print_success "SSH connection successful."

# Create base directory on remote server
run_remote "mkdir -p $TARGET_BASE_DIR"
run_remote "mkdir -p $TARGET_BASE_DIR/releases"
run_remote "mkdir -p $TARGET_BASE_DIR/shared"

# --- Deployment Steps --- 
print_header "Starting AlphaMind Deployment"

# Define release directory (e.g., using timestamp)
RELEASE_TIMESTAMP=$(date +%Y%m%d%H%M%S)
RELEASE_DIR="$TARGET_BASE_DIR/releases/$RELEASE_TIMESTAMP"

print_info "Creating new release directory on remote: $RELEASE_DIR"
run_remote "mkdir -p $RELEASE_DIR"

# --- Transfer Build Artifacts --- 
print_header "Transferring Build Artifacts"

# Transfer Backend
if [ -d "$BUILD_DIR/backend" ]; then
    transfer_files "$BUILD_DIR/backend" "$RELEASE_DIR/backend"
else
    print_warning "Build directory for backend not found. Skipping transfer."
fi

# Transfer Web Frontend
if [ -d "$BUILD_DIR/web" ]; then
    transfer_files "$BUILD_DIR/web" "$RELEASE_DIR/web"
else
    print_warning "Build directory for web frontend not found. Skipping transfer."
fi

# Transfer Mobile Frontend (Web Export)
if [ -d "$BUILD_DIR/mobile" ]; then
    transfer_files "$BUILD_DIR/mobile" "$RELEASE_DIR/mobile"
else
    print_warning "Build directory for mobile frontend not found. Skipping transfer."
fi

print_success "Build artifacts transferred."

# --- Remote Setup & Configuration --- 
print_header "Performing Remote Setup & Configuration"

# Backend Setup (Example: Python/Flask/Gunicorn)
print_info "Setting up backend on remote..."
BACKEND_REMOTE_DIR="$RELEASE_DIR/backend"
# Example steps:
# 1. Create/update virtual environment
run_remote "cd $BACKEND_REMOTE_DIR && python3 -m venv venv" # Adjust python command if needed
# 2. Install dependencies
run_remote "cd $BACKEND_REMOTE_DIR && source venv/bin/activate && pip install -r requirements.txt"
# 3. Database migrations (if applicable)
# run_remote "cd $BACKEND_REMOTE_DIR && source venv/bin/activate && flask db upgrade" 
# 4. Collect static files (if applicable, e.g., Django)
# run_remote "cd $BACKEND_REMOTE_DIR && source venv/bin/activate && python manage.py collectstatic --noinput"
print_success "Backend remote setup complete (example steps)."

# Frontend Setup (Example: Nginx serving static files)
print_info "Setting up frontends on remote (example: Nginx config)..."
# Example steps:
# 1. Update Nginx configuration to point to the new release's web/mobile directories.
# This usually involves modifying a config file and reloading Nginx.
# run_remote "sudo ln -s /path/to/your/nginx/config/for/this/release /etc/nginx/sites-enabled/alphamind"
# run_remote "sudo systemctl reload nginx"
print_warning "Frontend deployment requires manual Nginx/web server configuration update on the target server."
print_success "Frontend remote setup placeholder complete."

# --- Activate New Release --- 
print_header "Activating New Release"

# Update symbolic link (atomic switch)
CURRENT_SYMLINK="$TARGET_BASE_DIR/current"
print_info "Updating symbolic link 
\"$CURRENT_SYMLINK\" to point to 
\"$RELEASE_DIR\""
run_remote "ln -sfn $RELEASE_DIR $CURRENT_SYMLINK"
print_success "New release activated."

# --- Restart Services --- 
print_header "Restarting Services"

# Example: Restart Gunicorn/uWSGI service for the backend
# run_remote "sudo systemctl restart your_backend_service_name"
print_warning "Service restart needs to be configured based on your backend setup (e.g., systemd service)."

# Nginx reload might have happened during frontend setup
# run_remote "sudo systemctl reload nginx"

# --- Cleanup Old Releases (Optional) --- 
print_header "Cleaning Up Old Releases (Optional)"
RELEASES_TO_KEEP=3
print_info "Keeping the latest $RELEASES_TO_KEEP releases."
# This command lists directories in releases, sorts them, takes all but the last N, and removes them.
run_remote "cd $TARGET_BASE_DIR/releases && ls -1 | sort | head -n -$RELEASES_TO_KEEP | xargs -r rm -rf"
print_success "Old releases cleaned up."

# --- Final Summary --- 
print_header "AlphaMind Deployment Summary"
print_success "Deployment process completed successfully!"
print_success "New release is live at $TARGET_HOST (accessible via 
\"$CURRENT_SYMLINK\")"

exit 0

