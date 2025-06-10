# === Variables communes ===
$modsUpdatedFolder = "mods-mis-a-jour"
$jsonPath = "actions_mods.json"

# === Chargement des assemblies pour Windows Forms ===
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === Cr�ation de la fen�tre principale ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Installateur PulseMC"
$form.Size = New-Object System.Drawing.Size(700, 450)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 45)

# === Panneau gauche pour les boutons d'action ===
$panelActions = New-Object System.Windows.Forms.Panel
$panelActions.Location = New-Object System.Drawing.Point(10, 10)
$panelActions.Size = New-Object System.Drawing.Size(150, 400)
$panelActions.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$form.Controls.Add($panelActions)

# === Bouton Installer ===
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Text = "Installer"
$buttonInstall.Location = New-Object System.Drawing.Point(10, 20)
$buttonInstall.Size = New-Object System.Drawing.Size(130, 40)
$buttonInstall.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$buttonInstall.ForeColor = [System.Drawing.Color]::White
$buttonInstall.FlatStyle = "Flat"
$buttonInstall.FlatAppearance.BorderSize = 0
$panelActions.Controls.Add($buttonInstall)

# === Bouton Mettre � jour ===
$buttonUpdate = New-Object System.Windows.Forms.Button
$buttonUpdate.Text = "Mettre � jour"
$buttonUpdate.Location = New-Object System.Drawing.Point(10, 70)
$buttonUpdate.Size = New-Object System.Drawing.Size(130, 40)
$buttonUpdate.BackColor = [System.Drawing.Color]::FromArgb(0, 204, 106)
$buttonUpdate.ForeColor = [System.Drawing.Color]::White
$buttonUpdate.FlatStyle = "Flat"
$buttonUpdate.FlatAppearance.BorderSize = 0
$buttonUpdate.Enabled = $false
$panelActions.Controls.Add($buttonUpdate)

# === Bouton Discord ===
$buttonDiscord = New-Object System.Windows.Forms.Button
$buttonDiscord.Text = "Rejoindre Discord"
$buttonDiscord.Location = New-Object System.Drawing.Point(10, 120)
$buttonDiscord.Size = New-Object System.Drawing.Size(130, 40)
$buttonDiscord.BackColor = [System.Drawing.Color]::FromArgb(88, 101, 242)
$buttonDiscord.ForeColor = [System.Drawing.Color]::White
$buttonDiscord.FlatStyle = "Flat"
$buttonDiscord.FlatAppearance.BorderSize = 0
$buttonDiscord.Add_Click({
    Start-Process "https://discord.gg/YrhaycfbWG"
})
$panelActions.Controls.Add($buttonDiscord)

# === Label pour le chemin Minecraft ===
$labelPath = New-Object System.Windows.Forms.Label
$labelPath.Text = "Chemin du dossier Minecraft (ex : C:\Users\<nom>\AppData\Roaming\.minecraft) :"
$labelPath.Location = New-Object System.Drawing.Point(170, 20)
$labelPath.Size = New-Object System.Drawing.Size(510, 20)
$labelPath.ForeColor = [System.Drawing.Color]::White
$form.Controls.Add($labelPath)

# === Zone de texte pour le chemin Minecraft ===
$textBoxPath = New-Object System.Windows.Forms.TextBox
$textBoxPath.Location = New-Object System.Drawing.Point(170, 40)
$textBoxPath.Size = New-Object System.Drawing.Size(410, 20)
$textBoxPath.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$textBoxPath.Add_TextChanged({
    Update-ButtonState
})
$form.Controls.Add($textBoxPath)

# === Bouton pour parcourir les dossiers ===
$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Text = "Parcourir..."
$buttonBrowse.Location = New-Object System.Drawing.Point(590, 38)
$buttonBrowse.Size = New-Object System.Drawing.Size(90, 24)
$buttonBrowse.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$buttonBrowse.ForeColor = [System.Drawing.Color]::White
$buttonBrowse.FlatStyle = "Flat"
$buttonBrowse.FlatAppearance.BorderSize = 0
$buttonBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "S�lectionnez le dossier Minecraft"
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $textBoxPath.Text = $folderBrowser.SelectedPath
        Update-ButtonState
    }
})
$form.Controls.Add($buttonBrowse)

