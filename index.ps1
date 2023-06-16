# Définition d'un dictionnaire de scripts
$scripts = @{}

# Ajout des scripts au dictionnaire
$scripts["1"] = @{
    "Name" = "Desactiver redirection IE"
    "URL" = "https://raw.githubusercontent.com/DcSault/script_powershell/main/desactiver_redirection_ie.ps1"
}

$scripts["2"] = @{
    "Name" = "Nouveau script"
    "URL" = "https://example.com/nouveau_script.ps1"
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
    $scriptChoice = Read-Host -Prompt "`nEntrez le numero du script a executer ou 'Q' pour quitter"

    # Vérifie si l'utilisateur a choisi de quitter
    if ($scriptChoice.ToUpper() -eq "Q") {
        break
    }

    # Vérifie si le script choisi existe dans le dictionnaire
    if ($scripts.ContainsKey($scriptChoice)) {
        # Téléchargement du script choisi
        Write-Host "`n=== TELECHARGEMENT DU SCRIPT ==="
        $chosenScript = $scripts[$scriptChoice]
        $scriptOutput = Join-Path $env:TEMP ($chosenScript.Name + ".ps1")
        Invoke-WebRequest -Uri $chosenScript.URL -OutFile $scriptOutput -UseBasicParsing

        # Exécution du script choisi
        Write-Host "`n=== EXECUTION DU SCRIPT ==="
        . $scriptOutput

        # Ajoute une ligne vide après l'exécution du script
        Write-Host "`n"
    } else {
        Write-Host "`nErreur : Le script choisi n'existe pas."
    }
}
