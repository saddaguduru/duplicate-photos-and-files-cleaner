# ================================
# Duplicate File Finder
# ================================

# Set the folder to scan
$folder = "E:\Personal"

# Get all files (any extension)
$files = Get-ChildItem -Path $folder -Recurse -File

# Compute hash for each file
$hashes = $files | ForEach-Object {
    $hash = Get-FileHash $_.FullName -Algorithm MD5
    [PSCustomObject]@{
        Name = $_.Name
        Path = $_.FullName
        LastWriteTime = $_.LastWriteTime
        Hash = $hash.Hash
    }
}

# Group by hash to find duplicates
$duplicates = $hashes | Group-Object Hash | Where-Object { $_.Count -gt 1 }

# ================================
# Export Duplicate Details to CSV
# ================================
$csvPath = "E:\Personal\DuplicateFiles.csv"

$exportData = @()

$duplicates | ForEach-Object {
    $group = $_.Group | Sort-Object LastWriteTime -Descending
    $keep = $group[0]   # newest file
    $delete = $group | Select-Object -Skip 1  # older ones

    # Mark the file to keep
    $exportData += [PSCustomObject]@{
        Name = $keep.Name
        Path = $keep.Path
        LastWriteTime = $keep.LastWriteTime
        Hash = $keep.Hash
        Action = "Keep"
    }

    # Mark the files to delete
    foreach ($file in $delete) {
        $exportData += [PSCustomObject]@{
            Name = $file.Name
            Path = $file.Path
            LastWriteTime = $file.LastWriteTime
            Hash = $file.Hash
            Action = "Delete"
        }
    }
}

$exportData | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "Duplicate file details exported to $csvPath with Keep/Delete markers"

# ================================
# Preview Mode (Safe)
# ================================
Write-Host "=== Duplicate Files Found (Preview Mode) ==="
$exportData | Format-Table Name, Path, LastWriteTime, Action
