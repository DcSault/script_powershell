# Initialiser le tableau de scripts
$scriptFolders = @()

# Définir les dossiers de scripts
$folder1 = @{
    Name = "Trousse_a_Outils";
    Scripts = @(
        @{
            Name = "IE_BHO";
            Url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/Script/desactiver_redirection_ie.ps1"
        },
        @{
            Name = "Exemple 3";
            Url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/script2.ps1"
        }
    )
}

$folder2 = @{
    Name = "Network_Tool";
    Scripts = @(
        @{
            Name = "Ping Tools";
            Url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/Script/Ping_V2.5%20-%20Beta%20-%20Json.ps1"
        },
        @{
            Name = "Exemple 2";
            Url = "https://raw.githubusercontent.com/DcSault/script_powershell/main/script4.ps1"
        }
    )
}

# Ajouter les dossiers de scripts à la liste
$scriptFolders += $folder1
$scriptFolders += $folder2

do {
    Write-Host "`n=== DOSSIERS DISPONIBLES ==="
    for ($i=0; $i -lt $scriptFolders.Count; $i++) {
        Write-Host "($($i+1)) $($scriptFolders[$i].Name)"
    }
    Write-Host "(Q) Quitter"

    $folderChoice = Read-Host "`nEntrez le numero du dossier a ouvrir ou 'Q' pour quitter"
    if ($folderChoice -eq 'Q') { exit }

    $chosenFolder = $scriptFolders[$folderChoice - 1]

    do {
        Write-Host "`n=== SCRIPTS DISPONIBLES DANS $($chosenFolder.Name) ==="
        for ($i=0; $i -lt $chosenFolder.Scripts.Count; $i++) {
            Write-Host "($($i+1)) $($chosenFolder.Scripts[$i].Name)"
        }
        Write-Host "(Q) Retour"

        $scriptChoice = Read-Host "`nEntrez le numero du script a executer ou 'Q' pour revenir"
        if ($scriptChoice -eq 'Q') { break }

        $chosenScript = $chosenFolder.Scripts[$scriptChoice - 1]

        # Télécharger et exécuter le script
        $output = "$env:TEMP\$($chosenScript.Name).ps1"
        Invoke-WebRequest -Uri $chosenScript.Url -OutFile $output
        & $output

    } until ($false)

} until ($false)
