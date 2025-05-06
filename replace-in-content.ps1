# Path to your Hugo posts directory
$postsPath = "C:\Users\Zak\Documents\pestpolicy-hugo\content\posts"

# Iterate through all Markdown files in the posts directory
Get-ChildItem -Path $postsPath -Filter "*.markdown" -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $content = Get-Content $filePath
    $updatedContent = $content
    $replaced = $false

    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -cmatch "(?i).*permalink:.*") {
            $updatedContent[$i] = $content[$i] -creplace "(?i)(.*)permalink:(.*)", '$1slug:$2'
            $replaced = $true
        }
    }

    if ($replaced) {
        Set-Content $filePath -Value $updatedContent
        Write-Host "Aggressively replaced 'permalink' with 'slug' in $($_.Name)"
    }
}

Write-Host "`nFinished processing all Markdown files."