<#
.SYNOPSIS
  Removes consecutive sequences of three or more empty Markdown links with URLs.

.DESCRIPTION
  This script identifies and removes sequences of three or more consecutive
  lines in Markdown files where each line consists solely of an empty
  Markdown link `[]()` followed immediately by a URL.

.PARAMETER ContentPath
  The path to your Hugo content directory. Default is "content".

.EXAMPLE
  .\remove-consecutive-empty-links-final.ps1 -ContentPath "content"

  Processes all .markdown files in the "content" directory and its subdirectories.

.EXAMPLE
  .\remove-consecutive-empty-links-final.ps1 -ContentPath "C:\path\to\your\content"

  Processes .markdown files in the specified content directory.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ContentPath = "content"
)

# Get all .markdown files recursively
$files = Get-ChildItem -Path $ContentPath -Filter "*.markdown" -Recurse

foreach ($file in $files) {
    Write-Host "Processing file: $($file.FullName)"
    try {
        $content = Get-Content -Path $file.FullName
        $updatedContent = @()
        $consecutiveCount = 0
        $startIndex = -1

        for ($i = 0; $i -lt $content.Count; $i++) {
            $line = $content[$i].Trim()
            # Updated Regex: Allows for optional whitespace before/after []() and URL
            if ($line -match '^\s*\[]\(\s*([^)]+?)\s*\)\s*$') {
                $consecutiveCount++
                if ($consecutiveCount -ge 3 -and $startIndex -eq -1) {
                    $startIndex = $i - 2
                }
            } else {
                if ($consecutiveCount -ge 3) {
                    # Skip the sequence of empty links
                } else {
                    # Add the lines that were part of a shorter sequence or not empty links
                    if ($startIndex -ne -1) {
                        for ($j = $startIndex; $j -le $i - $consecutiveCount; $j++) {
                            $updatedContent += $content[$j]
                        }
                        $startIndex = -1
                    }
                    $updatedContent += $line
                }
                $consecutiveCount = 0
            }
        }

        # Handle any trailing sequence of less than 3 empty links
        if ($consecutiveCount -lt 3 -and $startIndex -ne -1) {
            for ($j = $startIndex; $j -lt $content.Count - $consecutiveCount; $j++) {
                $updatedContent += $content[$j]
            }
        } elseif ($consecutiveCount -lt 3 -and $startIndex -eq -1) {
            $updatedContent += $content
        }

        Set-Content -Path $file.FullName -Value $updatedContent -Encoding UTF8
        Write-Host "  Processed file."

    } catch {
        Write-Error "Error processing file '$($file.FullName)': $_"
    }
}

Write-Host "Consecutive empty link removal process complete."