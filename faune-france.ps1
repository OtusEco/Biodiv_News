$id = "faune-france"
$name = "Faune-France"
$accounts = "@biolovision @LPOFrance"
$tags = "#faunefrance #biodiversité #ornithologie #science"

$url = "https://www.faune-france.org/index.php?m_id=1351&content=news"

$jsonFile = "./$id/$id.json"
$debugFile = "./$id/curl.log"

if (!(Test-Path "./$id")) {
    New-Item -ItemType Directory -Path "./$id" -Force | Out-Null
}

Write-Host "Récupération des actualités de $name..."

$curlOutput = curl.exe `
    -sS `
    -L `
    -v `
    --max-time 30 `
    -H "Accept: application/json, text/plain, */*" `
    -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36" `
    -o "$jsonFile" `
    -w "`nHTTP_STATUS:%{http_code}`nREMOTE_IP:%{remote_ip}`n" `
    $url 2> "$debugFile"

$curlExit = $LASTEXITCODE

Write-Host $curlOutput
Write-Host "Code retour CURL : $curlExit"

Get-Content "$debugFile" |
    Select-String "HTTP/|server:|location:|cf-|403|forbidden"

if ($curlExit -ne 0) {
    throw "Échec de connexion à Faune-France."
}

if ($curlOutput -notmatch "HTTP_STATUS:200") {
    throw "Faune-France inaccessible : $curlOutput"
}

if (!(Test-Path $jsonFile)) {
    throw "Le fichier JSON n'a pas été créé."
}

try {
    $data = Get-Content $jsonFile -Raw | ConvertFrom-Json -ErrorAction Stop
}
catch {
    throw "La réponse du serveur n'est pas un JSON valide."
}

if (!$data.data -or $data.data.Count -eq 0) {
    throw "Aucun article trouvé dans les données reçues."
}

$new = $data.data[0].title

Write-Host "Titre reçu : $new"
Write-Host "Diagnostic terminé."