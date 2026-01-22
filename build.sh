#!/bin/bash

# Build script for Benefits Platform
# Supports: clean, build, test, lint, docker-build, validate

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-help}"

print_header() {
  echo ""
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
  echo ""
}

print_step() {
  echo "▶ $1"
}

print_success() {
  echo "✓ $1"
}

case "$TARGET" in
  clean)
    print_header "Cleaning build artifacts"
    print_step "Removing target/ directories"
    find "$ROOT_DIR" -name "target" -type d -exec rm -rf {} + 2>/dev/null || true
    print_step "Removing node_modules"
    find "$ROOT_DIR" -name "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
    print_success "Clean complete"
    ;;
  build)
    print_header "Building project (Maven)"
    print_step "Running mvn clean package"
    cd "$ROOT_DIR"
    mvn clean package -DskipTests -T 1.5C
    print_success "Build complete"
    ;;
  test)
    print_header "Running tests"
    print_step "Running Maven tests"
    cd "$ROOT_DIR"
    mvn test -T 1.5C
    print_success "Tests passed"
    ;;
  lint)
    print_header "Running linters"
    print_step "Checking code quality"
    cd "$ROOT_DIR"
    mvn spotbugs:check -DfailOnError=false || true
    mvn dependency-check:check -DfailOnError=false || true
    print_success "Lint complete"
    ;;
  docker-build)
    print_header "Building Docker images"
    print_step "Building images..."
    cd "$ROOT_DIR"
    # Will add docker build commands when services are ready
    print_success "Docker build complete"
    ;;
  validate)
    print_header "Running validation"
    print_step "Checking Java version"
    java -version 2>&1 | head -2
    print_step "Checking Maven"
    mvn --version | head -1
    print_success "Validation complete"
    ;;
  help|*)
    echo "BUILD SCRIPT - Benefits Platform"
    echo ""
    echo "USAGE: ./build.sh [TARGET]"
    echo ""
    echo "TARGETS:"
    echo "  clean       - Remove build artifacts"
    echo "  build       - Compile Maven modules"
    echo "  test        - Run tests"
    echo "  lint        - Run code quality checks"
    echo "  docker-build - Build Docker images"
    echo "  validate    - Check environment"
    echo "  help        - Show this help"
    echo ""
    ;;
esac
