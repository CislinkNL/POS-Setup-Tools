# Test script syntax
$ErrorActionPreference = "Stop"
try {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile("e:\POS Cislink Setup script\New POS Setup\POS_Setup.ps1", [ref]$null, [ref]$null)
    if ($ast) {
        Write-Host "✓ POS_Setup.ps1 syntax is valid" -ForegroundColor Green
    }
} catch {
    Write-Error "❌ Syntax error in POS_Setup.ps1: $($_.Exception.Message)"
}

try {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile("e:\POS Cislink Setup script\Restore PC\POS_restore.ps1", [ref]$null, [ref]$null)
    if ($ast) {
        Write-Host "✓ POS_restore.ps1 syntax is valid" -ForegroundColor Green
    }
} catch {
    Write-Error "❌ Syntax error in POS_restore.ps1: $($_.Exception.Message)"
}

Write-Host "`n=== Syntax Validation Complete ===" -ForegroundColor Cyan