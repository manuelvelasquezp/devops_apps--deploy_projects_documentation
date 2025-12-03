# Makefile

.PHONY: help install lint lint-fix test clean setup

# Default target
help: ## Show this help message
	@echo "Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# Development setup
setup: ## Set up development environment
	@ENVIRONMENT=$${ENVIRONMENT:-local} scripts/setup.sh

install: ## Install dependencies
	pip install --upgrade pip
	pip install -r requirements.txt
	pip install ".[dev]"
	@find . -name "*.egg-info" -type d -exec rm -rf {} + 2>/dev/null || true

# Code quality
lint: ## Run linting checks
	@scripts/lint.sh

lint-fix: ## Run linting with auto-fixes
	@scripts/lint-fix.sh

# Testing (when tests are implemented)
test: ## Run tests
	pytest -v

# Cleanup
clean: ## Clean up temporary files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf htmlcov/ .coverage build/ dist/
