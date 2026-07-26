<# 
  AI VISUAL CREATOR — Auto Deploy Script
  Watches the project folder for changes, commits, and pushes to GitHub Pages.
  
  First-time setup:
    1. cd into this project folder
    2. git init
    3. git remote add origin https://github.com/daniameen741-hue/LEARN-AI-VISUAL-CREATOR.git
    4. Run this script: .\deploy-watch.ps1
  
  After setup, every file save auto-deploys to GitHub Pages.
  Press Ctrl+C to stop watching.
#>

$repoPath = $PSScriptRoot
$remote = "origin"
$branch = "main"

# Ensure we're in the right directory
Set-Location $repoPath

# Check git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "ERROR: Not a git repo. Run 'git init' first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  AI VISUAL CREATOR — Auto Deploy" -ForegroundColor Cyan
Write-Host "  Watching for changes in: $repoPath" -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

# File watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repoPath
$watcher.IncludeSubdirectories = $true
$watcher.Filter = "*.*"
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::FileName
$watcher.EnableRaisingEvents = $false

# Debounce: wait 2 seconds after last change before committing
$timer = $null
$pending = $false

function Deploy-Changes {
    Set-Location $repoPath
    
    # Check if there are actual changes
    $status = git status --porcelain 2>&1
    if (-not $status) {
        return
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "  [$timestamp] Changes detected, deploying..." -ForegroundColor Yellow
    
    git add -A 2>&1 | Out-Null
    $commitMsg = "Auto-deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    git commit -m $commitMsg 2>&1 | Out-Null
    
    $pushOutput = git push $remote $branch 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [$timestamp] Deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [$timestamp] Push failed. Check your git credentials." -ForegroundColor Red
        Write-Host "  $pushOutput" -ForegroundColor Red
    }
}

# Watch for changes
Register-ObjectEvent $watcher "Changed" -Action {
    $global:pending = $true
    if ($global:timer) { $global:timer.Stop() }
    $global:timer = New-Object System.Timers.Timer
    $global:timer.Interval = 2000
    $global:timer.AutoReset = $false
    $global:timer.Add_Tick({
        if ($global:pending) {
            $global:pending = $false
            Deploy-Changes
        }
    })
    $global:timer.Start()
}

Register-ObjectEvent $watcher "Created" -Action {
    $global:pending = $true
    if ($global:timer) { $global:timer.Stop() }
    $global:timer = New-Object System.Timers.Timer
    $global:timer.Interval = 2000
    $global:timer.AutoReset = $false
    $global:timer.Add_Tick({
        if ($global:pending) {
            $global:pending = $false
            Deploy-Changes
        }
    })
    $global:timer.Start()
}

Register-ObjectEvent $watcher "Deleted" -Action {
    $global:pending = $true
    if ($global:timer) { $global:timer.Stop() }
    $global:timer = New-Object System.Timers.Timer
    $global:timer.Interval = 2000
    $global:timer.AutoReset = $false
    $global:timer.Add_Tick({
        if ($global:pending) {
            $global:pending = $false
            Deploy-Changes
        }
    })
    $global:timer.Start()
}

$watcher.EnableRaisingEvents = $true

Write-Host "  Watching... edit any file to trigger deploy." -ForegroundColor Green
Write-Host ""

# Keep script running
while ($true) { Start-Sleep -Seconds 1 }
