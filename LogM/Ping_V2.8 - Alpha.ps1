# Définition des paramètres du script
param (
    [Parameter(Mandatory = $true)]
    [string[]] $NomsHotes,  # Liste des noms d'hôtes à pinger

    [string] $RepertoireLogs = "Logs",  # Dossier de destination pour les logs

    [int] $DelaiEntrePings = 1  # Délai en secondes entre les pings
)

# Demande à l'utilisateur s'il souhaite enregistrer uniquement les changements de latence
$reponseEnregistrerChangementsLatence = Read-Host -Prompt "Voulez-vous enregistrer uniquement les changements de latence ? (oui/non)"
$EnregistrerChangementsLatence = $reponseEnregistrerChangementsLatence -eq "oui"

# Création du répertoire de logs si nécessaire
if (-not (Test-Path -Path $RepertoireLogs)) {
    New-Item -ItemType Directory -Path $RepertoireLogs | Out-Null
}

# Initialisation des données pour chaque hôte
$donneesHotes = @{}
$nomPoste = $env:COMPUTERNAME
$numeroDossier = Read-Host -Prompt "Entrez le numéro de dossier"

# Fonction pour générer une chaîne aléatoire
function Generate-RandomString {
    param ([int] $Length)
    $characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $randomString = ""
    for ($i = 1; $i -le $Length; $i++) {
        $randomIndex = Get-Random -Minimum 0 -Maximum $characters.Length
        $randomChar = $characters[$randomIndex]
        $randomString += $randomChar
    }
    return $randomString
}

# Création du chemin du fichier log
$nombreAleatoire = Generate-RandomString -Length 6
$fichierLog = Join-Path -Path $RepertoireLogs -ChildPath "${nomPoste}-${numeroDossier}-${nombreAleatoire}.json"

# Configuration des données initiales pour chaque hôte
foreach ($NomHote in $NomsHotes) {
    $donneesHotes[$NomHote] = @{
        "LatenceMax" = 0
        "NombreErreurs" = 0
        "LatenceTotale" = 0
        "NombrePings" = 0
        "Resultats" = @()
        "NomPoste" = $nomPoste
        "NumeroDossier" = $numeroDossier
        "DerniereLatence" = -1
    }
}

# Demande de la durée d'exécution du script
$dureeArretSecondes = Read-Host -Prompt "Entrez la durée en secondes après laquelle le script doit s'arrêter (0 pour une exécution indéfinie)"
$heureDebut = Get-Date

# Fonction pour effectuer un ping
function EffectuerPing {
    param ([string] $NomHote)
    try {
        $resultat = Test-Connection -ComputerName $NomHote -Count 1 -ErrorAction Stop
        $statut = "Success"
        $tempsAllerRetour = $resultat.ResponseTime
    } catch {
        $statut = "Failed"
        $tempsAllerRetour = 0
    }

    @{
        "Statut" = $statut
        "Adresse" = $NomHote
        "TempsAllerRetour" = $tempsAllerRetour
        "Date" = (Get-Date -Format o)
    }
}

# Boucle principale du script pour le ping des hôtes
do {
    foreach ($NomHote in $NomsHotes) {
        $resultatPing = EffectuerPing -NomHote $NomHote
        $donneesHote = $donneesHotes[$NomHote]

        # Enregistrement des résultats de ping
        # Si l'option d'enregistrement des changements de latence est activée,
        # enregistre seulement si le résultat diffère du dernier ping
        if (-not $EnregistrerChangementsLatence -or $donneesHote.DerniereLatence -ne $resultatPing.TempsAllerRetour) {
            $donneesHote.Resultats += $resultatPing
            $donneesHote.LatenceTotale += $resultatPing.TempsAllerRetour
            $donneesHote.LatenceMax = [Math]::Max($donneesHote.LatenceMax, $resultatPing.TempsAllerRetour)
            $donneesHote.NombrePings++
            $donneesHote.DerniereLatence = $resultatPing.TempsAllerRetour
        }
    }

    # Vérification pour sortir de la boucle si la durée spécifiée est dépassée
    if (($dureeArretSecondes -ne 0) -and ((Get-Date) - $heureDebut).TotalSeconds -ge $dureeArretSecondes) {
        break
    }

    Start-Sleep -Seconds $DelaiEntrePings
} while ($true)

# Exécution d'un dernier ping pour chaque hôte avant la fin du script
foreach ($NomHote in $NomsHotes) {
    $resultatPingFinal = EffectuerPing -NomHote $NomHote
    $donneesHote = $donneesHotes[$NomHote]

    # Enregistrement systématique du dernier ping
    $donneesHote.Resultats += $resultatPingFinal
    $donneesHote.NombrePings++
    if ($resultatPingFinal.Statut -eq "Success") {
        $donneesHote.LatenceTotale += $resultatPingFinal.TempsAllerRetour
        $donneesHote.LatenceMax = [Math]::Max($donneesHote.LatenceMax, $resultatPingFinal.TempsAllerRetour)
    } else {
        $donneesHote.NombreErreurs++
    }

    # Mise à jour de la latence moyenne
    if ($donneesHote.NombrePings -gt 0) {
        $donneesHote.LatenceMoyenne = [Math]::Round($donneesHote.LatenceTotale / $donneesHote.NombrePings)
    } else {
        $donneesHote.LatenceMoyenne = 0
    }
}

# Sauvegarde des données dans le fichier log
$donneesHotes | ConvertTo-Json -Depth 100 | Set-Content -Path $fichierLog
Write-Host "Les résultats ont été enregistrés dans le fichier $fichierLog"
