#!/usr/bin/env bash

# Used only for bootstrap, after that, argo manages itself

CHART_REPO_NAME="argocd"
CHART_REPO_URL="https://argoproj.github.io/argo-helm"

CHART_RELEASE_NAME="argocd"
CHART_PATH="argocd/argo-cd"
CHART_NAMESPACE="argocd"
CHART_VERSION="5.36.2"
