# On demande à l'utilisateur d'entrer le chemin du dossier
$folderPath = Read-Host "Veuillez entrer le chemin complet du dossier où le fichier sera créé (par exemple, C:\chemin\vers\le\dossier)"

# On détermine le chemin complet du fichier en ajoutant un nom de fichier par défaut
$filePath = Join-Path -Path $folderPath -ChildPath "softwareList.html"

# On vérifie si le fichier existe
if (!(Test-Path -Path $filePath)) {
    # On crée le fichier si celui-ci n'existe pas
    New-Item -ItemType file -Path $filePath -Force
}

# On obtient la liste des logiciels installés à partir des clés de registre
$installedSoftware = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* 

# On crée une liste vide pour stocker nos objets de logiciels
$softwareList = @()

# On parcourt chaque élément du logiciel installé
foreach ($software in $installedSoftware) {
    # On vérifie si les champs "DisplayName" et "DisplayVersion" existent
    if ($software.PSObject.Properties.Name -match "DisplayName" -and $software.PSObject.Properties.Name -match "DisplayVersion") {
        # On crée un nouvel objet avec le nom et la version du logiciel
        $softwareObject = New-Object PSObject -Property @{
            "Nom du Logiciel" = $software.DisplayName
            "Version du Logiciel" = $software.DisplayVersion
        }
        # On ajoute l'objet à notre liste de logiciels
        $softwareList += $softwareObject
    }
}

# On trie la liste par nom de logiciel
$sortedList = $softwareList | Sort-Object 'Nom du Logiciel'

# On défini le style CSS pour centrer le texte
$css = @"
<style>
body { font-family: Arial, sans-serif; padding: 20px; }
h2 { color: #3a87ad; }
table { width: 100%; border-collapse: collapse; margin-top: 20px; }
th, td { text-align: center; border: 1px solid #ddd; padding: 8px; }
th { background-color: #3a87ad; color: white; }
tr:nth-child(even) { background-color: #f2f2f2; }
</style>
"@

# On exporte la liste de logiciels triée vers un fichier HTML
$sortedList | ConvertTo-Html -Title "Liste des Logiciels" -Body "<H2>Liste des logiciels installés</H2>" -Head $css | Out-File $filePath
