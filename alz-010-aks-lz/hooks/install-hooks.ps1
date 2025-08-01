$gitHookDir = ".git/hooks"
$sourceHookDir = "hooks"
if (-Not (Test-Path -Path $gitHookDir)) {
    Write-Host "Error: Not a Git repository. No .git/hooks directory found."
    exit 1
}
Write-Host "Installing Git Hooks ..."
Copy-Item "$sourceHookDir/pre-commit" "$gitHookDir/pre-commit" -Force
Copy-Item "$sourceHookDir/pre-commit.ps1" "$gitHookDir/pre-commit.ps1" -Force
Write-Host "Git hooks installed."
