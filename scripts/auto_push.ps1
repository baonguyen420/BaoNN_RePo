param([string]$Branch = "main")
$ErrorActionPreference = "Stop"

# Đặt working dir về root repo
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location -Path (Resolve-Path "..")

# 1) Có thay đổi không?
$dirty = git status --porcelain
if ([string]::IsNullOrWhiteSpace($dirty)) {
  Write-Host "[auto_push] No changes to commit."
  exit 0
}

# 2) Cập nhật & rebase để tránh lỗi push
git fetch origin $Branch
try { git rebase origin/$Branch } catch {
  Write-Host "[auto_push] Rebase failed. Resolve conflicts then rerun."
  exit 1
}

# 3) Commit & push
git add -A
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
git commit -m "auto: $ts"
git push origin $Branch
Write-Host "[auto_push] Done."
