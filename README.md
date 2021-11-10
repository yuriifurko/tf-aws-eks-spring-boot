HELLO-WORLD
===

## Architecture

![img](images/arch.drawio.png)

### Initialization

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt run-all init --upgrade
terragrunt run-all plan
terragrunt run-all apply
```

### Destroy

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt run-all destroy
```

### CleanUP

```bash
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```