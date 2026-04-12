# fix_all_logos.ps1 — Complete club logo fetch with pilicense=any
$ErrorActionPreference = 'Continue'
$jsonPath = "E:\lineupx\assets\data\players.json"
$players = Get-Content $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host "Loaded $($players.Count) players" -ForegroundColor Cyan

# Complete club → Wikipedia F.C. article mapping
$clubWiki = @{
    "Inter Miami"         = "Inter_Miami_CF"
    "Al Nassr"            = "Al_Nassr_FC"
    "Paris Saint-Germain" = "Paris_Saint-Germain_F.C."
    "Manchester City"     = "Manchester_City_F.C."
    "Barcelona"           = "FC_Barcelona"
    "Inter"               = "Inter_Milan"
    "Real Madrid"         = "Real_Madrid_CF"
    "Liverpool"           = "Liverpool_F.C."
    "Bayern Munich"       = "FC_Bayern_Munich"
    "Al Hilal"            = "Al_Hilal_SFC"
    "Roma"                = "A.S._Roma"
    "Arsenal"             = "Arsenal_F.C."
    "AC Milan"            = "AC_Milan"
    "River Plate"         = "Club_Atletico_River_Plate"
    "Besiktas"            = "Besiktas_J.K."
    "Bayer Leverkusen"    = "Bayer_04_Leverkusen"
    "Napoli"              = "S.S.C._Napoli"
    "Newcastle United"    = "Newcastle_United_F.C."
    "Real Sociedad"       = "Real_Sociedad"
    "Al Ahli"             = "Al-Ahli_Saudi_FC"
    "Flamengo"            = "CR_Flamengo"
    "Galatasaray"         = "Galatasaray_S.K._(football)"
    "Atletico Madrid"     = "Atletico_Madrid"
    "Sporting CP"         = "Sporting_CP"
    "Juventus"            = "Juventus_F.C."
    "Chelsea"             = "Chelsea_F.C."
    "Porto"               = "FC_Porto"
    "Lyon"                = "Olympique_Lyonnais"
    "Lazio"               = "S.S._Lazio"
    "Ajax"                = "AFC_Ajax"
    "Benfica"             = "S.L._Benfica"
    "RB Leipzig"          = "RB_Leipzig"
    "Borussia Dortmund"   = "Borussia_Dortmund"
    "Fenerbahce"          = "Fenerbahce_S.K._(football)"
    "PSV"                 = "PSV_Eindhoven"
    "Marseille"           = "Olympique_de_Marseille"
    "Valencia"            = "Valencia_CF"
    "Atalanta"            = "Atalanta_BC"
    "Lille"               = "Lille_OSC"
    "Monaco"              = "AS_Monaco_FC"
    "Al Ittihad"          = "Al-Ittihad_Club_(Jeddah)"
    "Tottenham"           = "Tottenham_Hotspur_F.C."
    "Aston Villa"         = "Aston_Villa_F.C."
    "Manchester United"   = "Manchester_United_F.C."
    "Los Angeles FC"      = "Los_Angeles_FC"
    "LA Galaxy"           = "LA_Galaxy"
    "Boca Juniors"        = "Boca_Juniors"
    "Sevilla"             = "Sevilla_FC"
    "Stuttgart"           = "VfB_Stuttgart"
    "Palmeiras"           = "SE_Palmeiras"
    "Feyenoord"           = "Feyenoord"
    "Emirates Club"       = "Emirates_Club"
    "Crystal Palace"      = "Crystal_Palace_F.C."
    "Wolverhampton"       = "Wolverhampton_Wanderers_F.C."
    "Real Betis"          = "Real_Betis"
    "West Ham"            = "West_Ham_United_F.C."
    "Brighton"            = "Brighton_%26_Hove_Albion_F.C."
    "Fluminense"          = "Fluminense_FC"
    "Cremonese"           = "U.S._Cremonese"
    "Fulham"              = "Fulham_F.C."
    "Internazionale"      = "Inter_Milan"
    "Club Brugge"         = "Club_Brugge_KV"
    "Como"                = "Como_1907"
    "Botafogo"            = "Botafogo_de_Futebol_e_Regatas"
    "AFC Bournemouth"     = "AFC_Bournemouth"
}

$clubs = @($players | Select-Object -ExpandProperty club -Unique | Where-Object { $_ -and $_ -ne '' })
$logoMap = @{}
$batchSize = 50

Write-Host "`n=== Fetching club logos with pilicense=any ===" -ForegroundColor Yellow

for ($i = 0; $i -lt $clubs.Count; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $clubs.Count - 1)
    $batch = $clubs[$i..$end]
    $batchNum = [Math]::Floor($i / $batchSize) + 1

    # Build wiki title → original club name mapping
    $wikiToClub = @{}
    $titlesList = @()
    foreach ($c in $batch) {
        $wikiTitle = if ($clubWiki.ContainsKey($c)) { $clubWiki[$c] } else { $c -replace ' ','_' }
        $wikiToClub[$wikiTitle] = $c
        $wikiToClub[$wikiTitle -replace '_',' '] = $c
        $titlesList += $wikiTitle
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
            pilicense   = 'any'
        } -TimeoutSec 30

        $finalToClub = @{}
        foreach ($key in $wikiToClub.Keys) { $finalToClub[$key] = $wikiToClub[$key] }

        if ($result.query.normalized) {
            foreach ($n in $result.query.normalized) {
                $from = $n.from
                $fromSpaced = $from -replace '_',' '
                if ($wikiToClub.ContainsKey($from))       { $finalToClub[$n.to] = $wikiToClub[$from] }
                elseif ($wikiToClub.ContainsKey($fromSpaced)) { $finalToClub[$n.to] = $wikiToClub[$fromSpaced] }
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
        Write-Host "  Batch $batchNum : logos=$($logoMap.Count)" -ForegroundColor Gray
    }
    catch {
        Write-Host "  Batch $batchNum : ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 400
}

Write-Host "`nClubs with logos: $($logoMap.Count) / $($clubs.Count)" -ForegroundColor Green

$missing = $clubs | Where-Object { -not $logoMap.ContainsKey($_) }
if ($missing.Count -gt 0) {
    Write-Host "`nStill missing:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" }
}

# Update players JSON
foreach ($p in $players) {
    $logo = if ($logoMap.ContainsKey($p.club)) { $logoMap[$p.club] } else { "" }
    $p | Add-Member -NotePropertyName "clubLogoUrl" -NotePropertyValue $logo -Force
}

$players | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8

Write-Host "`n=== DONE: $($logoMap.Count)/$($clubs.Count) clubs with logos ===" -ForegroundColor Cyan
$logoMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
    $short = $_.Value.Substring(0, [Math]::Min(90, $_.Value.Length))
    Write-Host "  $($_.Key) => $short..."
}
