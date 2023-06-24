DEBUG ?=

SHELL = /bin/bash -o pipefail

DIR = $(shell pwd)

CONFIG_HOME = $(or ${XDG_CONFIG_HOME},${XDG_CONFIG_HOME},${HOME}/.config)

INSPEC_EXEC=PATH=${HOME}/.gem/ruby/2.7.0/bin/:${PATH} inspec exec

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
INFO_COLOR=\033[36m
WHITE_COLOR=\033[1m

MAKE_COLOR=\033[33;01m%-20s\033[0m

.DEFAULT_GOAL := help

OK=[✅]
KO=[❌]
WARN=[🟡]


KUBE_CONTEXT=kubernetes-admin@belt
KUBE_CURRENT_CONTEXT = $(shell kubectl config current-context)



.PHONY: help
help:
	@echo -e "$(OK_COLOR)                  $(BANNER)$(NO_COLOR)"
	@echo "------------------------------------------------------------------"
	@echo ""
	@echo -e "${ERROR_COLOR}Usage${NO_COLOR}: make ${INFO_COLOR}<target>${NO_COLOR}"
	@awk 'BEGIN {FS = ":.*##"; } /^[a-zA-Z_-]+:.*?##/ { printf "  ${INFO_COLOR}%-25s${NO_COLOR} %s\n", $$1, $$2 } /^##@/ { printf "\n${WHITE_COLOR}%s${NO_COLOR}\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "$(ERROR_COLOR)Environment variable $* not set$(NO_COLOR)"; \
		exit 1; \
	fi

check-%:
	@if $$(hash $* 2> /dev/null); then \
		echo -e "$(OK_COLOR)$(OK)$(NO_COLOR) $*"; \
	else \
		echo -e "$(ERROR_COLOR)$(KO)$(NO_COLOR) $*"; \
	fi

print-%:
	@if [ "${$*}" == "" ]; then \
		echo -e "$(ERROR_COLOR)[KO]$(NO_COLOR) $* = ${$*}"; \
	else \
		echo -e "$(OK_COLOR)[OK]$(NO_COLOR) $* = ${$*}"; \
	fi


# ====================================
# D E V
# ====================================

.PHONY: check ## Check requirements
check: check-helm


# ====================================
# H E L M
# ====================================

kubernetes-check-context:
	@if [[ "${KUBE_CONTEXT}" != "${KUBE_CURRENT_CONTEXT}" ]] ; then \
		echo -e "$(ERROR_COLOR)[KO]$(NO_COLOR) Kubernetes context: ${KUBE_CONTEXT} vs ${KUBE_CURRENT_CONTEXT}"; \
		exit 1; \
	fi


##@ Helm

.PHONY: helm-deps
helm-deps: guard-SERVICE ## Install Helm chart dependencies (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		([ ! -f "$(SERVICE)/Chart.yaml" ] && \
		helm repo add $$CHART_REPO_NAME $$CHART_REPO_URL && \
		helm repo update) || \
		([ -f "$(SERVICE)/Chart.yaml" ] && \
		helm dependency update $(SERVICE) || \
		echo "No dependencies found."); \


.PHONY: helm-values
helm-values: guard-SERVICE ## Show Helm values for the selected service (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		if [ ! -n "$(SKIP_DEPS)" ]; then \
			echo -e "I will pull deps for you, next time you can use SKIP_DEPS=true "; \
			([ ! -f "$(SERVICE)/Chart.yaml" ] && \
			helm repo add $$CHART_REPO_NAME $$CHART_REPO_URL && \
			helm repo update) || \
			([ -f "$(SERVICE)/Chart.yaml" ] && \
			helm dependency update $(SERVICE) || \
			echo "No dependencies found."); \
		fi; \
		helm show values $$CHART_PATH

.PHONY: helm-template
helm-template: guard-SERVICE ## Render chart templates locally and display the output. (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		helm template $$CHART_RELEASE_NAME $$CHART_PATH \
		--namespace $$CHART_NAMESPACE -f $(SERVICE)/values.yaml \
		--version $$CHART_VERSION

.PHONY: helm-validate
helm-validate: guard-SERVICE kubernetes-check-context ## Simulate the installation/upgrade of a release (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		helm upgrade --install $$CHART_RELEASE_NAME $$CHART_PATH \
		--namespace $$CHART_NAMESPACE -f $(SERVICE)/values.yaml \
		--version $$CHART_VERSION --create-namespace --dry-run

.PHONY: helm-diff
helm-diff: guard-SERVICE kubernetes-check-context ## Show diff of an installation/upgrade of the release (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		helm diff upgrade --install $$CHART_RELEASE_NAME $$CHART_PATH \
		--namespace $$CHART_NAMESPACE -f $(SERVICE)/values.yaml \
		--version $$CHART_VERSION

.PHONY: helm-install
helm-install: guard-SERVICE kubernetes-check-context ## Install/Upgrade the release (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		helm upgrade --install $$CHART_RELEASE_NAME $$CHART_PATH \
		--namespace $$CHART_NAMESPACE -f $(SERVICE)/values.yaml \
		--version $$CHART_VERSION --create-namespace

.PHONY: helm-uninstall
helm-uninstall: guard-SERVICE kubernetes-check-context ## Uninstall the release (SERVICE=xxx)
	@source $(SERVICE)/chart.sh && \
		helm uninstall $$CHART_RELEASE_NAME --namespace $$CHART_NAMESPACE
