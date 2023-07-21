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
    -f argocd/argocd/values.yaml
```

## Add a component

1. Configure argocd app-of-apps with the new app. If necessary create a new project and a new namespace. The project must be allowed on the namespace.
2. Add values in the values file
3. Synchronize app-of-apps in ArgoCD UI
4. Add monitoring :
   1. Prometheus rule if there is one
   2. Exporter if there is one
   3. Update Terraform Grafana stack with dashboard
5. Add URL in blackbox-exporter values if necessary

## Use secrets from Vault to K8S secrets

1. Configure Vault role in terraform for a sepcific service account and namespace. Allow access on specific secret.
2. Update vault/secret-stores with the synchronized secrets if you want to use K8S secrets. If you want only secrets as file in the pod, it's unnecessary.
3. Configure service account for the pod
4. Add volumes and volumeMounts like this :

```yaml
volumeMounts:
- mountPath: /mnt/secrets-store
    name: secrets-store-inline
volumes:
- name: secrets-store-inline
    csi:
    driver: secrets-store.csi.k8s.io
    readOnly: true
    volumeAttributes:
        secretProviderClass: <secret-provider-class-name>
```
