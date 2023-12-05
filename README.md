HELLO-WORLD
===

## Architecture

![img](images/arch.drawio.png)

### Initialization

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt init --upgrade --reconfigure
terragrunt run-all plan -auto-approve
terragrunt run-all apply -auto-approve
```

### Destroy

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt run-all destroy -auto-approve
```

### CleanUP

```bash
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```

### Update kubeconfig

```
aws eks update-kubeconfig \
  --name hello-world-dev \
  --region us-east-1 \
  --profile administrator-access-935454902317 \
  --kubeconfig $HOME/.kube/hello-world-dev
```