# Kubernetes
Kubernetes IAC repo for Homelab

## First ArgoCD install

```bash
source argo-cd/chart.sh
helm repo add ${CHART_REPO_NAME} ${CHART_REPO_URL}
helm repo update
helm install ${CHART_NAME} ${CHART_PATH} \
    --namespace=${CHART_NAMESPACE} \
    --create-namespace \
    -f argo-cd/values.yaml
```