.PHONY: init fmt validate plan apply destroy

TOFU ?= tofu

init:
	$(TOFU) init

fmt:
	$(TOFU) fmt -recursive

validate:
	$(TOFU) validate

plan:
	$(TOFU) plan -out=tfplan

apply:
	$(TOFU) apply tfplan

destroy:
	$(TOFU) plan -destroy

