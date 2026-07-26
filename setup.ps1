<# 
  AI VISUAL CREATOR — First-Time Setup
  Run this ONCE to connect your project to GitHub Pages.
  
  Prerequisites:
    - Git installed (git --version to check)
    - GitHub account with a repo named "LEARN-AI-VISUAL-CREATOR"
    - Git credentials configured (git config user.name / user.email)
  
  Usage:
    Right-click → Run with PowerShell (or: .\setup.ps1)
#>

$repoPath = $PSScriptRoot
Set-Location $repoPath

Write-Host ""
Write-Host "  AI VISUAL CREATOR — First-Time Setup" -ForegroundColor Cyan
Write-Host ""

# Step 1: Git init
if (-not (Test-Path ".git")) {
    Write-Host "  [1/5] Initializing git repo..." -ForegroundColor Yellow
    git init
    git branch -M main
} else {
    Write-Host "  [1/5] Git repo already exists" -ForegroundColor Green
}

# Step 2: Rename landing.html to index.html (homepage)
if ((Test-Path "landing.html") -and -not (Test-Path "index.html")) {
    Write-Host "  [2/5] Renaming landing.html → index.html..." -ForegroundColor Yellow
    Rename-Item "landing.html" "index.html"
} else {
    Write-Host "  [2/5] index.html already exists" -ForegroundColor Green
}

# Step 3: Create .gitignore
if (-not (Test-Path ".gitignore")) {
    Write-Host "  [3/5] Creating .gitignore..." -ForegroundColor Yellow
    @"
deploy-watch.ps1
setup.ps1
*.swp
*.tmp
Thumbs.db
"@ | Set-Content ".gitignore" -Encoding UTF8
} else {
    Write-Host "  [3/5] .gitignore exists" -ForegroundColor Green
}

# Step 4: Add remote
$remotes = git remote -v 2>&1
if ($remotes -notmatch "origin") {
    Write-Host "  [4/5] Adding GitHub remote..." -ForegroundColor Yellow
    git remote add origin https://github.com/daniameen741-hue/LEARN-AI-VISUAL-CREATOR.git
} else {
    Write-Host "  [4/5] Remote already configured" -ForegroundColor Green
}

# Step 5: Initial commit and push
Write-Host "  [5/5] Creating initial commit and pushing..." -ForegroundColor Yellow
git add -A
git commit -m "Initial deploy — AI VISUAL CREATOR landing + registration"
git push -u origin main

Write-Host ""
Write-Host "  Setup complete!" -ForegroundColor Green
  Write-Host "  Your site: https://daniameen741-hue.github.io/LEARN-AI-VISUAL-CREATOR/" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Next: Run '.\deploy-watch.ps1' to enable auto-deploy on file changes." -ForegroundColor Gray
Write-Host ""
