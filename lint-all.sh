#!/bin/bash

# AlphaMind Project - Combined Code Quality Script (Linting & Formatting)

# --- Configuration --- 

# Define project root directory (assuming the script is in the project root)
PROJECT_ROOT="$(pwd)"

# Define directories
BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$PROJECT_ROOT/venv"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"

# --- Mode --- 

# Default mode is 'check'
MODE="check"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fix)
            MODE="fix"
            shift # past argument
            ;;
        -h|--help)
            echo "Usage: $0 [--fix]"
            echo "  --fix   Apply automatic fixes for formatting and some linting issues."
            echo "  -h, --help Show this help message."
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--fix]"
            exit 1
            ;;
    esac
done

# --- Colors & Helpers --- 

# Define colors for output
COLOR_RESET=\e[0m
COLOR_GREEN=\e[32m
COLOR_RED=\e[31m
COLOR_YELLOW=\e[33m
COLOR_BLUE=\e[34m

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

# Function to print info messages
print_info() {
    echo -e "${COLOR_YELLOW}[INFO] $1${COLOR_RESET}"
}

# --- Initialization --- 

# Track overall status
OVERALL_STATUS=0 # 0 for success, 1 for failure
PYTHON_STATUS=0
WEB_FRONTEND_STATUS=0
MOBILE_FRONTEND_STATUS=0

print_info "Running in ${MODE^^} mode."

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
        echo "Checking/Installing Python code quality tools (black, isort, flake8, pylint)..."
        pip install black isort flake8 pylint
        if ! command_exists black || ! command_exists isort || ! command_exists flake8 || ! command_exists pylint; then
             print_error "Failed to install required Python tools (black, isort, flake8, pylint)."
             PYTHON_STATUS=1
             OVERALL_STATUS=1
        else
            if [ "$MODE" == "fix" ]; then
                # Run Black formatter (fix mode)
                echo "Running black formatter (fix mode)..."
                black .
                BLACK_EXIT_CODE=$?
                if [ $BLACK_EXIT_CODE -eq 0 ]; then
                    print_success "black formatting applied successfully."
                else
                    print_error "black formatting failed (code: $BLACK_EXIT_CODE)."
                    PYTHON_STATUS=1
                    OVERALL_STATUS=1
                fi

                # Run isort (fix mode)
                echo "Running isort import sorter (fix mode)..."
                isort .
                ISORT_EXIT_CODE=$?
                if [ $ISORT_EXIT_CODE -eq 0 ]; then
                    print_success "isort import sorting applied successfully."
                else
                    print_error "isort sorting failed (code: $ISORT_EXIT_CODE)."
                    PYTHON_STATUS=1
                    OVERALL_STATUS=1
                fi
                
                # Fix trailing whitespace
                echo "Fixing trailing whitespace..."
                find . -type f -name "*.py" -exec sed -i 's/[ \t]*$//' {} \;
                print_success "Trailing whitespace fixed."
                
                # Ensure newline at end of file
                echo "Ensuring newline at end of files..."
                find . -type f -name "*.py" -exec sh -c '[ -n "$(tail -c1 "$1")" ] && echo "" >> "$1"' sh {} \;
                print_success "Newline at end of files ensured."

            else # Check mode
                # Run Black format check
                echo "Running black formatter check..."
                black --check .
                BLACK_EXIT_CODE=$?
                if [ $BLACK_EXIT_CODE -eq 0 ]; then
                    print_success "black formatting check passed."
                elif [ $BLACK_EXIT_CODE -eq 1 ]; then
                    print_error "black found formatting issues. Run with --fix to fix."
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
                    print_error "isort found import sorting issues. Run with --fix to fix."
                    PYTHON_STATUS=1
                    OVERALL_STATUS=1
                else
                     print_error "isort check failed with unexpected error (code: $ISORT_EXIT_CODE)."
                     PYTHON_STATUS=1
                     OVERALL_STATUS=1
                fi
            fi

            # Run flake8 linting (always check, doesn't fix)
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
            
            # Run pylint (optional, can be noisy, check only for now)
            # Consider adding a separate flag or configuration for pylint if needed
            echo "Running pylint linter (experimental)..."
            # Using a simplified pylint command, adjust disable list as needed
            pylint --disable=C0111,C0103,C0303,W0621,C0301,W0612,W0611,R0913,R0914,R0915 $(find . -type f -name "*.py")
            PYLINT_EXIT_CODE=$?
            if [ $PYLINT_EXIT_CODE -eq 0 ]; then
                print_success "pylint linting passed."
            else
                # Pylint uses bitmask exit codes, non-zero indicates issues
                print_warning "pylint found issues (exit code: $PYLINT_EXIT_CODE). Review output."
                # Decide if pylint issues should cause overall failure
                # PYTHON_STATUS=1 
                # OVERALL_STATUS=1
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
            if [ $? -ne 0 ]; then
                print_error "npm install failed. Skipping web frontend checks."
                WEB_FRONTEND_STATUS=1
                OVERALL_STATUS=1
                cd "$PROJECT_ROOT"
                # Skip the rest of the web frontend checks
                goto web_frontend_done # Using goto equivalent with conditional block
            fi
        fi
        
        # Define commands based on mode
        if [ "$MODE" == "fix" ]; then
            LINT_CMD="npm run lint:fix --if-present"
            FORMAT_CMD="npm run format --if-present"
            LINT_FALLBACK_CMD="./node_modules/.bin/eslint --fix . --ext .js,.jsx,.ts,.tsx"
            FORMAT_FALLBACK_CMD="./node_modules/.bin/prettier --write \"**/*.{js,jsx,ts,tsx,json,css,md}\""
            LINT_ACTION="fixing"
            FORMAT_ACTION="formatting"
        else
            LINT_CMD="npm run lint --if-present"
            FORMAT_CMD="npm run format:check --if-present"
            LINT_FALLBACK_CMD="./node_modules/.bin/eslint . --ext .js,.jsx,.ts,.tsx"
            FORMAT_FALLBACK_CMD="./node_modules/.bin/prettier --check \"**/*.{js,jsx,ts,tsx,json,css,md}\""
            LINT_ACTION="checking"
            FORMAT_ACTION="checking"
        fi
        
        ESLINT_PATH="./node_modules/.bin/eslint"
        PRETTIER_PATH="./node_modules/.bin/prettier"

        # Check if specific scripts exist (more reliable than exit code of --help)
        HAS_LINT_SCRIPT=$(npm pkg get scripts.lint)
        HAS_LINT_FIX_SCRIPT=$(npm pkg get scripts."lint:fix")
        HAS_FORMAT_SCRIPT=$(npm pkg get scripts.format)
        HAS_FORMAT_CHECK_SCRIPT=$(npm pkg get scripts."format:check")

        # Run ESLint
        echo "Running ESLint $LINT_ACTION..."
        LINT_EXECUTED=0
        if [ "$MODE" == "fix" ] && [ "$HAS_LINT_FIX_SCRIPT" != "undefined" ]; then
            npm run lint:fix
            LINT_EXIT_CODE=$?
            LINT_EXECUTED=1
        elif [ "$MODE" == "check" ] && [ "$HAS_LINT_SCRIPT" != "undefined" ]; then
            npm run lint
            LINT_EXIT_CODE=$?
            LINT_EXECUTED=1
        elif [ -f "$ESLINT_PATH" ]; then
            if [ "$MODE" == "fix" ]; then
                 print_warning "'lint:fix' script not found, running ESLint directly with --fix."
                 $LINT_FALLBACK_CMD
                 LINT_EXIT_CODE=$?
                 LINT_EXECUTED=1
            elif [ "$MODE" == "check" ]; then
                 print_warning "'lint' script not found, running ESLint directly."
                 $LINT_FALLBACK_CMD
                 LINT_EXIT_CODE=$?
                 LINT_EXECUTED=1
            fi
        fi

        if [ $LINT_EXECUTED -eq 0 ]; then
             print_warning "Neither lint script nor local ESLint found. Skipping linting."
             LINT_EXIT_CODE=0 # Treat as skipped
        elif [ $LINT_EXIT_CODE -ne 0 ]; then
            print_error "ESLint found issues or failed (exit code: $LINT_EXIT_CODE)."
            WEB_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "ESLint $LINT_ACTION passed."
        fi

        # Run Prettier
        echo "Running Prettier $FORMAT_ACTION..."
        FORMAT_EXECUTED=0
        if [ "$MODE" == "fix" ] && [ "$HAS_FORMAT_SCRIPT" != "undefined" ]; then
            npm run format
            FORMAT_EXIT_CODE=$?
            FORMAT_EXECUTED=1
        elif [ "$MODE" == "check" ] && [ "$HAS_FORMAT_CHECK_SCRIPT" != "undefined" ]; then
            npm run format:check
            FORMAT_EXIT_CODE=$?
            FORMAT_EXECUTED=1
        elif [ -f "$PRETTIER_PATH" ]; then
             if [ "$MODE" == "fix" ]; then
                 print_warning "'format' script not found, running Prettier directly with --write."
                 $FORMAT_FALLBACK_CMD
                 FORMAT_EXIT_CODE=$?
                 FORMAT_EXECUTED=1
             elif [ "$MODE" == "check" ]; then
                 print_warning "'format:check' script not found, running Prettier directly with --check."
                 $FORMAT_FALLBACK_CMD
                 FORMAT_EXIT_CODE=$?
                 FORMAT_EXECUTED=1
             fi
        fi
        
        if [ $FORMAT_EXECUTED -eq 0 ]; then
            print_warning "Neither format script nor local Prettier found. Skipping format check."
            FORMAT_EXIT_CODE=0 # Treat as skipped
        elif [ $FORMAT_EXIT_CODE -ne 0 ]; then
            print_error "Prettier found issues or failed (exit code: $FORMAT_EXIT_CODE). Run with --fix or manually to fix."
            WEB_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "Prettier $FORMAT_ACTION passed."
        fi
    fi
    :web_frontend_done # Label for goto jump
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Mobile Frontend Code Quality (JavaScript/TypeScript) --- 
print_header "Running Mobile Frontend Code Quality Checks (JS/TS)"

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
            if [ $? -ne 0 ]; then
                print_error "yarn install failed. Skipping mobile frontend checks."
                MOBILE_FRONTEND_STATUS=1
                OVERALL_STATUS=1
                cd "$PROJECT_ROOT"
                goto mobile_frontend_done # Using goto equivalent
            fi
        fi
        
        # Define commands based on mode
        if [ "$MODE" == "fix" ]; then
            LINT_CMD="yarn run lint:fix --if-present"
            FORMAT_CMD="yarn run format --if-present"
            LINT_FALLBACK_CMD="./node_modules/.bin/eslint --fix . --ext .js,.jsx,.ts,.tsx"
            FORMAT_FALLBACK_CMD="./node_modules/.bin/prettier --write \"**/*.{js,jsx,ts,tsx,json,css,md}\""
            LINT_ACTION="fixing"
            FORMAT_ACTION="formatting"
        else
            LINT_CMD="yarn run lint --if-present"
            FORMAT_CMD="yarn run format:check --if-present"
            LINT_FALLBACK_CMD="./node_modules/.bin/eslint . --ext .js,.jsx,.ts,.tsx"
            FORMAT_FALLBACK_CMD="./node_modules/.bin/prettier --check \"**/*.{js,jsx,ts,tsx,json,css,md}\""
            LINT_ACTION="checking"
            FORMAT_ACTION="checking"
        fi
        
        ESLINT_PATH="./node_modules/.bin/eslint"
        PRETTIER_PATH="./node_modules/.bin/prettier"

        # Check if specific scripts exist (more reliable than exit code of --help)
        # Note: yarn pkg is not a standard command, using grep on yarn run output
        HAS_LINT_SCRIPT=$(yarn run | grep -qE '^\s*lint\s' && echo true || echo false)
        HAS_LINT_FIX_SCRIPT=$(yarn run | grep -qE '^\s*lint:fix\s' && echo true || echo false)
        HAS_FORMAT_SCRIPT=$(yarn run | grep -qE '^\s*format\s' && echo true || echo false)
        HAS_FORMAT_CHECK_SCRIPT=$(yarn run | grep -qE '^\s*format:check\s' && echo true || echo false)

        # Run ESLint
        echo "Running ESLint $LINT_ACTION..."
        LINT_EXECUTED=0
        if [ "$MODE" == "fix" ] && [ "$HAS_LINT_FIX_SCRIPT" == true ]; then
            yarn run lint:fix
            LINT_EXIT_CODE=$?
            LINT_EXECUTED=1
        elif [ "$MODE" == "check" ] && [ "$HAS_LINT_SCRIPT" == true ]; then
            yarn run lint
            LINT_EXIT_CODE=$?
            LINT_EXECUTED=1
        elif [ -f "$ESLINT_PATH" ]; then
            if [ "$MODE" == "fix" ]; then
                 print_warning "'lint:fix' script not found, running ESLint directly with --fix."
                 $LINT_FALLBACK_CMD
                 LINT_EXIT_CODE=$?
                 LINT_EXECUTED=1
            elif [ "$MODE" == "check" ]; then
                 print_warning "'lint' script not found, running ESLint directly."
                 $LINT_FALLBACK_CMD
                 LINT_EXIT_CODE=$?
                 LINT_EXECUTED=1
            fi
        fi

        if [ $LINT_EXECUTED -eq 0 ]; then
             print_warning "Neither lint script nor local ESLint found. Skipping linting."
             LINT_EXIT_CODE=0 # Treat as skipped
        elif [ $LINT_EXIT_CODE -ne 0 ]; then
            print_error "ESLint found issues or failed (exit code: $LINT_EXIT_CODE)."
            MOBILE_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "ESLint $LINT_ACTION passed."
        fi

        # Run Prettier
        echo "Running Prettier $FORMAT_ACTION..."
        FORMAT_EXECUTED=0
        if [ "$MODE" == "fix" ] && [ "$HAS_FORMAT_SCRIPT" == true ]; then
            yarn run format
            FORMAT_EXIT_CODE=$?
            FORMAT_EXECUTED=1
        elif [ "$MODE" == "check" ] && [ "$HAS_FORMAT_CHECK_SCRIPT" == true ]; then
            yarn run format:check
            FORMAT_EXIT_CODE=$?
            FORMAT_EXECUTED=1
        elif [ -f "$PRETTIER_PATH" ]; then
             if [ "$MODE" == "fix" ]; then
                 print_warning "'format' script not found, running Prettier directly with --write."
                 $FORMAT_FALLBACK_CMD
                 FORMAT_EXIT_CODE=$?
                 FORMAT_EXECUTED=1
             elif [ "$MODE" == "check" ]; then
                 print_warning "'format:check' script not found, running Prettier directly with --check."
                 $FORMAT_FALLBACK_CMD
                 FORMAT_EXIT_CODE=$?
                 FORMAT_EXECUTED=1
             fi
        fi
        
        if [ $FORMAT_EXECUTED -eq 0 ]; then
            print_warning "Neither format script nor local Prettier found. Skipping format check."
            FORMAT_EXIT_CODE=0 # Treat as skipped
        elif [ $FORMAT_EXIT_CODE -ne 0 ]; then
            print_error "Prettier found issues or failed (exit code: $FORMAT_EXIT_CODE). Run with --fix or manually to fix."
            MOBILE_FRONTEND_STATUS=1
            OVERALL_STATUS=1
        else
            print_success "Prettier $FORMAT_ACTION passed."
        fi
    fi
    :mobile_frontend_done # Label for goto jump
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Final Summary --- 
print_header "Code Quality Check Summary (Mode: ${MODE^^})"

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

