# fetch_images.ps1 — Fetch real player photos & club logos from Wikipedia
# Uses MediaWiki API batch query (50 titles/request) with redirect support

$ErrorActionPreference = 'Continue'
$jsonPath = "E:\lineupx\assets\data\players.json"
$players = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host "Loaded $($players.Count) players" -ForegroundColor Cyan

# ═══════════════════════════════════════════════════════════════════════════════
#  PHASE 1 — Player Photos
# ═══════════════════════════════════════════════════════════════════════════════
$photoMap = @{}
$batchSize = 50
$totalBatches = [Math]::Ceiling($players.Count / $batchSize)
Write-Host "`n=== Fetching player photos ($totalBatches batches) ===" -ForegroundColor Yellow

for ($i = 0; $i -lt $players.Count; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $players.Count - 1)
    $batch = $players[$i..$end]
    $batchNum = [Math]::Floor($i / $batchSize) + 1

    # Build title-to-name mapping
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
        } -TimeoutSec 30

        # Build reverse map: final Wikipedia title → original player name
        $finalToOriginal = @{}
        foreach ($key in $titleToName.Keys) {
            $finalToOriginal[$key -replace '_', ' '] = $titleToName[$key]
        }

        if ($result.query.normalized) {
            foreach ($n in $result.query.normalized) {
                $orig = $n.from
                if ($titleToName.ContainsKey($orig)) {
                    $finalToOriginal[$n.to] = $titleToName[$orig]
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

        Write-Host "  Batch $batchNum/$totalBatches : total photos = $($photoMap.Count)" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Batch $batchNum/$totalBatches : ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 400
}

Write-Host "`nPlayers with photos: $($photoMap.Count) / $($players.Count)" -ForegroundColor Green

# ═══════════════════════════════════════════════════════════════════════════════
#  PHASE 2 — Club Logos
# ═══════════════════════════════════════════════════════════════════════════════
$clubs = @($players | Select-Object -ExpandProperty club -Unique | Where-Object { $_ -and $_ -ne '' })
$logoMap = @{}

# Common short names → full Wikipedia article titles
$clubWiki = @{
    "Tottenham"       = "Tottenham Hotspur F.C."
    "Wolverhampton"   = "Wolverhampton Wanderers F.C."
    "Brighton"        = "Brighton & Hove Albion F.C."
    "Inter"           = "Inter Milan"
    "Internazionale"  = "Inter Milan"
    "Como"            = "Como 1907"
    "Emirates Club"   = "Emirates Club"
    "Crystal Palace"  = "Crystal Palace F.C."
    "AFC Bournemouth" = "AFC Bournemouth"
    "Fulham"          = "Fulham F.C."
    "West Ham"        = "West Ham United F.C."
    "Cremonese"       = "U.S. Cremonese"
}

$clubBatches = [Math]::Ceiling($clubs.Count / $batchSize)
Write-Host "`n=== Fetching club logos ($($clubs.Count) clubs, $clubBatches batches) ===" -ForegroundColor Yellow

for ($i = 0; $i -lt $clubs.Count; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $clubs.Count - 1)
    $batch = $clubs[$i..$end]
    $batchNum = [Math]::Floor($i / $batchSize) + 1

    $clubTitleMap = @{}
    foreach ($c in $batch) {
        $wikiTitle = if ($clubWiki.ContainsKey($c)) { $clubWiki[$c] } else { $c }
        $clubTitleMap[$wikiTitle -replace ' ', '_'] = $c
    }

    $titles = ($batch | ForEach-Object {
        $c = $_
        $wt = if ($clubWiki.ContainsKey($c)) { $clubWiki[$c] } else { $c }
        $wt -replace ' ', '_'
    }) -join '|'

    try {
        $result = Invoke-RestMethod -Uri "https://en.wikipedia.org/w/api.php" -Body @{
            action      = 'query'
            titles      = $titles
            prop        = 'pageimages'
            pithumbsize = 100
            format      = 'json'
            redirects   = 1
        } -TimeoutSec 30

        $finalToClub = @{}
        foreach ($key in $clubTitleMap.Keys) {
            $finalToClub[$key -replace '_', ' '] = $clubTitleMap[$key]
        }
        if ($result.query.normalized) {
            foreach ($n in $result.query.normalized) {
                if ($clubTitleMap.ContainsKey($n.from)) {
                    $finalToClub[$n.to] = $clubTitleMap[$n.from]
                }
            }
        }
        if ($result.query.redirects) {
            foreach ($r in $result.query.redirects) {
                foreach ($key in @($finalToClub.Keys)) {
                    if ($key -eq $r.from) { $finalToClub[$r.to] = $finalToClub[$key] }
                }
            }
        }

        foreach ($prop in $result.query.pages.PSObject.Properties) {
            $page = $prop.Value
            if ($page.thumbnail -and $page.thumbnail.source -and [int]$prop.Name -gt 0) {
                if ($finalToClub.ContainsKey($page.title)) {
                    $logoMap[$finalToClub[$page.title]] = $page.thumbnail.source
                }
            }
        }

        Write-Host "  Club batch $batchNum/$clubBatches : total logos = $($logoMap.Count)" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Club batch $batchNum/$clubBatches : ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }

    Start-Sleep -Milliseconds 400
}

Write-Host "`nClubs with logos: $($logoMap.Count) / $($clubs.Count)" -ForegroundColor Green

# ═══════════════════════════════════════════════════════════════════════════════
#  PHASE 3 — Update JSON
# ═══════════════════════════════════════════════════════════════════════════════
Write-Host "`n=== Updating players.json ===" -ForegroundColor Yellow

foreach ($p in $players) {
    $img  = if ($photoMap.ContainsKey($p.name)) { $photoMap[$p.name] } else { "" }
    $logo = if ($logoMap.ContainsKey($p.club))  { $logoMap[$p.club]  } else { "" }

    $p | Add-Member -NotePropertyName "imageUrl"    -NotePropertyValue $img  -Force
    $p | Add-Member -NotePropertyName "clubLogoUrl" -NotePropertyValue $logo -Force
}

$players | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8

Write-Host "`n=== DONE ===" -ForegroundColor Cyan
Write-Host "  Players with real photos : $($photoMap.Count) / $($players.Count)"
Write-Host "  Clubs with logos         : $($logoMap.Count) / $($clubs.Count)"
Write-Host "  Saved to $jsonPath"

# Print some samples
Write-Host "`nSample photos:" -ForegroundColor Yellow
$photoMap.GetEnumerator() | Select-Object -First 8 | ForEach-Object { Write-Host "  $($_.Key) => $($_.Value)" }
Write-Host "`nSample logos:" -ForegroundColor Yellow
$logoMap.GetEnumerator() | Select-Object -First 8 | ForEach-Object { Write-Host "  $($_.Key) => $($_.Value)" }
