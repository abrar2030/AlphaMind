#!/bin/bash

# AlphaMind Project - Environment Setup Script

# Define colors for output
COLOR_RESET=\e[0m
COLOR_GREEN=\e[32m
COLOR_RED=\e[31m
COLOR_YELLOW=\e[33m
COLOR_BLUE=\e[34m

# --- Helper Functions --- 

# Function to check if a command exists
command_exists() {
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

# --- Initialization --- 

# Exit immediately if a command exits with a non-zero status.
set -e

# Define project root directory (assuming the script is in the project root)
PROJECT_ROOT="$(pwd)"

# --- Sanity Checks --- 
print_header "Performing Prerequisite Checks"

CHECKS_PASSED=1
if ! command_exists python3.11; then
    print_error "python3.11 command not found. Please ensure Python 3.11 is installed and in your PATH."
    CHECKS_PASSED=0
fi
if ! command_exists pip3; then
    # Check for pip if pip3 doesn't exist
    if ! command_exists pip; then
        print_error "pip3 or pip command not found. Please ensure pip is installed for Python 3.11."
        CHECKS_PASSED=0
    else
        PIP_CMD="pip"
    fi
else
    PIP_CMD="pip3"
fi

if ! command_exists npm; then
    print_error "npm command not found. Please ensure Node.js and npm are installed and in your PATH."
    CHECKS_PASSED=0
fi
if ! command_exists yarn; then
    print_error "yarn command not found. Please ensure Yarn is installed globally (e.g., npm install -g yarn)."
    CHECKS_PASSED=0
fi

if [ $CHECKS_PASSED -eq 0 ]; then
    print_error "Prerequisite checks failed. Please install the missing tools and try again."
    exit 1
else
    print_success "Prerequisite checks passed."
fi

# --- Setup Execution --- 
print_header "Starting AlphaMind Environment Setup"

# --- Backend Setup --- 
print_header "Setting up Backend Environment"
BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$PROJECT_ROOT/venv" # Using a shared venv in the project root

# Check if venv directory exists, create if not
if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found at $VENV_DIR. Creating..."
    python3.11 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        print_error "Failed to create virtual environment."
        exit 1
    fi
    print_success "Virtual environment created at $VENV_DIR."
else
    echo "Virtual environment found at $VENV_DIR."
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"
if [ $? -ne 0 ]; then
    print_error "Failed to activate virtual environment."
    exit 1
fi
print_success "Virtual environment activated."

# Install/update dependencies from requirements.txt
if [ -f "$BACKEND_DIR/requirements.txt" ]; then
    echo "Installing/updating backend dependencies from $BACKEND_DIR/requirements.txt..."
    $PIP_CMD install -r "$BACKEND_DIR/requirements.txt"
    if [ $? -ne 0 ]; then
        print_error "Failed to install backend dependencies."
        deactivate
        exit 1
    fi
    print_success "Backend dependencies installed/updated."
else
    print_warning "requirements.txt not found in $BACKEND_DIR. Skipping backend dependency installation."
fi

# Deactivate venv
echo "Deactivating virtual environment."
deactivate
print_success "Backend environment setup complete."

# --- Web Frontend Setup --- 
print_header "Setting up Web Frontend Environment"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"

if [ -d "$WEB_FRONTEND_DIR" ]; then
    cd "$WEB_FRONTEND_DIR"
    if [ -f "package.json" ]; then
        echo "Installing web frontend dependencies using npm..."
        npm install
        if [ $? -ne 0 ]; then
            print_error "Failed to install web frontend dependencies."
            exit 1
        fi
        print_success "Web frontend dependencies installed."
    else
        print_warning "package.json not found in $WEB_FRONTEND_DIR. Skipping web frontend dependency installation."
    fi
    cd "$PROJECT_ROOT" # Return to root directory
else
    print_warning "Web frontend directory not found at $WEB_FRONTEND_DIR. Skipping setup."
fi
print_success "Web frontend environment setup complete."

# --- Mobile Frontend Setup --- 
print_header "Setting up Mobile Frontend Environment"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"

if [ -d "$MOBILE_FRONTEND_DIR" ]; then
    cd "$MOBILE_FRONTEND_DIR"
    if [ -f "package.json" ]; then
        echo "Installing mobile frontend dependencies using yarn..."
        yarn install
        if [ $? -ne 0 ]; then
            print_error "Failed to install mobile frontend dependencies."
            exit 1
        fi
        print_success "Mobile frontend dependencies installed."
    else
        print_warning "package.json not found in $MOBILE_FRONTEND_DIR. Skipping mobile frontend dependency installation."
    fi
    cd "$PROJECT_ROOT" # Return to root directory
else
    print_warning "Mobile frontend directory not found at $MOBILE_FRONTEND_DIR. Skipping setup."
fi
print_success "Mobile frontend environment setup complete."

# --- Final Summary --- 
print_header "AlphaMind Environment Setup Summary"
print_success "All environment setup tasks completed successfully!"

exit 0

