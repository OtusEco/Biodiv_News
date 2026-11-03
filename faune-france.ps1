# variables
$id = "faune-france"
$name = "Faune-France"
$accounts = "@biolovision @LPOFrance"
$tags = "#faunefrance #biodiversité #ornithologie #science"

$url = "https://www.faune-france.org/index.php?m_id=1351&content=news"

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"
    "Accept" = "application/json, text/plain, */*"
}

try {
    Write-Host "Récupération des actualités de $name..."

    $response = Invoke-WebRequest `
        -Uri $url `
        -Headers $headers `
        -ErrorAction Stop

    Write-Host "Réponse HTTP : $($response.StatusCode)"

    $data = $response.Content | ConvertFrom-Json

    # compare two title
    $old = (Get-Content "./$id/$id.json" -Raw | ConvertFrom-Json).data[0].title
    $new = $data.data[0].title

    if ( $new -eq $old ) {
        echo "Le dernier article de $name est déjà existant dans la base de donnée"
    } else {

        Write-Host "Nouvel article détecté : $new"

        $data | ConvertTo-Json -Depth 100 | Set-Content "./$id/$id.json" -Encoding UTF8

        $title = $data.data[0].title
        $nid = $data.data[0].nid

        $link = "https://www.faune-france.org/index.php?m_id=1164&a=$nid#FN$nid"

        Write-Host "Titre : $title"
        Write-Host "Lien : $link"

        ./end_push.ps1
    }
}
catch {
    Write-Host "ERREUR lors de la récupération des actualités de $name"
    Write-Host "Message : $($_.Exception.Message)"

    if ($_.Exception.Response) {
        Write-Host "Code HTTP : $([int]$_.Exception.Response.StatusCode)"
        Write-Host "En-têtes HTTP :"
        $_.Exception.Response.Headers
    }

    throw
}