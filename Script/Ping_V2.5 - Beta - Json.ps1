param (
    [Parameter(Mandatory = $true)]
    [string[]] $NomsHotes,
    [string] $RepertoireLogs = "Logs",
    [int] $DelaiEntrePings = 1
)

$ping = New-Object System.Net.NetworkInformation.Ping

if (-not (Test-Path -Path $RepertoireLogs)) {
    New-Item -ItemType Directory -Path $RepertoireLogs | Out-Null
}

$donneesHotes = @{}
$fichierLog = Join-Path -Path $RepertoireLogs -ChildPath "tous_les_hotes.json"

# Demande le numéro de dossier
$numeroDossier = Read-Host -Prompt "Entrez le numéro de dossier"

foreach ($NomHote in $NomsHotes) {
    $donneesHotes[$NomHote] = @{
        "LatenceMax" = 0
        "NombreErreurs" = 0
        "LatenceTotale" = 0
        "NombrePings" = 0
        "Resultats" = @()
        "NomPoste" = $env:COMPUTERNAME  # Ajoute le nom du poste au fichier JSON
        "NumeroDossier" = $numeroDossier  # Ajoute le numéro de dossier au fichier JSON
    }
}

$dureeArretSecondes = Read-Host -Prompt "Entrez la durée en secondes après laquelle le script doit s'arrêter (0 pour une exécution indéfinie)"

$heureDebut = Get-Date

while (($dureeArretSecondes -eq 0) -or ((Get-Date) - $heureDebut).TotalSeconds -lt $dureeArretSecondes) {
    foreach ($NomHote in $NomsHotes) {
        $resultat = $ping.Send($NomHote)

        $messageResultat = @{
            "Statut" = $resultat.Status.ToString()
            "Adresse" = $resultat.Address.IPAddressToString
            "TempsAllerRetour" = $resultat.RoundtripTime
            "Date" = (Get-Date -Format o)
        }

        if ($resultat.Status -eq [System.Net.NetworkInformation.IPStatus]::TimedOut) {
            $donneesHotes[$NomHote]["NombreErreurs"]++
        } else {
            $donneesHotes[$NomHote]["LatenceTotale"] += $messageResultat.TempsAllerRetour
            $donneesHotes[$NomHote]["LatenceMax"] = [Math]::Max($donneesHotes[$NomHote]["LatenceMax"], $messageResultat.TempsAllerRetour)
            $donneesHotes[$NomHote]["NombrePings"]++
        }

        if ($donneesHotes[$NomHote]["NombrePings"] -gt 0) {
            $latenceMoyenne = [Math]::Round($donneesHotes[$NomHote]["LatenceTotale"] / $donneesHotes[$NomHote]["NombrePings"])
        } else {
            $latenceMoyenne = 0
        }

        $donneesHotes[$NomHote]["LatenceMoyenne"] = $latenceMoyenne

        $donneesHotes[$NomHote]["Resultats"] += $messageResultat

        $donneesHotes | ConvertTo-Json -Depth 100 | Set-Content $fichierLog
    }

    Start-Sleep -Seconds $DelaiEntrePings
}
