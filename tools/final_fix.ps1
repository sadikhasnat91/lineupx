# final_fix.ps1 — Re-fetch player photos with pilicense=any + fix Brighton
$ErrorActionPreference = 'Continue'
$jsonPath = "E:\lineupx\assets\data\players.json"
$players = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host "Loaded $($players.Count) players" -ForegroundColor Cyan

# ── Fix Brighton logo ──
$brightonLogo = "https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Brighton_and_Hove_Albion_FC_crest.svg/120px-Brighton_and_Hove_Albion_FC_crest.svg.png"
foreach ($p in $players) {
    if ($p.club -eq "Brighton") {
        $p.clubLogoUrl = $brightonLogo
    }
}
Write-Host "Fixed Brighton logo" -ForegroundColor Green

# ── Re-fetch player photos with pilicense=any ──
$photoMap = @{}
$batchSize = 50
$totalBatches = [Math]::Ceiling($players.Count / $batchSize)
Write-Host "`n=== Re-fetching player photos with pilicense=any ($totalBatches batches) ===" -ForegroundColor Yellow

for ($i = 0; $i -lt $players.Count; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $players.Count - 1)
    $batch = $players[$i..$end]
    $batchNum = [Math]::Floor($i / $batchSize) + 1

    $titleToName = @{}
    foreach ($p in $batch) {
        $t = $p.name -replace ' ', '_'
        $titleToName[$t] = $p.name
    }
    $titles = ($batch | ForEach-Object { $_.name -replace ' ', '_' }) -join '|'

    try {
        $result = Invoke-RestMethod -Uri "https://en.wikipedia.org/w/api.php" -Body @{
            action      = 'query'
            titles      = $titles
            prop        = 'pageimages'
            pithumbsize = 200
            format      = 'json'
            redirects   = 1
            pilicense   = 'any'
        } -TimeoutSec 30

        $finalToOriginal = @{}
        foreach ($key in $titleToName.Keys) {
            $finalToOriginal[$key -replace '_', ' '] = $titleToName[$key]
        }

        if ($result.query.normalized) {
            foreach ($n in $result.query.normalized) {
                if ($titleToName.ContainsKey($n.from)) {
                    $finalToOriginal[$n.to] = $titleToName[$n.from]
                }
            }
        }
        if ($result.query.redirects) {
            foreach ($r in $result.query.redirects) {
                foreach ($key in @($finalToOriginal.Keys)) {
                    if ($key -eq $r.from) {
                        $finalToOriginal[$r.to] = $finalToOriginal[$key]
                    }
                }
            }
        }

        foreach ($prop in $result.query.pages.PSObject.Properties) {
            $page = $prop.Value
            if ($page.thumbnail -and $page.thumbnail.source -and [int]$prop.Name -gt 0) {
                $title = $page.title
                if ($finalToOriginal.ContainsKey($title)) {
                    $photoMap[$finalToOriginal[$title]] = $page.thumbnail.source
                }
            }
        }
        Write-Host "  Batch $batchNum/$totalBatches : photos=$($photoMap.Count)" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Batch $batchNum/$totalBatches : ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 400
}

Write-Host "`nPlayers with real photos: $($photoMap.Count) / $($players.Count)" -ForegroundColor Green

# ── Apply photos to JSON ──
foreach ($p in $players) {
    if ($photoMap.ContainsKey($p.name)) {
        $p.imageUrl = $photoMap[$p.name]
    }
    # Keep existing imageUrl (empty or from previous run) if no new photo found
}

$players | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8

$withPhoto = ($players | Where-Object { $_.imageUrl -and $_.imageUrl -ne '' }).Count
$withLogo = ($players | Where-Object { $_.clubLogoUrl -and $_.clubLogoUrl -ne '' }).Count

Write-Host "`n=== FINAL STATS ===" -ForegroundColor Cyan
Write-Host "  Players with real photos : $withPhoto / $($players.Count)"
Write-Host "  Players with club logos  : $withLogo / $($players.Count)"
Write-Host "  Saved to $jsonPath"
