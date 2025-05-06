<#
.SYNOPSIS
  Extracts "Pros" or "Cons" titles, formats their list items, and removes Shortcodes Ultimate tags.

.DESCRIPTION
  This script finds [su_box] shortcodes with the title "Pros" or "Cons",
  extracts the title, formats the subsequent list items with indentation,
  and removes [su_row], [su_column], and [su_list] tags.

.PARAMETER ContentPath
  The path to your Hugo content directory. Default is "content".

.EXAMPLE
  .\process-pros-cons.ps1 -ContentPath "content"

  This will process all .md files in the "content" directory and its subdirectories.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ContentPath = "content"
)

# Regular expression to match the [su_box] with "Pros" and its list
$prosBlockPattern = '\[su_box(?:\s+[^\]]+)?\s+title="Pros"[^\]]*\]\s*\[su_list[^\]]*\](.*?)\s*\[/su_list\]\s*\[/su_box\]'

# Regular expression to match the [su_box] with "Cons" and its list
$consBlockPattern = '\[su_box(?:\s+[^\]]+)?\s+title="Cons"[^\]]*\]\s*\[su_list[^\]]*\](.*?)\s*\[/su_list\]\s*\[/su_box\]'

# Regular expression patterns to remove [su_row] and [su_column] tags
$rowColumnPattern = '\[/?su_(row|column)(?:\s+[^\]]+)?\]'

# Get all .md files within the content path and its subdirectories
$files = Get-ChildItem -Path $ContentPath -Filter "*.md" -Recurse

# Process each Markdown file
foreach ($file in $files) {
    Write-Host "Processing file: $($file.FullName)"
    try {
        # Read the content of the file
        $content = Get-Content -Path $file.FullName -Raw

        # Process "Pros" block: Extract title and indent list items
        $newContent = [regex]::Replace($content, '(?is)' + $prosBlockPattern, {
            param($match)
            "Pros:`n" + ($match.Groups[1].Value -split '\n' | Where-Object { $_ -like '*' -and $_ -notmatch '^\s*$' } | ForEach-Object { "  $_" } -join "`n")
        })

        # Process "Cons" block: Extract title and indent list items
        $newContent = [regex]::Replace($newContent, '(?is)' + $consBlockPattern, {
            param($match)
            "Cons:`n" + ($match.Groups[1].Value -split '\n' | Where-Object { $_ -like '*' -and $_ -notmatch '^\s*$' } | ForEach-Object { "  $_" } -join "`n")
        })

        # Remove [su_row] and [su_column] tags (case-insensitive)
        $newContent = $newContent -creplace '(?i)' + $rowColumnPattern, ''

        # Write the modified content back to the file
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "  Processed Pros/Cons and removed row/column shortcodes."
    }
    catch {
        Write-Error "Error processing file $($file.FullName): $_"
    }
}

Write-Host "Pros/Cons processing and Shortcodes removal complete."