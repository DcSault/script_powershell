# Chemin du registre pour trouver les installations d'Office
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$officeInstallations = Get-ChildItem $regPath -Recurse | Get-ItemProperty | Where-Object { $_.DisplayName -like "*Microsoft Office 365*" -or $_.DisplayName -like "*Microsoft Office*" }

if ($officeInstallations -ne $null) {
    foreach ($officeRegKey in $officeInstallations) {
        $uninstallString = $officeRegKey.UninstallString

        if ($uninstallString -and $uninstallString.Contains('OfficeClickToRun.exe')) {
            try {
                # Construction et exécution de la commande de désinstallation silencieuse pour Office 365
                $uninstallCommand = "`"$uninstallString`" scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365BusinessRetail.16_fr-fr_x-none culture=fr-fr version.16=16.0"
                Write-Host "Exécution de la commande de désinstallation silencieuse : $uninstallCommand"
                Start-Process "cmd.exe" "/c $uninstallCommand" -Wait -NoNewWindow
                Write-Host "Microsoft Office 365 désinstallé."
            } catch {
                Write-Host "Erreur lors de la désinstallation : $_"
            }
        } else {
            Write-Host "Impossible de trouver la chaîne de désinstallation pour : $officeRegKey.DisplayName"
        }
    }
} else {
    Write-Host "Microsoft Office 365 n'est pas installé sur cet ordinateur."
}
