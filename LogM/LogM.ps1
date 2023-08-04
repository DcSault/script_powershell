$indexUrl = "https://raw.githubusercontent.com/DcSault/script_powershell/main/index.ps1"

# Utiliser le répertoire temporaire du système
$tempDir = [System.IO.Path]::GetTempPath()
$indexOutput = Join-Path -Path $tempDir -ChildPath "index.ps1"

# Télécharger l'index
Invoke-WebRequest -Uri $indexUrl -OutFile $indexOutput

# Exécuter l'index et obtenir chaque URL
$scriptUrls = Invoke-Expression -Command $indexOutput

