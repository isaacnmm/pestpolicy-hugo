# Path to your Hugo website's public directory (adjust if needed)
$publicPath = "C:\Users\Zak\Documents\pestpolicy-hugo\public"

# Pattern to identify Amazon product links with your tag
$amazonLinkPattern = 'https?://(?:www\.)?amazon\.com/dp/([A-Z0-9]{10})/\?(?:.*&)tag=p-policy-\d{2}(?:&|$)'

# Array to store broken links
$brokenLinks = @()

# Get all HTML files in the public directory
$htmlFiles = Get-ChildItem -Path $publicPath -Filter "*.html" -Recurse

if (-not (Test-Path $publicPath -PathType Container)) {
    Write-Warning "Public directory not found at '$publicPath'. Please ensure your Hugo site is built."
    exit
}

foreach ($file in $htmlFiles) {
    Write-Host "Processing file: $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw

    # Find all Amazon product links matching the pattern
    $amazonLinks = [regex]::Matches($content, $amazonLinkPattern) | ForEach-Object {$_.Value} | Select-Object -Unique

    foreach ($link in $amazonLinks) {
        Write-Host "Checking link: $link"
        try {
            $response = Invoke-WebRequest -Uri $link -Method Head -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -ne 200) {
                Write-Warning "Broken Amazon link found in $($file.FullName): $link (Status Code: $($response.StatusCode))"
                $brokenLinks += [PSCustomObject]@{
                    File = $file.FullName
                    Link = $link
                    StatusCode = $response.StatusCode
                }
            }
            # Be respectful and add a delay to avoid rate limiting
            Start-Sleep -Seconds 2
        }
        catch {
            Write-Error "Error checking link $($link) in $($file.FullName): $_"
            $brokenLinks += [PSCustomObject]@{
                File = $file.FullName
                Link = $link
                StatusCode = "Error"
            }
            # Still add a delay in case of errors
            Start-Sleep -Seconds 2
        }
    }
}

if ($brokenLinks.Count -gt 0) {
    Write-Host "--- Broken Amazon Product Links Found ---"
    $brokenLinks | Format-Table
    # Export broken links to a CSV file
    $brokenLinks | Export-Csv -Path "broken_amazon_product_links.csv" -NoTypeInformation
} else {
    Write-Host "No broken Amazon product links found matching the specified pattern."
}