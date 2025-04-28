#!/bin/bash

# Linting and Fixing Script for AlphaMind Project (Python)

set -e  # Exit immediately if a command exits with a non-zero status

echo "----------------------------------------"
echo "Starting linting and fixing process for AlphaMind..."
echo "----------------------------------------"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required tools
echo "Checking for required tools..."

# Check for Python
if ! command_exists python3; then
  echo "Error: python3 is required but not installed. Please install Python 3."
  exit 1
else
  echo "python3 is installed."
fi

# Check for pip
if ! command_exists pip3; then
  echo "Error: pip3 is required but not installed. Please install pip3."
  exit 1
else
  echo "pip3 is installed."
fi

# Install required Python linting tools if not already installed
echo "----------------------------------------"
echo "Installing/Updating Python linting tools..."
pip3 install --upgrade black isort flake8 pylint

# Define directories to process
PYTHON_DIRECTORIES=(
  "backend/ai_models"
  "backend/alpha_research"
  "backend/alternative_data"
  "backend/execution_engine"
  "backend/infrastructure"
  "backend/risk_system"
  "frontend/docs"
  "frontend/downloads"
  "tests"
)

# 1. Run Black (code formatter)
echo "----------------------------------------"
echo "Running Black code formatter..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Formatting Python files in $dir..."
    python3 -m black "$dir"
  else
    echo "Directory $dir not found. Skipping Black formatting for this directory."
  fi
done
echo "Black formatting completed."

# 2. Run isort (import sorter)
echo "----------------------------------------"
echo "Running isort to sort imports..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Sorting imports in Python files in $dir..."
    python3 -m isort "$dir"
  else
    echo "Directory $dir not found. Skipping isort for this directory."
  fi
done
echo "Import sorting completed."

# 3. Run flake8 (linter)
echo "----------------------------------------"
echo "Running flake8 linter..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Linting Python files in $dir with flake8..."
    python3 -m flake8 "$dir" || {
      echo "Flake8 found issues in $dir. Please review the above warnings/errors."
    }
  else
    echo "Directory $dir not found. Skipping flake8 for this directory."
  fi
done
echo "Flake8 linting completed."

# 4. Run pylint (more comprehensive linter)
echo "----------------------------------------"
echo "Running pylint for more comprehensive linting..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Linting Python files in $dir with pylint..."
    find "$dir" -type f -name "*.py" | xargs python3 -m pylint --disable=C0111,C0103,C0303,W0621,C0301,W0612,W0611,R0913,R0914,R0915 || {
      echo "Pylint found issues in $dir. Please review the above warnings/errors."
    }
  else
    echo "Directory $dir not found. Skipping pylint for this directory."
  fi
done
echo "Pylint linting completed."

# 5. Check for unused imports
echo "----------------------------------------"
echo "Checking for unused imports..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Checking for unused imports in $dir..."
    python3 -m flake8 "$dir" --select=F401 || {
      echo "Found unused imports in $dir. Please review the above warnings."
    }
  else
    echo "Directory $dir not found. Skipping unused imports check for this directory."
  fi
done
echo "Unused imports check completed."

# 6. Check for trailing whitespace and fix
echo "----------------------------------------"
echo "Checking and fixing trailing whitespace..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Checking for trailing whitespace in $dir..."
    find "$dir" -type f -name "*.py" -exec sed -i 's/[ \t]*$//' {} \;
    echo "Fixed trailing whitespace in $dir."
  else
    echo "Directory $dir not found. Skipping trailing whitespace check for this directory."
  fi
done
echo "Trailing whitespace check and fix completed."

# 7. Ensure newline at end of file
echo "----------------------------------------"
echo "Ensuring newline at end of files..."
for dir in "${PYTHON_DIRECTORIES[@]}"; do
  if [ -d "$dir" ]; then
    echo "Ensuring newline at end of files in $dir..."
    find "$dir" -type f -name "*.py" -exec sh -c '[ -n "$(tail -c1 "$1")" ] && echo "" >> "$1"' sh {} \;
    echo "Ensured newline at end of files in $dir."
  else
    echo "Directory $dir not found. Skipping newline check for this directory."
  fi
done
echo "Newline check completed."

echo "----------------------------------------"
echo "Linting and fixing process for AlphaMind completed!"
echo "----------------------------------------"
