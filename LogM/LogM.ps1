# Powershell script pour trouver le fichier .log le plus récent et chercher une erreur définitive dans une liste

# Définissez le chemin du dossier
$folderPath = "C:\ProgramData\MICEN4\logs" # remplacez par votre chemin

# Obtenez le fichier .log le plus récent
$latestLogFile = Get-ChildItem -Path $folderPath -Filter *.log | Sort-Object LastAccessTime -Descending | Select-Object -First 1

# Imprimez le nom du fichier le plus récent
Write-Output "Fichier le plus récent: $($latestLogFile.FullName)"

# Utilisez Invoke-RestMethod pour obtenir le fichier JSON de la liste d'erreurs
$url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/LogM/erreur.json"
$errorList = Invoke-RestMethod -Uri $url

# Lisez le contenu du fichier log
$logContent = Get-Content $latestLogFile.FullName

# Créez une table de hachage pour enregistrer les erreurs rencontrées
$foundErrors = @{}

# Parcourez chaque erreur dans la liste d'erreurs
foreach ($error in $errorList) {
    # Vérifiez si le contenu du fichier log contient l'erreur et si l'erreur n'a pas déjà été trouvée
    if (($logContent -match $error.code) -and (!$foundErrors[$error.code])) {
        Write-Output "Erreur trouvée: $($error.code)"
        Write-Output "Description: $($error.description)"
        Write-Output "Solution: $($error.solution)"
        
        # Marquez l'erreur comme trouvée
        $foundErrors[$error.code] = $true
    }
}
