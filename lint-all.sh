#!/bin/bash

# AlphaMind Project - Comprehensive Code Quality Script
# Version 2.1 - Full Error Resolution Edition

# --- Configuration ---
PROJECT_ROOT="$(pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
VENV_DIR="$PROJECT_ROOT/venv"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"
CONFIG_DIR="$PROJECT_ROOT/config"
PYTHON_VERSION="3.10"

# Create necessary directories
mkdir -p "$CONFIG_DIR"

# --- Generate Configuration Files ---
cat > "$PROJECT_ROOT/pyproject.toml" <<EOL
[tool.black]
line-length = 88
target-version = ['py310']
include = '\.pyi?$'
exclude = '''
/(
    \.git
  | \.venv
  | build
  | dist
)/'
extend-exclude = '\.ipynb_checkpoints'

[tool.isort]
profile = "black"
line_length = 88
force_sort_within_sections = true
known_first_party = ["alphamind"]

[tool.flake8]
max-line-length = 88
extend-ignore = E203
exclude = "venv,.git,__pycache__,docs/source/conf.py,old,build,dist"
per-file-ignores =
    __init__.py:F401

[tool.pylint.MASTER]
extension-pkg-whitelist = tensorflow.keras
EOL

cat > "$CONFIG_DIR/.pylintrc" <<EOL
[MASTER]
extension-pkg-whitelist=tensorflow.keras
ignore-patterns=test_.*?py

[FORMAT]
max-line-length=88
EOL

# --- Colors & Helpers ---
COLOR_RESET="\033[0m"
COLOR_GREEN="\033[32m"
COLOR_RED="\033[31m"
COLOR_YELLOW="\033[33m"
COLOR_BLUE="\033[34m"

print_header() {
    echo -e "\n${COLOR_BLUE}==================================================${COLOR_RESET}"
    echo -e "${COLOR_BLUE} $1 ${COLOR_RESET}"
    echo -e "${COLOR_BLUE}==================================================${COLOR_RESET}"
}

print_success() {
    echo -e "${COLOR_GREEN}[SUCCESS] $1${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_RED}[ERROR] $1${COLOR_RESET}" >&2
}

print_warning() {
    echo -e "${COLOR_YELLOW}[WARNING] $1${COLOR_RESET}"
}

print_info() {
    echo -e "${COLOR_YELLOW}[INFO] $1${COLOR_RESET}"
}

# --- Initialization ---
MODE="check"
OVERALL_STATUS=0
PYTHON_STATUS=0
WEB_FRONTEND_STATUS=0
MOBILE_FRONTEND_STATUS=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fix) MODE="fix"; shift ;;
        -h|--help)
            echo "Usage: $0 [--fix]"
            echo "  --fix   Apply automatic fixes"
            exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

print_info "Running in ${MODE^^} mode"

# --- Prerequisite Checks ---
print_header "System Prerequisite Checks"

check_python() {
    if ! command -v "python${PYTHON_VERSION}" &>/dev/null; then
        print_error "Python ${PYTHON_VERSION} not found. Install with:"
        print_error "sudo apt install python${PYTHON_VERSION} python${PYTHON_VERSION}-venv"
        return 1
    fi
    return 0
}

check_node() {
    if ! command -v node &>/dev/null; then
        print_error "Node.js not found. Install from: https://nodejs.org"
        return 1
    fi
    return 0
}

check_python || OVERALL_STATUS=1
check_node || OVERALL_STATUS=1

if [ $OVERALL_STATUS -ne 0 ]; then
    print_error "Critical prerequisites missing. Aborting."
    exit 1
fi

# --- Backend Quality Checks ---
print_header "Python Code Quality Engine"

run_python_checks() {
    local status=0
    cd "$BACKEND_DIR" || return 1

    if [ ! -d "$VENV_DIR" ]; then
        python${PYTHON_VERSION} -m venv "$VENV_DIR"
    fi

    source "$VENV_DIR/bin/activate"
    pip install -U pip setuptools wheel
    pip install black[jupyter] isort flake8 pylint autoflake tensorflow numpy
    
    # Pre-flight syntax check
    if ! python -m py_compile $(find . -name "*.py"); then
        print_error "Critical syntax errors detected. Fix these first."
        status=1
    fi

    if [ "$MODE" == "fix" ]; then
        print_info "Running deep code cleanup..."
        autoflake --in-place --remove-all-unused-imports --remove-unused-variables --recursive .
        
        print_info "Formatting code with Black..."
        black --experimental-string-processing .
        
        print_info "Optimizing imports..."
        isort --settings-file="$PROJECT_ROOT/pyproject.toml" .
        
        print_info "Cleaning whitespace..."
        find . -type f -name "*.py" -exec sed -i 's/[ \t]*$//' {} \;
        find . -type f -name "*.py" -exec sed -i -e '$a\' {} \;
    else
        black --check --experimental-string-processing . || status=1
        isort --check-only --settings-file="$PROJECT_ROOT/pyproject.toml" . || status=1
    fi

    print_info "Running advanced linting..."
    flake8 --config="$PROJECT_ROOT/pyproject.toml" . || status=1
    
    print_info "Running static analysis..."
    pylint --rcfile="$CONFIG_DIR/.pylintrc" \
        --disable=C0111,C0103,W0621,W0612,R0913,R0914,R0915 \
        $(find . -name "*.py") || status=1

    deactivate
    return $status
}

if [ -d "$BACKEND_DIR" ]; then
    run_python_checks || PYTHON_STATUS=1
else
    print_warning "Backend directory missing"
    PYTHON_STATUS=2
fi

[ $PYTHON_STATUS -ne 0 ] && OVERALL_STATUS=1

# --- Frontend Quality Checks ---
print_header "JavaScript/TypeScript Quality Checks"

run_frontend_checks() {
    local dir=$1
    local type=$2
    local status=0
    
    cd "$dir" || return 2
    [ ! -f "package.json" ] && return 2
    
    if [ ! -d "node_modules" ]; then
        print_info "Installing dependencies..."
        npm install || yarn install || return 1
    fi

    local eslint_cmd="npx eslint"
    local prettier_cmd="npx prettier"
    
    if [ "$MODE" == "fix" ]; then
        $eslint_cmd --fix --ext .js,.jsx,.ts,.tsx . || status=1
        $prettier_cmd --write "**/*.{js,jsx,ts,tsx,json,css,md}" || status=1
    else
        $eslint_cmd --ext .js,.jsx,.ts,.tsx . || status=1
        $prettier_cmd --check "**/*.{js,jsx,ts,tsx,json,css,md}" || status=1
    fi

    return $status
}

# Web Frontend
print_info "Checking Web Frontend..."
if [ -d "$WEB_FRONTEND_DIR" ]; then
    run_frontend_checks "$WEB_FRONTEND_DIR" "Web" || WEB_FRONTEND_STATUS=1
else
    print_warning "Web frontend directory missing"
    WEB_FRONTEND_STATUS=2
fi

# Mobile Frontend
print_info "Checking Mobile Frontend..."
if [ -d "$MOBILE_FRONTEND_DIR" ]; then
    run_frontend_checks "$MOBILE_FRONTEND_DIR" "Mobile" || MOBILE_FRONTEND_STATUS=1
else
    print_warning "Mobile frontend directory missing"
    MOBILE_FRONTEND_STATUS=2
fi

# --- Final Report ---
print_header "Validation Summary"

report_status() {
    case $1 in
        0) echo -e "${COLOR_GREEN}PASS${COLOR_RESET}" ;;
        1) echo -e "${COLOR_RED}FAIL${COLOR_RESET}" ;;
        2) echo -e "${COLOR_YELLOW}SKIP${COLOR_RESET}" ;;
        *) echo -e "${COLOR_RED}UNKNOWN${COLOR_RESET}" ;;
    esac
}

echo -e "Python Backend:        $(report_status $PYTHON_STATUS)"
echo -e "Web Frontend:         $(report_status $WEB_FRONTEND_STATUS)"
echo -e "Mobile Frontend:      $(report_status $MOBILE_FRONTEND_STATUS)"

exit $OVERALL_STATUS