SIMPLE SPRING-BOOT APPLICATION
===

## 🏠 Architecture

![img](images/arch.drawio.png)

### 🖥️ Initialization

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt run-all init
terragrunt run-all plan -auto-approve
terragrunt run-all apply -auto-approve
```

### 🖥️ Destroy

```bash
cd infrastructure/non-prod/us-east-1/dev
terragrunt run-all destroy

find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->