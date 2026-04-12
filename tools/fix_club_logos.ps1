# fix_club_logos.ps1 — Re-fetch club logos with proper F.C. article mappings
$ErrorActionPreference = 'Continue'
$jsonPath = "E:\lineupx\assets\data\players.json"
$players = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host "Loaded $($players.Count) players" -ForegroundColor Cyan

# Complete mapping: JSON club name → Wikipedia article title
$clubWiki = @{
    "Inter Miami"        = "Inter Miami CF"
    "Al Nassr"           = "Al Nassr FC"
    "Paris Saint-Germain"= "Paris Saint-Germain F.C."
    "Manchester City"    = "Manchester City F.C."
    "Barcelona"          = "FC Barcelona"
    "Inter"              = "Inter Milan"
    "Real Madrid"        = "Real Madrid CF"
    "Liverpool"          = "Liverpool F.C."
    "Bayern Munich"      = "FC Bayern Munich"
    "Al Hilal"           = "Al Hilal SFC"
    "Roma"               = "A.S. Roma"
    "Arsenal"            = "Arsenal F.C."
    "AC Milan"           = "AC Milan"
    "River Plate"        = "Club Atletico River Plate"
    "Besiktas"           = "Besiktas J.K."
    "Bayer Leverkusen"   = "Bayer 04 Leverkusen"
    "Napoli"             = "S.S.C. Napoli"
    "Newcastle United"   = "Newcastle United F.C."
    "Real Sociedad"      = "Real Sociedad"
    "Al Ahli"            = "Al-Ahli Saudi FC"
    "Flamengo"           = "CR Flamengo"
    "Galatasaray"        = "Galatasaray S.K. (football)"
    "Atletico Madrid"    = "Atletico Madrid"
    "Sporting CP"        = "Sporting CP"
    "Juventus"           = "Juventus F.C."
    "Chelsea"            = "Chelsea F.C."
    "Porto"              = "FC Porto"
    "Lyon"               = "Olympique Lyonnais"
    "Lazio"              = "S.S. Lazio"
    "Ajax"               = "AFC Ajax"
    "Benfica"            = "S.L. Benfica"
    "RB Leipzig"         = "RB Leipzig"
    "Borussia Dortmund"  = "Borussia Dortmund"
    "Fenerbahce"         = "Fenerbahce S.K. (football)"
    "PSV"                = "PSV Eindhoven"
    "Marseille"          = "Olympique de Marseille"
    "Valencia"           = "Valencia CF"
    "Atalanta"           = "Atalanta BC"
    "Lille"              = "Lille OSC"
    "Monaco"             = "AS Monaco FC"
    "Al Ittihad"         = "Al-Ittihad Club (Jeddah)"
    "Tottenham"          = "Tottenham Hotspur F.C."
    "Aston Villa"        = "Aston Villa F.C."
    "Manchester United"  = "Manchester United F.C."
    "Los Angeles FC"     = "Los Angeles FC"
    "LA Galaxy"          = "LA Galaxy"
    "Boca Juniors"       = "Boca Juniors"
    "Sevilla"            = "Sevilla FC"
    "Stuttgart"          = "VfB Stuttgart"
    "Palmeiras"          = "SE Palmeiras"
    "Feyenoord"          = "Feyenoord"
    "Emirates Club"      = "Emirates Club"
    "Crystal Palace"     = "Crystal Palace F.C."
    "Wolverhampton"      = "Wolverhampton Wanderers F.C."
    "Real Betis"         = "Real Betis"
    "West Ham"           = "West Ham United F.C."
    "Brighton"           = "Brighton %26 Hove Albion F.C."
    "Fluminense"         = "Fluminense FC"
    "Cremonese"          = "U.S. Cremonese"
    "Fulham"             = "Fulham F.C."
    "Internazionale"     = "Inter Milan"
    "Club Brugge"        = "Club Brugge KV"
    "Como"               = "Como 1907"
    "Botafogo"           = "Botafogo de Futebol e Regatas"
    "AFC Bournemouth"    = "AFC Bournemouth"
}

$clubs = @($players | Select-Object -ExpandProperty club -Unique | Where-Object { $_ -and $_ -ne '' })
$logoMap = @{}
$batchSize = 50
$clubBatches = [Math]::Ceiling($clubs.Count / $batchSize)

Write-Host "=== Fetching club logos ($($clubs.Count) clubs) ===" -ForegroundColor Yellow

for ($i = 0; $i -lt $clubs.Count; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $clubs.Count - 1)
    $batch = $clubs[$i..$end]
    $batchNum = [Math]::Floor($i / $batchSize) + 1

    $wikiToClub = @{}
    $titlesList = @()
    foreach ($c in $batch) {
        $wikiTitle = if ($clubWiki.ContainsKey($c)) { $clubWiki[$c] } else { $c }
        $wikiKey = $wikiTitle -replace ' ', '_'
        $wikiToClub[$wikiTitle] = $c
        $wikiToClub[$wikiKey -replace '_',' '] = $c
        $titlesList += $wikiKey
    }
    $titles = $titlesList -join '|'

    try {
        $result = Invoke-RestMethod -Uri "https://en.wikipedia.org/w/api.php" -Body @{
            action      = 'query'
            titles      = $titles
            prop        = 'pageimages'
            pithumbsize = 100
            format      = 'json'
            redirects   = 1
        } -TimeoutSec 30

        # Track through normalizations and redirects
        $finalToClub = @{}
        foreach ($key in $wikiToClub.Keys) { $finalToClub[$key] = $wikiToClub[$key] }

        if ($result.query.normalized) {
            foreach ($n in $result.query.normalized) {
                $from = $n.from -replace '_',' '
                if ($wikiToClub.ContainsKey($from)) { $finalToClub[$n.to] = $wikiToClub[$from] }
                elseif ($wikiToClub.ContainsKey($n.from)) { $finalToClub[$n.to] = $wikiToClub[$n.from] }
            }
        }
        if ($result.query.redirects) {
            foreach ($r in $result.query.redirects) {
                if ($finalToClub.ContainsKey($r.from)) { $finalToClub[$r.to] = $finalToClub[$r.from] }
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
        Write-Host "  Batch $batchNum/$clubBatches : logos = $($logoMap.Count)" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Batch $batchNum/$clubBatches : ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 400
}

Write-Host "`nClubs with logos: $($logoMap.Count) / $($clubs.Count)" -ForegroundColor Green

# Show which clubs are missing
$missing = $clubs | Where-Object { -not $logoMap.ContainsKey($_) }
if ($missing.Count -gt 0) {
    Write-Host "`nMissing logos for:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" }
}

# Update players
foreach ($p in $players) {
    $logo = if ($logoMap.ContainsKey($p.club)) { $logoMap[$p.club] } else { "" }
    $p | Add-Member -NotePropertyName "clubLogoUrl" -NotePropertyValue $logo -Force
}

$players | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8

Write-Host "`n=== DONE ===" -ForegroundColor Cyan
Write-Host "Clubs with logos: $($logoMap.Count) / $($clubs.Count)"

Write-Host "`nAll logos:" -ForegroundColor Yellow
$logoMap.GetEnumerator() | Sort-Object Name | ForEach-Object { 
    Write-Host "  $($_.Key) => $($_.Value.Substring(0, [Math]::Min(80, $_.Value.Length)))..." 
}
