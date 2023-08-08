# URL du script
$scriptUrl = "https://raw.githubusercontent.com/DcSault/script_powershell/main/LogM/Script_LogM.ps1"

# Utiliser le repertoire temporaire du systeme
$tempDir = [System.IO.Path]::GetTempPath()
$scriptOutput = Join-Path -Path $tempDir -ChildPath "Script_LogM.ps1"

# Supprimer le script s'il existe deja
if(Test-Path $scriptOutput){
    Remove-Item $scriptOutput -Force
}

# Telecharge le script
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptOutput

# Execute le script
Invoke-Expression -Command $scriptOutput
