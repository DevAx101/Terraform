SHELL := /usr/bin/env bash

all-test: clean tf-plan-eks

.PHONY: clean
clean:
	rm -rf .terraform

.PHONY: tf-plan-eks
tf-plan-eks:
	terraform init -backend-config ./environment/dev/backend.conf -reconfigure source && terraform validate && terraform plan -var-file ./environment/dev/base.tfvars source

.PHONY: tf-apply-eks
tf-apply-eks:
	terraform init -backend-config ./environment/dev/backend.conf -reconfigure source && terraform validate && terraform apply -var-file ./environment/dev/base.tfvars -auto-approve source

.PHONY: tf-destroy-eks
tf-destroy-test:
	terraform init -backend-config ./environment/dev/backend.conf -reconfigure source && terraform validate && terraform destroy -var-file ./environment/dev/base.tfvars source -auto-approve source

.PHONY: tf-fmt
fmt:
	for i in $$(find . -name \*.tf | grep -v ".terraform"); do terraform fmt -write=true $$i; done

.PHONY: tf-sec
tfsec:
	tfsec .

default: help

.PHONY: help
help: ## print targets and their descrptions
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: fmt
fmt: ## terraform fmt
	terraform fmt -recursive -write .

.PHONY: validate
validate: ## terraform validate
	@for dir in $(shell find . -name "*.tf" -not -path "*.terraform*" -printf '%h ' | uniq); do \
		echo "====> $$dir"; \
		terraform -chdir=$$dir init -backend=false || exit 1; \
		terraform -chdir=$$dir validate || exit 1; \
	done
