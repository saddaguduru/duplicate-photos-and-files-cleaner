# ==============================================
# Duplicate Photos and Videos Deletion from CSV
# ==============================================

# Path to the previously created CSV file
$csvPath = "E:\Personal\Duplicate-Media-files.csv"

# Import the CSV data
$exportData = Import-Csv -Path $csvPath

# ================================
# Preview Mode (Safe)
# ================================
Write-Host "=== Duplicate Files Found (Preview Mode from CSV) ==="
$exportData | Format-Table Name, Path, LastWriteTime, Action

# ================================
# Delete Mode (Uncomment to enable)
# ================================

$exportData | Where-Object { $_.Action -eq "Delete" } | ForEach-Object {
    $filePath = $_.Path.Trim()   # ensure no trailing spaces
    if (Test-Path "$filePath") {
        Remove-Item -LiteralPath "$filePath" -Force
        Write-Output "Deleted: $filePath"
    } else {
        Write-Output "File not found: $filePath"
    }
}
