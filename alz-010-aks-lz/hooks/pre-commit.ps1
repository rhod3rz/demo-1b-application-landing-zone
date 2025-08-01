# Exit script on error
$ErrorActionPreference = "Stop"

# Ensure Terraform is installed and in PATH
if (-not (Get-Command "terraform" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Terraform is not installed or not in PATH"
    exit 1
}

# Ensure TFLint is installed and in PATH
if (-not (Get-Command "tflint" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: TFLint is not installed or not in PATH"
    exit 1
}

# Run terraform fmt
Write-Host "Running terraform fmt..."
terraform fmt -recursive
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: terraform fmt failed"
    exit 1
}

# Run tflint
Write-Host "Running tflint..."
tflint
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: tflint failed"
    exit 1
}

# Run terraform validate
Write-Host "Running terraform validate..."
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: terraform validate failed"
    exit 1
}

Write-Host "All checks passed. Proceeding with commit."
exit 0
