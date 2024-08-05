#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Treat unset variables as an error when substituting.
set -u

# Function to print colored output
print_color() {
    COLOR=$1
    MESSAGE=$2
    RESET='\033[0m'
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

# Function to run a test
run_test() {
    TEST_NAME=$1
    TEST_COMMAND=$2
    
    echo "Testing: $TEST_NAME"
    if eval "$TEST_COMMAND"; then
        print_color '\033[0;32m' "  [PASS] $TEST_NAME"
    else
        print_color '\033[0;31m' "  [FAIL] $TEST_NAME"
        FAILED_TESTS+=("$TEST_NAME")
    fi
    echo
}

FAILED_TESTS=()

# Test Python setup
run_test "Python version" "python --version"
run_test "Rye installation" "rye --version"
run_test "UV installation" "uv --version"
run_test "Python virtual environment" "[ -d .venv ] || [ -d '$RYE_HOME' ]"
run_test "Jupyter installation" "jupyter --version"
run_test "IPython kernel installation" "jupyter kernelspec list | grep -q project_kernel"

# Test R setup
run_test "R version" "R --version"
run_test "renv installation" "R -q -e 'packageVersion(\"renv\")'"
run_test "R environment location" "[ \"$R_LIBS_USER\" = \"/opt/r_env\" ]"

# Test document preparation tools
run_test "Quarto installation" "quarto --version"
run_test "LaTeX installation" "latex --version"
run_test "Typst installation" "typst --version"

# Test Git configuration
run_test "Git autocrlf configuration" "git config --get core.autocrlf | grep -q input"

# Print summary
echo "==== Test Summary ===="
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    print_color '\033[0;32m' "All tests passed successfully!"
else
    print_color '\033[0;31m' "The following tests failed:"
    for test in "${FAILED_TESTS[@]}"; do
        print_color '\033[0;31m' "  - $test"
    done
    exit 1
fi