# === Zone de texte pour les messages de statut ===
$statusBox = New-Object System.Windows.Forms.TextBox
$statusBox.Multiline = $true
$statusBox.ScrollBars = "Vertical"
$statusBox.Location = New-Object System.Drawing.Point(170, 70)
$statusBox.Size = New-Object System.Drawing.Size(510, 270)
$statusBox.ReadOnly = $true
$statusBox.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$form.Controls.Add($statusBox)

# === Fonction pour mettre � jour l'�tat des boutons ===
function Update-ButtonState {
    $mcRoot = $textBoxPath.Text
    if (-not $mcRoot) {
        $buttonUpdate.Enabled = $false
        $statusBox.AppendText("Veuillez entrer un chemin pour le dossier Minecraft.`r`n")
        return
    }
    if (-not (Test-Path $mcRoot)) {
        $buttonUpdate.Enabled = $false
        $statusBox.AppendText("Le dossier sp�cifi� n'existe pas.`r`n")
        return
    }
    $installFlag = Join-Path $mcRoot "pulsemc.installed.flag"
    $buttonUpdate.Enabled = Test-Path $installFlag
    if ($buttonUpdate.Enabled) {
        $statusBox.AppendText("Installation existante d�tect�e. Mode Mise � jour disponible.`r`n")
    } else {
        $statusBox.AppendText("Aucune installation existante d�tect�e. Mode Installation par d�faut.`r`n")
    }
}

