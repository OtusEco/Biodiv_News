# variables
$id = "faune-france"
$name = "Faune-France"
$accounts = "@biolovision @LPOFrance"
$tags ="#faunefrance #biodiversité #ornithologie #science"

# compare two title
$old = (Get-Content ./$id/$id.json | ConvertFrom-Json).data[0].title

$new = (Invoke-WebRequest "$worker_url/index.php?m_id=1351&content=news" -Headers @{ Authorization = "Bearer $worker_token"; Projet = "biodiv_news" } | ConvertFrom-Json).data[0].title

if ( $new -eq $old ) {
echo "Le dernier article de $name est déjà existant dans la base de donnée"
} else {
Invoke-WebRequest -Uri "$worker_url/index.php?m_id=1351&content=news" -Headers @{ Authorization = "Bearer $worker_token"; Projet = "biodiv_news" } -OutFile "./$id/$id.json"

$title = (Get-Content ./$id/$id.json | ConvertFrom-Json).data[0].title
$nid = (Get-Content ./$id/$id.json | ConvertFrom-Json).data[0].nid
$link = "https://www.faune-france.org/index.php?m_id=1164&a=$nid#FN$nid"

./end_push.ps1
}