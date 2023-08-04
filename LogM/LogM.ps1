# Powershell script pour trouver le fichier .log le plus récent et chercher une erreur définitive dans une liste

# Définissez le chemin du dossier
$folderPath = "C:\ProgramData\MICEN4\logs" # remplacez par votre chemin

# Obtenez le fichier .log le plus récent
$latestLogFile = Get-ChildItem -Path $folderPath -Filter *.log | Sort-Object LastAccessTime -Descending | Select-Object -First 1

# Imprimez le nom du fichier le plus récent avec une ligne de séparation
Write-Host "`n==================================================`n"
Write-Host "Fichier le plus récent: $($latestLogFile.FullName)" -ForegroundColor Cyan
Write-Host "`n==================================================`n"

# Utilisez Invoke-RestMethod pour obtenir le fichier JSON de la liste d'erreurs
$url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/LogM/erreur.json?$(Get-Date -Format o)"
$errorList = Invoke-RestMethod -Uri $url

# Lisez le contenu du fichier log
$logContent = Get-Content $latestLogFile.FullName

# Créez une table de hachage pour enregistrer les erreurs rencontrées
$foundErrors = @{}

# Parcourez chaque erreur dans la liste d'erreurs
foreach ($err in $errorList) {
    # Vérifiez si le contenu du fichier log contient l'erreur et si l'erreur n'a pas déjà été trouvée
    if (($logContent -match $err.code) -and (!$foundErrors[$err.code])) {
        # Obtenez l'heure de l'erreur
        $errorLine = $logContent | Where-Object { $_ -match $err.code } | Select-Object -Last 1
        $errorTime = $errorLine.Substring(0, 19) # Adaptez cela en fonction du format d'horodatage de votre fichier log
        
        # Imprimez les détails de l'erreur avec des couleurs et des lignes de séparation
        Write-Host "Erreur trouvée: $($err.code)" -ForegroundColor Red
        Write-Host "TDA: $($err.tda)" -ForegroundColor Magenta
        Write-Host "Heure: $errorTime" -ForegroundColor Yellow
        Write-Host "Description: $($err.description)" -ForegroundColor Green
        Write-Host "Solution: $($err.solution)" -ForegroundColor White
        Write-Host "`n==================================================`n"
        
        # Marquez l'erreur comme trouvée
        $foundErrors[$err.code] = $true
    }
}

# Mettez le script en pause à la fin
pause
