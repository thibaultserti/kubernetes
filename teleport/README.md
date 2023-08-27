# Create admin user

```bash
kubectl --namespace teleport exec deploy/teleport-auth -- tctl users add admin --roles=access,editor
```

# Create terraform user and role

## Create role

```yaml
kind: role
metadata:
  name: terraform
spec:
  allow:
    db_labels:
      '*': '*'
    app_labels:
      '*': '*'
    rules:
      - resources:
        - app
        - cluster_auth_preference
        - cluster_networking_config
        - db
        - device
        - github
        - login_rule
        - oidc
        - okta_import_rule
        - role
        - saml
        - session_recording_config
        - token
        - trusted_cluster
        - user
        verbs: ['list','create','read','update','delete']
version: v6
```

## Create user

```yaml
kind: user
metadata:
  name: terraform
spec:
  roles: ['terraform']
version: v2
```

## Create terraform impersonification role

```yaml
kind: role
version: v6
metadata:
  name: terraform-impersonator
spec:
  allow:
    # This impersonate role allows any user assigned to this role to impersonate
    # and generate certificates for the user named "terraform" with a role also
    # named "terraform".
    impersonate:
      users: ['terraform']
      roles: ['terraform']
```

then add `terraform-impersonator` role to your user

Request identity for terraform:

```bash
kubectl --namespace teleport exec deploy/teleport-auth -- tctl auth sign --user=terraform
```