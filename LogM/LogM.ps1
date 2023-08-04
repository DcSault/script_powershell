# URL du script
$scriptUrl = "https://raw.githubusercontent.com/DcSault/script_powershell/main/LogM/Script_LogM.ps1"

# Utiliser le répertoire temporaire du système
$tempDir = [System.IO.Path]::GetTempPath()
$scriptOutput = Join-Path -Path $tempDir -ChildPath "Script_LogM.ps1"

# Supprimer le script s'il existe déjà
if(Test-Path $scriptOutput){
    Remove-Item $scriptOutput -Force
}

# Télécharger le script
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptOutput

# Exécuter le script
Invoke-Expression -Command $scriptOutput
