#!/bin/bash

# AlphaMind Project - Enhanced Code Quality Script (Linting & Formatting)

# Define colors for output
COLOR_RESET=\e[0m
COLOR_GREEN=\e[32m
COLOR_RED=\e[31m
COLOR_YELLOW=\e[33m
COLOR_BLUE=\e[34m

# --- Helper Functions --- 

# Function to check if a command exists (globally or in venv/node_modules)
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

# Track overall status
OVERALL_STATUS=0 # 0 for success, 1 for failure
PYTHON_STATUS=0
WEB_FRONTEND_STATUS=0
MOBILE_FRONTEND_STATUS=0

# --- Prerequisite Checks --- 
print_header "Performing Prerequisite Checks"

CHECKS_PASSED=1
# Check for Python tools (will be checked within venv later)
if ! command_exists python3.11; then
    print_error "python3.11 command not found. Please ensure Python 3.11 is installed."
    CHECKS_PASSED=0
fi
# Check for Node tools (will be checked in respective directories later)
if ! command_exists npm; then
    print_error "npm command not found. Please ensure Node.js and npm are installed."
    CHECKS_PASSED=0
fi
if ! command_exists yarn; then
    print_error "yarn command not found. Please ensure Yarn is installed globally."
    CHECKS_PASSED=0
fi

if [ $CHECKS_PASSED -eq 0 ]; then
    print_error "Prerequisite checks failed. Please install the missing base tools."
    exit 1
else
    print_success "Base prerequisite checks passed."
fi

# --- Backend Code Quality (Python) --- 
print_header "Running Backend Code Quality Checks (Python)"
BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$PROJECT_ROOT/venv"

if [ ! -d "$BACKEND_DIR" ]; then
    print_warning "Backend directory not found at $BACKEND_DIR. Skipping backend checks."
    PYTHON_STATUS=2 # Use 2 for skipped
else
    cd "$BACKEND_DIR"
    # Activate virtual environment
    if [ -d "$VENV_DIR/bin" ]; then
        echo "Activating backend virtual environment from $VENV_DIR..."
        source "$VENV_DIR/bin/activate"
        
        # Install/Check Python tools
        echo "Checking/Installing Python code quality tools (black, isort, flake8)..."
        pip install black isort flake8
        if ! command_exists black || ! command_exists isort || ! command_exists flake8; then
             print_error "Failed to install required Python tools (black, isort, flake8)."
             PYTHON_STATUS=1
             OVERALL_STATUS=1
        else
            # Run Black format check
            echo "Running black formatter check..."
            black --check .
            BLACK_EXIT_CODE=$?
            if [ $BLACK_EXIT_CODE -eq 0 ]; then
                print_success "black formatting check passed."
            elif [ $BLACK_EXIT_CODE -eq 1 ]; then
                print_error "black found formatting issues. Run 'black .' in '$BACKEND_DIR' to fix."
                PYTHON_STATUS=1
                OVERALL_STATUS=1
            else
                print_error "black check failed with unexpected error (code: $BLACK_EXIT_CODE)."
                PYTHON_STATUS=1
                OVERALL_STATUS=1
            fi

            # Run isort check
            echo "Running isort import sorting check..."
            isort --check-only .
            ISORT_EXIT_CODE=$?
            if [ $ISORT_EXIT_CODE -eq 0 ]; then
                print_success "isort import sorting check passed."
            elif [ $ISORT_EXIT_CODE -eq 1 ]; then
                print_error "isort found import sorting issues. Run 'isort .' in '$BACKEND_DIR' to fix."
                PYTHON_STATUS=1
                OVERALL_STATUS=1
            else
                 print_error "isort check failed with unexpected error (code: $ISORT_EXIT_CODE)."
                 PYTHON_STATUS=1
                 OVERALL_STATUS=1
            fi

            # Run flake8 linting
            echo "Running flake8 linter..."
            flake8 .
            FLAKE8_EXIT_CODE=$?
            if [ $FLAKE8_EXIT_CODE -eq 0 ]; then
                print_success "flake8 linting passed."
            else
                print_error "flake8 found linting issues."
                PYTHON_STATUS=1
                OVERALL_STATUS=1
            fi
        fi
        
        # Deactivate venv
        echo "Deactivating backend venv."
        deactivate
    else
        print_error "Backend virtual environment not found at $VENV_DIR. Skipping backend checks."
        print_error "Please run the environment setup script first."
        PYTHON_STATUS=1 # Treat missing venv as failure
        OVERALL_STATUS=1
    fi
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Web Frontend Code Quality (JavaScript/TypeScript) --- 
print_header "Running Web Frontend Code Quality Checks (JS/TS)"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"

if [ ! -d "$WEB_FRONTEND_DIR" ]; then
    print_warning "Web frontend directory not found at $WEB_FRONTEND_DIR. Skipping web frontend checks."
    WEB_FRONTEND_STATUS=2 # Skipped
else
    cd "$WEB_FRONTEND_DIR"
    if [ ! -f "package.json" ]; then
        print_warning "package.json not found in $WEB_FRONTEND_DIR. Skipping web frontend checks."
        WEB_FRONTEND_STATUS=2 # Skipped
    else
        # Install dependencies if node_modules doesn't exist
        if [ ! -d "node_modules" ]; then
            echo "Installing web frontend dependencies with npm..."
            npm install
        fi
        
        # Check for lint and format scripts in package.json (common practice)
        LINT_CMD="npm run lint --if-present"
        FORMAT_CHECK_CMD="npm run format:check --if-present"
        
        # Fallback to direct execution if scripts don't exist (requires tools installed)
        # This assumes eslint and prettier are dev dependencies
        ESLINT_PATH="./node_modules/.bin/eslint"
        PRETTIER_PATH="./node_modules/.bin/prettier"

        HAS_LINT_SCRIPT=$(npm run lint -- --help > /dev/null 2>&1 && echo true || echo false)
        HAS_FORMAT_SCRIPT=$(npm run format:check -- --help > /dev/null 2>&1 && echo true || echo false)

        # Run ESLint
        echo "Running ESLint check..."
        if [ "$HAS_LINT_SCRIPT" = true ]; then
            $LINT_CMD
            LINT_EXIT_CODE=$?
        elif [ -f "$ESLINT_PATH" ]; then
            print_warning "'lint' script not found, running ESLint directly."
            $ESLINT_PATH . --ext .js,.jsx,.ts,.tsx
            LINT_EXIT_CODE=$?
        else
            print_warning "Neither 'lint' script nor local ESLint found. Skipping linting."
            LINT_EXIT_CODE=0 # Treat as skipped, not failure for now
        fi
        
        if [ $LINT_EXIT_CODE -ne 0 ]; then
            print_error "ESLint found issues."
            WEB_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "ESLint check passed or skipped."
        fi

        # Run Prettier format check
        echo "Running Prettier format check..."
        if [ "$HAS_FORMAT_SCRIPT" = true ]; then
             $FORMAT_CHECK_CMD
             FORMAT_EXIT_CODE=$?
        elif [ -f "$PRETTIER_PATH" ]; then
            print_warning "'format:check' script not found, running Prettier directly."
            $PRETTIER_PATH --check "**/*.{js,jsx,ts,tsx,json,css,md}"
            FORMAT_EXIT_CODE=$?
        else
            print_warning "Neither 'format:check' script nor local Prettier found. Skipping format check."
            FORMAT_EXIT_CODE=0 # Treat as skipped
        fi

        if [ $FORMAT_EXIT_CODE -ne 0 ]; then
            print_error "Prettier found formatting issues. Run 'npm run format' or Prettier manually to fix."
            WEB_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "Prettier format check passed or skipped."
        fi
    fi
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Mobile Frontend Code Quality (JavaScript/TypeScript) --- 
print_header "Running Mobile Frontend Code Quality Checks (JS/TS)"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"

if [ ! -d "$MOBILE_FRONTEND_DIR" ]; then
    print_warning "Mobile frontend directory not found at $MOBILE_FRONTEND_DIR. Skipping mobile frontend checks."
    MOBILE_FRONTEND_STATUS=2 # Skipped
else
    cd "$MOBILE_FRONTEND_DIR"
    if [ ! -f "package.json" ]; then
        print_warning "package.json not found in $MOBILE_FRONTEND_DIR. Skipping mobile frontend checks."
        MOBILE_FRONTEND_STATUS=2 # Skipped
    else
        # Install dependencies if node_modules doesn't exist
        if [ ! -d "node_modules" ]; then
            echo "Installing mobile frontend dependencies with yarn..."
            yarn install
        fi
        
        # Check for lint and format scripts in package.json
        LINT_CMD="yarn run lint --if-present"
        FORMAT_CHECK_CMD="yarn run format:check --if-present"
        
        ESLINT_PATH="./node_modules/.bin/eslint"
        PRETTIER_PATH="./node_modules/.bin/prettier"

        HAS_LINT_SCRIPT=$(yarn run lint -- --help > /dev/null 2>&1 && echo true || echo false)
        HAS_FORMAT_SCRIPT=$(yarn run format:check -- --help > /dev/null 2>&1 && echo true || echo false)

        # Run ESLint
        echo "Running ESLint check..."
        if [ "$HAS_LINT_SCRIPT" = true ]; then
            $LINT_CMD
            LINT_EXIT_CODE=$?
        elif [ -f "$ESLINT_PATH" ]; then
            print_warning "'lint' script not found, running ESLint directly."
            $ESLINT_PATH . --ext .js,.jsx,.ts,.tsx
            LINT_EXIT_CODE=$?
        else
            print_warning "Neither 'lint' script nor local ESLint found. Skipping linting."
            LINT_EXIT_CODE=0 # Skipped
        fi
        
        if [ $LINT_EXIT_CODE -ne 0 ]; then
            print_error "ESLint found issues."
            MOBILE_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "ESLint check passed or skipped."
        fi

        # Run Prettier format check
        echo "Running Prettier format check..."
        if [ "$HAS_FORMAT_SCRIPT" = true ]; then
             $FORMAT_CHECK_CMD
             FORMAT_EXIT_CODE=$?
        elif [ -f "$PRETTIER_PATH" ]; then
            print_warning "'format:check' script not found, running Prettier directly."
            $PRETTIER_PATH --check "**/*.{js,jsx,ts,tsx,json,css,md}"
            FORMAT_EXIT_CODE=$?
        else
            print_warning "Neither 'format:check' script nor local Prettier found. Skipping format check."
            FORMAT_EXIT_CODE=0 # Skipped
        fi

        if [ $FORMAT_EXIT_CODE -ne 0 ]; then
            print_error "Prettier found formatting issues. Run 'yarn run format' or Prettier manually to fix."
            MOBILE_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "Prettier format check passed or skipped."
        fi
    fi
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Final Summary --- 
print_header "Code Quality Check Summary"

# Function to print status based on code (0=Success, 1=Failed, 2=Skipped)
print_status() {
    case $1 in
        0) print_success "Passed" ;;
        1) print_error   "Failed" ;;
        2) print_warning "Skipped";;
        *) print_error   "Unknown";;
    esac
}

echo -n "Backend Checks:         "
print_status $PYTHON_STATUS

echo -n "Web Frontend Checks:    "
print_status $WEB_FRONTEND_STATUS

echo -n "Mobile Frontend Checks: "
print_status $MOBILE_FRONTEND_STATUS

echo -e "\n-------------------------------------"
if [ $OVERALL_STATUS -eq 0 ]; then
    print_success "All code quality checks passed or were skipped without error!"
    exit 0
else
    print_error "One or more code quality checks failed."
    exit 1
fi