# === Bouton pour ex�cuter l'action ===
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Text = "Ex�cuter"
$buttonExecute.Location = New-Object System.Drawing.Point(170, 350)
$buttonExecute.Size = New-Object System.Drawing.Size(100, 30)
$buttonExecute.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 212)
$buttonExecute.ForeColor = [System.Drawing.Color]::White
$buttonExecute.FlatStyle = "Flat"
$buttonExecute.FlatAppearance.BorderSize = 0
$buttonExecute.Add_Click({
    $statusBox.Clear()
    $mcRoot = $textBoxPath.Text
    $modsFolder = Join-Path $mcRoot "mods"
    
    # === V�rification du chemin ===
    if (-not $mcRoot) {
        $statusBox.AppendText("Veuillez entrer un chemin pour le dossier Minecraft.`r`n")
        return
    }
    if (-Not (Test-Path "$mcRoot")) {
        $statusBox.AppendText("Le dossier sp�cifi� n'existe pas.`r`n")
        return
    }

    # === D�terminer le mode ===
    $mode = if ($buttonInstall.Focused) { "R" } elseif ($buttonUpdate.Focused) { "M" } else { "R" }

    # === INSTALLATION COMPLETE ===
    if ($mode -eq "R") {
        # === Copie kubejs ===
        $sourceKubeJS = "kubejs"
        $destKubeJS = Join-Path $textBoxPath.Text "kubejs"
        if (Test-Path $sourceKubeJS) {
            Copy-Item -Path $sourceKubeJS -Destination $destKubeJS -Recurse -Force
            $statusBox.AppendText("Dossier kubejs copi�.`r`n")
        } else {
            $statusBox.AppendText("Dossier kubejs introuvable.`r`n")
        }

        # === Copie des fichiers config depuis patch ===
        $sourcePatchFolder = "patch"
        $destConfigFolder = Join-Path $textBoxPath.Text "config"
        if (-not (Test-Path $destConfigFolder)) {
            New-Item -Path $destConfigFolder -ItemType Directory | Out-Null
            $statusBox.AppendText("Dossier 'config' cr��.`r`n")
        }

        if (Test-Path $sourcePatchFolder) {
            Get-ChildItem -Path $sourcePatchFolder -File | ForEach-Object {
                Copy-Item -Path $_.FullName -Destination $destConfigFolder -Force
                $statusBox.AppendText("Config copi�e : $($_.Name)`r`n")
            }
        } else {
            $statusBox.AppendText("Le dossier 'patch/' est introuvable.`r`n")
        }

        # === V�rifier/cr�er le dossier mods ===
        $modsFolder = Join-Path $textBoxPath.Text "mods"
        if (-not (Test-Path $modsFolder)) {
            New-Item -Path $modsFolder -ItemType Directory | Out-Null
            $statusBox.AppendText("Dossier 'mods' cr��.`r`n")
        }

        # === Copie des mods depuis mods-zip ===
        $modsZipFolder = "mods-zip"
        if (Test-Path $modsZipFolder) {
            $statusBox.AppendText("Installation des mods depuis $modsZipFolder...`r`n")
            Get-ChildItem $modsZipFolder -Filter *.jar -File | ForEach-Object {
                Copy-Item -Path $_.FullName -Destination $modsFolder -Force
                $statusBox.AppendText("Mod install� : $($_.Name)`r`n")
            }
        } else {
            $statusBox.AppendText("Le dossier 'mods-zip/' est introuvable.`r`n")
        }

        # === Marquer l'installation comme faite ===
        $installFlag = Join-Path $mcRoot "pulsemc.installed.flag"
        New-Item -Path $installFlag -ItemType File -Force | Out-Null
        $statusBox.AppendText("Installation termin�e.`r`n")
        Update-ButtonState # Mettre � jour l'�tat apr�s l'installation
    }

    # === MISE � JOUR AVANC�E DES MODS ===
    if ($mode -eq "M" -or $mode -eq "R") {
        if (Test-Path $jsonPath) {
            $statusBox.AppendText("Mise � jour des mods selon actions_mods.json...`r`n")
            $actions = Get-Content $jsonPath | ConvertFrom-Json

            # === Supprimer les anciens mods ===
            foreach ($mod in $actions.suppressions) {
                $modPath = Join-Path $modsFolder $mod
                if (Test-Path $modPath) {
                    Remove-Item $modPath -Force
                    $statusBox.AppendText("Mod supprim� : $mod`r`n")
                } else {
                    $statusBox.AppendText("Mod introuvable (d�j� supprim� ?) : $mod`r`n")
                }
            }

            # === Ajouter les nouveaux mods ===
            foreach ($mod in $actions.ajouts) {
                $sourcePath = Join-Path $modsUpdatedFolder $mod
                $destPath = Join-Path $modsFolder $mod
                if (Test-Path $sourcePath) {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                    $statusBox.AppendText("Nouveau mod ajout� : $mod`r`n")
                } else {
                    $statusBox.AppendText("Mod � ajouter non trouv� : $mod`r`n")
                }
            }

            # === G�rer les mises � jour ===
            foreach ($majPair in $actions.maj) {
                $ancien = $majPair[0]
                $nouveau = $majPair[1]
                $ancienPath = Join-Path $modsFolder $ancien
                $nouveauPath = Join-Path $modsUpdatedFolder $nouveau

                if (Test-Path $ancienPath) {
                    Remove-Item $ancienPath -Force
                    $statusBox.AppendText("Mod mis � jour (ancien supprim�) : $ancien`r`n")
                }

                if (Test-Path $nouveauPath) {
                    Copy-Item -Path $nouveauPath -Destination $modsFolder -Force
                    $statusBox.AppendText("Mod mis � jour (nouveau copi�) : $nouveau`r`n")
                } else {
                    $statusBox.AppendText("Fichier pour mise � jour manquant : $nouveau`r`n")
                }
            }
        } else {
            $statusBox.AppendText("Fichier actions_mods.json introuvable. Mise � jour annul�e.`r`n")
        }
    }

    $statusBox.AppendText("Op�ration termin�e.`r`n")
})
$form.Controls.Add($buttonExecute)

# === Bouton pour quitter ===
$buttonQuit = New-Object System.Windows.Forms.Button
$buttonQuit.Text = "Quitter"
$buttonQuit.Location = New-Object System.Drawing.Point(280, 350)
$buttonQuit.Size = New-Object System.Drawing.Size(100, 30)
$buttonQuit.BackColor = [System.Drawing.Color]::FromArgb(200, 50, 50)
$buttonQuit.ForeColor = [System.Drawing.Color]::White
$buttonQuit.FlatStyle = "Flat"
$buttonQuit.FlatAppearance.BorderSize = 0
$buttonQuit.Add_Click({ $form.Close() })
$form.Controls.Add($buttonQuit)

# === Logique pour les boutons Installer et Mettre � jour ===
$buttonInstall.Add_Click({
    $buttonInstall.Focus()
    $statusBox.AppendText("Mode Installation s�lectionn�.`r`n")
})
$buttonUpdate.Add_Click({
    $buttonUpdate.Focus()
    $statusBox.AppendText("Mode Mise � jour s�lectionn�.`r`n")
})

# === Afficher la fen�tre ===
[void]$form.ShowDialog()