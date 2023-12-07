HELLO-WORLD
===

## 🏠 Architecture

![img](images/arch.drawio.png)

### 🖥️ Initialization

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt init --upgrade --reconfigure
terragrunt run-all plan -auto-approve
terragrunt run-all apply -auto-approve
```

### 🖥️ Destroy

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt run-all destroy

find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```