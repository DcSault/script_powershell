# Charger l'assembly pour les boîtes de dialogue
Add-Type -AssemblyName System.Windows.Forms

# Vérifier si le script est exécuté en tant qu'administrateur
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-Not $IsAdmin) {
    [System.Windows.Forms.MessageBox]::Show("Ce script nécessite des droits d'administrateur.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    Exit
}

# Vérifier si la mise à jour KB5029253 est installée
$Update = Get-HotFix | Where-Object {$_.HotFixID -eq 'KB5029253'}

if ($Update) {
    $UserChoice = [System.Windows.Forms.MessageBox]::Show("La mise à jour KB5029253 est installée. Voulez-vous la supprimer ?", "Confirmation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)

    if ($UserChoice -eq "Yes") {
        # Supprimer la mise à jour
        wusa /uninstall /kb:5029253 /quiet /norestart

        # Afficher un message de redémarrage
        [System.Windows.Forms.MessageBox]::Show("L'ordinateur va redémarrer...", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

        # Redémarrer l'ordinateur
        Restart-Computer
    } else {
        [System.Windows.Forms.MessageBox]::Show("La mise à jour ne sera pas supprimée.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
} else {
    [System.Windows.Forms.MessageBox]::Show("La mise à jour KB5029253 n'est pas installée.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
