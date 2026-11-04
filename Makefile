.DEFAULT_GOAL := help
.PHONY: help fmt lint test up down

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-8s %s\n", $$1, $$2}'

fmt: ## Format every Terraform file
	terraform fmt -recursive

lint: ## Check formatting and run tflint
	terraform fmt -check -recursive
	tflint --recursive

test: ## Run terraform test for every module
	@for d in modules/*/; do \
		echo "== $$d"; \
		terraform -chdir="$$d" init -backend=false -input=false >/dev/null; \
		terraform -chdir="$$d" test || exit 1; \
	done

up: ## Create the local kind + LocalStack demo environment
	terraform -chdir=examples/local init -upgrade -input=false
	terraform -chdir=examples/local apply -auto-approve -target=module.kind
	terraform -chdir=examples/local apply -auto-approve

down: ## Destroy the local demo environment
	terraform -chdir=examples/local destroy -auto-approve
