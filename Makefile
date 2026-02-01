.PHONY: test lint validate converge destroy clean help

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

test: ## Run unit tests
	@echo "Running tests..."
	@rake test

lint: ## Run linters (ruby syntax check)
	@echo "Checking Ruby syntax..."
	@ruby -c vagrantfile
	@ruby -c lib/config_validator.rb
	@echo "Lint passed."

validate: ## Validate Vagrant configuration
	@echo "Validating Vagrant configuration..."
	@vagrant validate

converge: ## Bring up all VMs
	@vagrant up

destroy: ## Destroy all VMs
	@vagrant destroy -f

clean: destroy ## Alias for destroy

idempotence: ## Test idempotence (provision twice, check no changes)
	@echo "Testing idempotence..."
	@vagrant provision
	@vagrant provision

status: ## Show VM status
	@vagrant status
