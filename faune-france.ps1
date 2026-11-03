
$urls = @(
    "https://www.faune-france.org/",
    "https://www.faune-france.org/index.php",
    "https://www.faune-france.org/index.php?m_id=1351&content=news",
    "https://www.faune-france.org/index.php?m_id=1164",
    "https://faune-france.org/",
    "https://faune-france.org/index.php?m_id=1351&content=news"
)

$browsers = @(
    @{
        Name = "Chrome Windows"
        UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
    },
    @{
        Name = "Firefox Windows"
        UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0"
    },
    @{
        Name = "Edge Windows"
        UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
    },
    @{
        Name = "Safari macOS"
        UserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
    },
    @{
        Name = "Chrome Android"
        UserAgent = "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36"
    },
    @{
        Name = "Googlebot"
        UserAgent = "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    },
    @{
        Name = "Curl"
        UserAgent = "curl/8.10.0"
    }
)

$results = @()

foreach ($browser in $browsers) {

    Write-Host ""
    Write-Host "=========================================="
    Write-Host "NAVIGATEUR : $($browser.Name)"
    Write-Host "=========================================="

    foreach ($url in $urls) {

        Write-Host ""
        Write-Host "URL : $url"

        try {
            $response = Invoke-WebRequest `
                -Uri $url `
                -UserAgent $browser.UserAgent `
                -Headers @{
                    "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
                    "Accept-Language" = "fr-FR,fr;q=0.9,en;q=0.8"
                } `
                -MaximumRedirection 5 `
                -TimeoutSec 30 `
                -ErrorAction Stop

            $status = [int]$response.StatusCode
            $server = $response.Headers["Server"]
            $size = $response.Content.Length

            Write-Host "HTTP : $status"
            Write-Host "SERVER : $server"
            Write-Host "TAILLE : $size"

            $results += [PSCustomObject]@{
                Browser = $browser.Name
                URL = $url
                Status = $status
                Server = $server
                Size = $size
            }
        }
        catch {
            $status = 0
            $server = ""

            if ($_.Exception.Response) {
                $status = [int]$_.Exception.Response.StatusCode
                $server = $_.Exception.Response.Headers["Server"]
            }

            Write-Host "HTTP : $status"
            Write-Host "SERVER : $server"
            Write-Host "ERREUR : $($_.Exception.Message)"

            $results += [PSCustomObject]@{
                Browser = $browser.Name
                URL = $url
                Status = $status
                Server = $server
                Size = 0
            }
        }

        Start-Sleep -Milliseconds 300
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "RÉSUMÉ DES TESTS"
Write-Host "=========================================="

$results | Format-Table Browser, Status, Server, Size -AutoSize

$results |
    Export-Csv "./faune-france-tests.csv" -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Résultats enregistrés dans faune-france-tests.csv"