.DEFAULT_GOAL := help
.PHONY: help fmt lint test validate up down up-aws down-aws up-aws-emulated down-aws-emulated up-gcp-emulated down-gcp-emulated

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

validate: ## Validate every example (no cloud credentials needed)
	@for d in examples/local examples/aws examples/gcp; do \
		echo "== $$d"; \
		terraform -chdir="$$d" init -backend=false -input=false >/dev/null; \
		terraform -chdir="$$d" validate || exit 1; \
	done

up: ## Create the local kind + LocalStack demo environment
	terraform -chdir=examples/local init -upgrade -input=false
	terraform -chdir=examples/local apply -auto-approve -target=module.kind
	terraform -chdir=examples/local apply -auto-approve

down: ## Destroy the local demo environment
	terraform -chdir=examples/local destroy -auto-approve

up-aws: ## Create the timeboxed real-AWS demo (needs AWS_PROFILE and TF_VAR_caller_cidr)
	terraform -chdir=examples/aws init -upgrade -input=false
	terraform -chdir=examples/aws apply -auto-approve

down-aws: ## Destroy the real-AWS demo
	terraform -chdir=examples/aws destroy -auto-approve

up-aws-emulated: ## Apply aws-network + aws-github-oidc against Floci on :4567
	docker rm -f platform-local-floci-aws >/dev/null 2>&1 || true
	docker run -d --rm --name platform-local-floci-aws -p 4567:4566 floci/floci:2.4.0
	terraform -chdir=examples/aws init -upgrade -input=false
	terraform -chdir=examples/aws apply -auto-approve \
		-target=module.network -target=module.github_oidc \
		-var aws_endpoint_url=http://localhost:4567 -var caller_cidr=203.0.113.10/32

down-aws-emulated: ## Destroy the emulated AWS resources and remove Floci
	terraform -chdir=examples/aws destroy -auto-approve \
		-var aws_endpoint_url=http://localhost:4567 -var caller_cidr=203.0.113.10/32
	docker rm -f platform-local-floci-aws >/dev/null 2>&1 || true

up-gcp-emulated: ## Apply the GCP network and identity modules against Floci GCP on :4588
	docker rm -f platform-local-floci-gcp >/dev/null 2>&1 || true
	docker run -d --rm --name platform-local-floci-gcp -p 4588:4588 floci/floci-gcp:0.12.0
	terraform -chdir=examples/gcp init -upgrade -input=false
	terraform -chdir=examples/gcp apply -auto-approve -target=module.network \
		-var project_id=example-project -var emulator_endpoint=http://localhost:4588

down-gcp-emulated: ## Destroy the emulated GCP resources and remove Floci GCP
	terraform -chdir=examples/gcp destroy -auto-approve \
		-var project_id=example-project -var emulator_endpoint=http://localhost:4588
	docker rm -f platform-local-floci-gcp >/dev/null 2>&1 || true
