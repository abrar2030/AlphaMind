#!/bin/bash

# AlphaMind Project - Unified Test Runner Script

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

# Define project root directory (assuming the script is in the project root)
PROJECT_ROOT="$(pwd)"

# Track overall test status
OVERALL_STATUS=0 # 0 for success, 1 for failure
BACKEND_STATUS=0
WEB_FRONTEND_STATUS=0
MOBILE_FRONTEND_STATUS=0

# --- Sanity Checks --- 
print_header "Performing Environment Checks"

CHECKS_PASSED=1
if ! command_exists python3.11; then
    print_error "python3.11 command not found. Please ensure Python 3.11 is installed and in your PATH."
    CHECKS_PASSED=0
fi
if ! command_exists npm; then
    print_error "npm command not found. Please ensure Node.js and npm are installed and in your PATH."
    CHECKS_PASSED=0
fi
if ! command_exists yarn; then
    print_error "yarn command not found. Please ensure Yarn is installed globally (npm install -g yarn)."
    CHECKS_PASSED=0
fi

if [ $CHECKS_PASSED -eq 0 ]; then
    exit 1
else
    print_success "Environment checks passed."
fi

# --- Test Execution --- 
print_header "Starting AlphaMind Test Suite"

# --- Backend Tests --- 
print_header "Running Backend Tests"
BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$PROJECT_ROOT/venv" # Corrected venv path

cd "$BACKEND_DIR"

# Check and activate virtual environment
if [ -d "$VENV_DIR/bin" ]; then
    echo "Activating backend virtual environment from $VENV_DIR..."
    source "$VENV_DIR/bin/activate"
    print_success "Backend venv activated."
    
    # Check for requirements.txt and install dependencies
    if [ -f "requirements.txt" ]; then
        echo "Installing/updating backend dependencies from requirements.txt..."
        pip install -r requirements.txt
    else
        print_warning "requirements.txt not found in $BACKEND_DIR. Skipping dependency installation."
    fi
    
    # Check if pytest is installed
    if ! command_exists pytest; then
        print_error "pytest command not found within the virtual environment. Please ensure it is listed in requirements.txt."
        deactivate
        BACKEND_STATUS=1
        OVERALL_STATUS=1
    else
        # Run pytest
        echo "Running pytest..."
        # Run pytest but don't exit script on failure; capture status instead
        pytest tests
        PYTEST_EXIT_CODE=$?
        if [ $PYTEST_EXIT_CODE -ne 0 ]; then
            print_error "Backend tests failed (pytest exit code: $PYTEST_EXIT_CODE)."
            BACKEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "Backend tests passed."
        fi
    fi
    
    # Deactivate venv
    echo "Deactivating backend venv."
    deactivate
else
    print_error "Backend virtual environment not found at $VENV_DIR"
    print_error "Please create it first, e.g., by running: python3.11 -m venv $VENV_DIR"
    BACKEND_STATUS=1
    OVERALL_STATUS=1
fi

# --- Web Frontend Tests --- 
print_header "Running Web Frontend Tests"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"
cd "$WEB_FRONTEND_DIR"

# Check if node_modules exists, install if not
if [ ! -d "node_modules" ]; then
    echo "Web frontend node_modules not found. Installing dependencies with npm..."
    npm install
fi

# Check if test script exists in package.json
if ! npm run test -- --help > /dev/null 2>&1; then 
    print_warning "'test' script not found or configured in web-frontend/package.json. Attempting to run Jest directly."
    # Check if jest is installed locally
    if [ -f "./node_modules/.bin/jest" ]; then
        echo "Running local Jest..."
        ./node_modules/.bin/jest
        JEST_EXIT_CODE=$?
    else
        print_error "Cannot find 'test' script or local Jest executable in web-frontend."
        JEST_EXIT_CODE=1 # Simulate failure
    fi
else
    # Run npm test
    echo "Running npm test..."
    npm test
    JEST_EXIT_CODE=$?
fi

if [ $JEST_EXIT_CODE -ne 0 ]; then
    print_error "Web frontend tests failed (exit code: $JEST_EXIT_CODE)."
    WEB_FRONTEND_STATUS=1
    OVERALL_STATUS=1
else
    print_success "Web frontend tests passed."
fi

# --- Mobile Frontend Tests --- 
print_header "Running Mobile Frontend Tests"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"
cd "$MOBILE_FRONTEND_DIR"

# Check if node_modules exists, install if not
if [ ! -d "node_modules" ]; then
    echo "Mobile frontend node_modules not found. Installing dependencies with yarn..."
    yarn install
fi

# Check if test script exists in package.json
if ! yarn run test -- --help > /dev/null 2>&1; then
    print_warning "'test' script not found or configured in mobile-frontend/package.json. Attempting to run Jest directly."
     # Check if jest is installed locally
    if [ -f "./node_modules/.bin/jest" ]; then
        echo "Running local Jest..."
        ./node_modules/.bin/jest
        YARN_JEST_EXIT_CODE=$?
    else
        print_error "Cannot find 'test' script or local Jest executable in mobile-frontend."
        YARN_JEST_EXIT_CODE=1 # Simulate failure
    fi
else
    # Run yarn test
    echo "Running yarn test..."
    yarn test
    YARN_JEST_EXIT_CODE=$?
fi

if [ $YARN_JEST_EXIT_CODE -ne 0 ]; then
    print_error "Mobile frontend tests failed (exit code: $YARN_JEST_EXIT_CODE)."
    MOBILE_FRONTEND_STATUS=1
    OVERALL_STATUS=1
else
    print_success "Mobile frontend tests passed."
fi

# --- Final Summary --- 
print_header "AlphaMind Test Suite Summary"

echo -n "Backend Tests:         "
if [ $BACKEND_STATUS -eq 0 ]; then print_success "Passed"; else print_error "Failed"; fi

echo -n "Web Frontend Tests:    "
if [ $WEB_FRONTEND_STATUS -eq 0 ]; then print_success "Passed"; else print_error "Failed"; fi

echo -n "Mobile Frontend Tests: "
if [ $MOBILE_FRONTEND_STATUS -eq 0 ]; then print_success "Passed"; else print_error "Failed"; fi

echo -e "\n-------------------------------------"
if [ $OVERALL_STATUS -eq 0 ]; then
    print_success "All test suites completed successfully!"
    exit 0
else
    print_error "One or more test suites failed."
    exit 1
fi

