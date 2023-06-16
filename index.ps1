# Définition d'une hiérarchie de scripts
$scripts = @{}

# Ajout des scripts au dictionnaire
$scripts["1"] = @{
    "Name" = "Dossier 1"
    "Scripts" = @{
        "1" = @{
            "Name" = "Desactiver redirection IE"
            "URL" = "https://raw.githubusercontent.com/DcSault/script_powershell/main/desactiver_redirection_ie.ps1"
        }
        "2" = @{
            "Name" = "Nouveau script"
            "URL" = "https://example.com/nouveau_script.ps1"
        }
    }
}

# Boucle principale
while ($true) {
    # Affichage des scripts disponibles
    Write-Host "`n=== MENU PRINCIPAL ==="
    $scripts.Keys | ForEach-Object {
        Write-Host ("{0} - {1}" -f $_, $scripts[$_].Name)
    }
    Write-Host "Q - Quitter"

    # Demande à l'utilisateur de choisir un script à exécuter
    $folderChoice = Read-Host -Prompt "`nEntrez le numéro du dossier à ouvrir ou 'Q' pour quitter"

    # Vérifie si l'utilisateur a choisi de quitter
    if ($folderChoice -eq "Q") {
        break
    }

    # Vérifie si le dossier choisi existe dans le dictionnaire
    if ($scripts.ContainsKey($folderChoice)) {
        $chosenFolder = $scripts[$folderChoice]
        while ($true) {
            # Affichage des scripts disponibles
            Write-Host "`n=== MENU DU DOSSIER {0} ===" -f $chosenFolder.Name
            $chosenFolder.Scripts.Keys | ForEach-Object {
                Write-Host ("{0} - {1}" -f $_, $chosenFolder.Scripts[$_].Name)
            }
            Write-Host "R - Retour"
            Write-Host "Q - Quitter"

            # Demande à l'utilisateur de choisir un script à exécuter
            $scriptChoice = Read-Host -Prompt "`nEntrez le numéro du script à exécuter, 'R' pour revenir ou 'Q' pour quitter"

            # Vérifie si l'utilisateur a choisi de quitter ou de revenir
            if ($scriptChoice -eq "Q") {
                exit
            } elseif ($scriptChoice -eq "R") {
                break
            }

            # Vérifie si le script choisi existe dans le dictionnaire
            if ($chosenFolder.Scripts.ContainsKey($scriptChoice)) {
                # Téléchargement du script choisi
                Write-Host "`n=== TÉLÉCHARGEMENT DU SCRIPT ==="
                $chosenScript = $chosenFolder.Scripts[$scriptChoice]
                $scriptOutput = Join-Path $env:TEMP ($chosenScript.Name + ".ps1")
                Invoke-WebRequest -Uri $chosenScript.URL -OutFile $scriptOutput -UseBasicParsing

                # Exécution du script choisi
                Write-Host "`n=== EXÉCUTION DU SCRIPT ==="
                . $scriptOutput
            } else {
                Write-Host "`nErreur : Le script choisi n'existe pas."
            }
        }
    } else {
        Write-Host "`nErreur : Le dossier choisi n'existe pas."
    }
}
