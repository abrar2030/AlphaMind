#!/bin/bash

# AlphaMind Project - Build Script

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
BUILD_DIR="$PROJECT_ROOT/build"

# Track overall status (though set -e handles failures)

# --- Prerequisite Checks --- 
print_header "Performing Prerequisite Checks"

CHECKS_PASSED=1
# Check for Python tools
if ! command_exists python3.11; then
    print_error "python3.11 command not found. Please ensure Python 3.11 is installed."
    CHECKS_PASSED=0
fi
# Check for Node tools
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

# --- Clean and Create Build Directory --- 
print_header "Preparing Build Directory"
echo "Removing old build directory (if exists)..."
rm -rf "$BUILD_DIR"
echo "Creating new build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
print_success "Build directory prepared."

# --- Build Execution --- 
print_header "Starting AlphaMind Build Process"

# --- Web Frontend Build --- 
print_header "Building Web Frontend"
WEB_FRONTEND_DIR="$PROJECT_ROOT/web-frontend"
WEB_BUILD_OUTPUT_DIR="$BUILD_DIR/web"

if [ ! -d "$WEB_FRONTEND_DIR" ]; then
    print_warning "Web frontend directory not found at $WEB_FRONTEND_DIR. Skipping build."
else
    cd "$WEB_FRONTEND_DIR"
    if [ ! -f "package.json" ]; then
        print_warning "package.json not found in $WEB_FRONTEND_DIR. Skipping build."
    else
        echo "Installing web frontend dependencies (if needed)..."
        npm install --prefer-offline --no-audit --progress=false
        
        echo "Running web frontend build command (npm run build)..."
        # Check if build script exists
        if npm run build -- --help > /dev/null 2>&1; then
            npm run build
            # Assuming build output is in a standard directory like 'dist' or 'build'
            # Adjust this based on the actual project configuration
            BUILD_SOURCE_DIR="dist" # Default assumption
            if [ -d "build" ]; then
                BUILD_SOURCE_DIR="build"
            fi
            
            if [ -d "$BUILD_SOURCE_DIR" ]; then
                echo "Copying build artifacts to $WEB_BUILD_OUTPUT_DIR..."
                mkdir -p "$WEB_BUILD_OUTPUT_DIR"
                # Use cp instead of rsync
                cp -r "$BUILD_SOURCE_DIR"/* "$WEB_BUILD_OUTPUT_DIR/"
                print_success "Web frontend build completed and copied."
            else
                print_error "Web frontend build completed, but output directory (\"$BUILD_SOURCE_DIR\") not found."
                exit 1
            fi
        else
            print_warning "No 'build' script found in web-frontend/package.json. Skipping build."
        fi
    fi
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Mobile Frontend Build (Web Export) --- 
print_header "Building Mobile Frontend (Web Export)"
MOBILE_FRONTEND_DIR="$PROJECT_ROOT/mobile-frontend"
MOBILE_BUILD_OUTPUT_DIR="$BUILD_DIR/mobile"

if [ ! -d "$MOBILE_FRONTEND_DIR" ]; then
    print_warning "Mobile frontend directory not found at $MOBILE_FRONTEND_DIR. Skipping build."
else
    cd "$MOBILE_FRONTEND_DIR"
    if [ ! -f "package.json" ]; then
        print_warning "package.json not found in $MOBILE_FRONTEND_DIR. Skipping build."
    else
        echo "Installing mobile frontend dependencies (if needed)..."
        yarn install --prefer-offline
        
        echo "Running mobile frontend web export command (npx expo export --platform web)..."
        # Check if expo is available
        if command_exists npx; then
             # Use npx to run local expo-cli if available
             npx expo export --platform web --output-dir "web-build"
             
             if [ -d "web-build" ]; then
                 echo "Copying build artifacts to $MOBILE_BUILD_OUTPUT_DIR..."
                 mkdir -p "$MOBILE_BUILD_OUTPUT_DIR"
                 # Use cp instead of rsync
                 cp -r web-build/* "$MOBILE_BUILD_OUTPUT_DIR/"
                 print_success "Mobile frontend web export completed and copied."
             else
                 print_error "Mobile frontend web export completed, but output directory (\"web-build\") not found."
                 exit 1
             fi
        else
             print_error "npx command not found. Cannot run expo export. Skipping mobile build."
        fi
    fi
    cd "$PROJECT_ROOT" # Return to root
fi

# --- Backend Packaging --- 
print_header "Packaging Backend"
BACKEND_DIR="$PROJECT_ROOT/backend"
BACKEND_BUILD_OUTPUT_DIR="$BUILD_DIR/backend"

if [ ! -d "$BACKEND_DIR" ]; then
    print_warning "Backend directory not found at $BACKEND_DIR. Skipping packaging."
else
    echo "Creating backend package directory: $BACKEND_BUILD_OUTPUT_DIR"
    mkdir -p "$BACKEND_BUILD_OUTPUT_DIR"
    
    echo "Copying backend source files using cp..."
    # Use cp -r for directories, cp for files. Handle exclusions manually.
    # Copy main directories
    for item in ai_models alpha_research alternative_data execution_engine infrastructure risk_system; do
        if [ -d "$BACKEND_DIR/$item" ]; then
            cp -r "$BACKEND_DIR/$item" "$BACKEND_BUILD_OUTPUT_DIR/"
        fi
    done
    # Copy specific files if needed (e.g., main app file, config files)
    # cp $BACKEND_DIR/app.py $BACKEND_BUILD_OUTPUT_DIR/
    
    # Copy requirements.txt if it exists
    if [ -f "$BACKEND_DIR/requirements.txt" ]; then
        cp "$BACKEND_DIR/requirements.txt" "$BACKEND_BUILD_OUTPUT_DIR/"
    fi
    
    # Remove unwanted files/dirs from the copied structure
    echo "Cleaning backend package directory..."
    find "$BACKEND_BUILD_OUTPUT_DIR" -type d -name '__pycache__' -exec rm -rf {} + 
    find "$BACKEND_BUILD_OUTPUT_DIR" -type f -name '*.pyc' -delete
    # Add other cleaning steps if needed

    print_success "Backend packaging complete."
fi

# --- Final Summary --- 
print_header "AlphaMind Build Process Summary"
print_success "Build process completed! Artifacts are located in the 
'$BUILD_DIR' directory."

exit 0

