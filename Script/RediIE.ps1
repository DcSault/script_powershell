try {
    # D�finir le chemin du dossier d'installation de Microsoft Edge
    $edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application"
    Write-Host "Chemin d'Edge defini : $edgePath"

    # Obtenir tous les dossiers dans le dossier d'application de Edge
    $versionFolders = Get-ChildItem -Path $edgePath -Directory | Where-Object { $_.Name -ne 'SetupMetrics' }
    Write-Host "Dossiers de version obtenus : $($versionFolders.Name)"

    # Trier les dossiers par LastWriteTime en descendant et prendre le premier (le plus r�cent)
    $latestVersionFolder = $versionFolders | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    Write-Host "Dossier de la derniere version : $($latestVersionFolder.Name)"

    # V�rifier si le dossier BHO existe dans le dossier de la derni�re version
    $bhoPath = Join-Path -Path $latestVersionFolder.FullName -ChildPath "BHO"
    Write-Host "Chemin du dossier BHO : $bhoPath"


    if (Test-Path $bhoPath) {
        # Renommer le dossier
        Rename-Item -Path $bhoPath -NewName "BHO.bak" -ErrorAction Stop
        Write-Host "Le dossier a ete renomme avec succes."
    } else {
        Write-Host "Le dossier BHO n'existe pas."
    }
}
catch {
    Write-Host "Une erreur s'est produite :"
    Write-Host $_.Exception.Message
}

Write-Host "Appuyez sur une touche pour continuer ..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
