#!/usr/bin/env bash

# Used only for bootstrap, after that, argo manages itself

CHART_REPO_NAME="argocd"
CHART_REPO_URL="https://argoproj.github.io/argo-helm"

CHART_RELEASE_NAME="argocd-apps"
CHART_PATH="argocd/argocd-apps"
CHART_NAMESPACE="argocd"
CHART_VERSION="1.2.0"
