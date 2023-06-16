# Définition d'un dictionnaire de scripts
$scripts = @{}

# Ajout des scripts au dictionnaire
$scripts["1"] = @{
    "Name" = "Desactiver redirection IE"
    "URL" = "https://raw.githubusercontent.com/DcSault/script_powershell/main/desactiver_redirection_ie.ps1"
}

# Affichage des scripts disponibles
Write-Host "Scripts disponibles :"
$scripts.Keys | ForEach-Object {
    Write-Host ("{0} - {1}" -f $_, $scripts[$_].Name)
}

# Demande à l'utilisateur de choisir un script à exécuter
$scriptChoice = Read-Host -Prompt "Entrez le numéro du script à exécuter"

# Vérifie si le script choisi existe dans le dictionnaire
if ($scripts.ContainsKey($scriptChoice)) {
    # Téléchargement du script choisi
    $chosenScript = $scripts[$scriptChoice]
    $scriptOutput = Join-Path $env:TEMP ($chosenScript.Name + ".ps1")
    Invoke-WebRequest -Uri $chosenScript.URL -OutFile $scriptOutput -UseBasicParsing

    # Exécution du script choisi
    . $scriptOutput
} else {
    Write-Host "Le script choisi n'existe pas."
}
