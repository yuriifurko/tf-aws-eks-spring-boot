#!/bin/bash

echo -e "Generate README"
terraform-docs markdown table --output-file README.md .

echo -e "\n Running validate"
terraform init --upgrade -migrate-state && terraform validate

echo -e "\n Running fmt"
terraform fmt -recursive -check

echo -e "\n Running tfsec"
tfsec

echo -e "\n Running checkov"
checkov -d .

echo -e "\n Running tflint"
tflint --recursive --config "$(pwd)/.tflint.hcl"
