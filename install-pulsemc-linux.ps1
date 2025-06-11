# === Variables communes ===
$modsUpdatedFolder = "mods-mis-a-jour"
$jsonPath = "actions_mods.json"

# =============================
#  Installateur PulseMC
# =============================
Clear-Host
Write-Host "============================"
Write-Host "  Installateur PulseMC"
Write-Host "============================`n"

# === Chemin Minecraft ===
$mcRoot = Read-Host "Entrez le chemin du dossier Minecraft (ex : /home/<nom>/.minecraft)"
$modsFolder = Join-Path $mcRoot "mods"
# Vérifie si le chemin existe
if (-Not (Test-Path "$mcRoot")) {
    Write-Host "Le dossier spécifié n'existe pas. Fermeture du script."
    Read-Host "Appuyez sur Entrée pour fermer"
    exit
}

# === Dossier d'installation détecté ? ===
$installFlag = Join-Path $mcRoot "pulsemc.installed.flag"
$alreadyInstalled = Test-Path $installFlag

# === Choix utilisateur ===
if ($alreadyInstalled) {
    $mode = Read-Host "Modpack déjà installé. Voulez-vous [M]ettre à jour ou [R]éinstaller ?"
} else {
    $mode = "R"
}

$mode = $mode.ToUpper()

# === INSTALLATION COMPLETE ===
if ($mode -eq "R") {

    # === Copie kubejs ===
    $sourceKubeJS = "kubejs"
    $destKubeJS = Join-Path $mcRoot "kubejs"
    if (Test-Path $sourceKubeJS) {
        Copy-Item -Path $sourceKubeJS -Destination $destKubeJS -Recurse -Force
        Write-Host "Dossier kubejs copié."
    } else {
        Write-Host "Dossier kubejs introuvable."
    }

    # === Copie des fichiers config depuis patch ===
    $sourcePatchFolder = "patch"
    $destConfigFolder = Join-Path $mcRoot "config"
    if (-not (Test-Path $destConfigFolder)) {
        New-Item -Path $destConfigFolder -ItemType Directory | Out-Null
        Write-Host "Dossier 'config' créé."
    }

    if (Test-Path $sourcePatchFolder) {
        Get-ChildItem -Path $sourcePatchFolder -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $destConfigFolder -Force
            Write-Host "Config copiée : $($_.Name)"
        }
    } else {
        Write-Host "Le dossier 'patch/' est introuvable."
    }

    # === Vérifier/créer le dossier mods ===
    $modsFolder = Join-Path $mcRoot "mods"
    if (-not (Test-Path $modsFolder)) {
        New-Item -Path $modsFolder -ItemType Directory | Out-Null
        Write-Host "Dossier 'mods' créé."
    }

    # === Copie des mods depuis mods-zip ===
    $modsZipFolder = "mods-zip"
    if (Test-Path $modsZipFolder) {
        Write-Host "`nInstallation des mods depuis $modsZipFolder..."
        Get-ChildItem $modsZipFolder -Filter *.jar -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $modsFolder -Force
            Write-Host "Mod installé : $($_.Name)"
        }
    } else {
        Write-Host "Le dossier 'mods-zip/' est introuvable."
    }

    # === Marquer l'installation comme faite ===
    New-Item -Path $installFlag -ItemType File -Force | Out-Null
    Write-Host "`nInstallation terminée.`n"
}

# === MISE À JOUR AVANCÉE DES MODS (via actions_mods.json) ===
if ($mode -eq "M" -or $mode -eq "R") {
    if (Test-Path $jsonPath) {
        Write-Host "`nMise à jour des mods..."

        # === Mise à jour du dossier kubejs ===
        $sourceKubeJS = "kubejs"
        $destKubeJS = Join-Path $mcRoot "kubejs"
        if (Test-Path $destKubeJS) {
            Remove-Item -Path $destKubeJS -Recurse -Force
            Write-Host "Dossier kubejs existant supprimé."
        }
        if (Test-Path $sourceKubeJS) {
            Copy-Item -Path $sourceKubeJS -Destination $destKubeJS -Recurse -Force
            Write-Host "Nouveau dossier kubejs copié."
        } else {
            Write-Host "Dossier kubejs introuvable dans la source."
        }

        $actions = Get-Content $jsonPath | ConvertFrom-Json

        # === Supprimer les anciens mods ===
        foreach ($mod in $actions.suppressions) {
            $modPath = Join-Path $modsFolder $mod
            if (Test-Path $modPath) {
                Remove-Item $modPath -Force
                Write-Host "Mod supprimé : $mod"
            } else {
                Write-Host "Mod introuvable (déjà supprimé ?) : $mod"
            }
        }

        # === Ajouter les nouveaux mods ===
        foreach ($mod in $actions.ajouts) {
            $sourcePath = Join-Path $modsUpdatedFolder $mod
            $destPath = Join-Path $modsFolder $mod
            if (Test-Path $sourcePath) {
                Copy-Item -Path $sourcePath -Destination $destPath -Force
                Write-Host "Nouveau mod ajouté : $mod"
            } else {
                Write-Host "Mod à ajouter non trouvé : $mod"
            }
        }

        # === Gérer les mises à jour ===
        foreach ($majPair in $actions.maj) {
            $ancien = $majPair[0]
            $nouveau = $majPair[1]

            $ancienPath = Join-Path $modsFolder $ancien
            $nouveauPath = Join-Path $modsUpdatedFolder $nouveau

            if (Test-Path $ancienPath) {
                Remove-Item $ancienPath -Force
                Write-Host "Mod mis à jour (ancien supprimé) : $ancien"
            }

            if (Test-Path $nouveauPath) {
                Copy-Item $nouveauPath -Destination $modsFolder -Force
                Write-Host "Mod mis à jour (nouveau copié) : $nouveau"
            } else {
                Write-Host "Fichier pour mise à jour manquant : $nouveau"
            }
        }

    } else {
        Write-Host "`nFichier actions_mods.json introuvable. Mise à jour annulée."
    }
}

Write-Host "`nOpération terminée."
Read-Host "`nAppuyez sur Entrée pour fermer"
