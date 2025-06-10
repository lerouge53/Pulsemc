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
Write-Host "# Note du d�vellopeur, faite click droit pour coller"
$mcRoot = Read-Host "Entrez le chemin du dossier Minecraft (ex : C:\Users\<nom>\Appdata\Roaming\.minecraft)"
$modsFolder = Join-Path $mcRoot "mods"
# V�rifie si le chemin existe
if (-Not (Test-Path "$mcRoot")) {
    Write-Host "Le dossier sp�cifi� n'existe pas. Fermeture du script."
    Read-Host "Appuyez sur Entr�e pour fermer"
    exit
}

# === Dossier d'installation d�tect� ?
$installFlag = Join-Path $mcRoot "pulsemc.installed.flag"
$alreadyInstalled = Test-Path $installFlag

# === Choix utilisateur
if ($alreadyInstalled) {
    $mode = Read-Host "Modpack d�j� install�. Voulez-vous [M]ettre � jour ou [R]�installer ?"
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
        Write-Host "Dossier kubejs copi�."
    } else {
        Write-Host "Dossier kubejs introuvable."
    }

    # === Copie des fichiers config depuis patch ===
    $sourcePatchFolder = "patch"
    $destConfigFolder = Join-Path $mcRoot "config"
    if (-not (Test-Path $destConfigFolder)) {
        New-Item -Path $destConfigFolder -ItemType Directory | Out-Null
        Write-Host "Dossier 'config' cr��."
    }

    if (Test-Path $sourcePatchFolder) {
        Get-ChildItem -Path $sourcePatchFolder -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $destConfigFolder -Force
            Write-Host "Config copi�e : $($_.Name)"
        }
    } else {
        Write-Host "Le dossier 'patch/' est introuvable."
    }

    # === V�rifier/cr�er le dossier mods ===
    $modsFolder = Join-Path $mcRoot "mods"
    if (-not (Test-Path $modsFolder)) {
        New-Item -Path $modsFolder -ItemType Directory | Out-Null
        Write-Host "Dossier 'mods' cr��."
    }

    # === Copie des mods depuis mods-zip (anciennement mods.zip) ===
    $modsZipFolder = "mods-zip"
    if (Test-Path $modsZipFolder) {
        Write-Host "`nInstallation des mods depuis $modsZipFolder..."
        Get-ChildItem $modsZipFolder -Filter *.jar -File | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $modsFolder -Force
            Write-Host "Mod install� : $($_.Name)"
        }
    } else {
        Write-Host "Le dossier 'mods-zip/' est introuvable."
    }

    # === Marquer l'installation comme faite
    New-Item -Path $installFlag -ItemType File -Force | Out-Null
    Write-Host "`nInstallation termin�e.`n"
}

# === MISE � JOUR AVANC�E DES MODS (via actions_mods.json) ===
if ($mode -eq "M" -or $mode -eq "R") {
    if (Test-Path $jsonPath) {
        Write-Host "`nMise � jour des mods selon actions_mods.json..."

        $actions = Get-Content $jsonPath | ConvertFrom-Json

        # === Supprimer les anciens mods ===
        foreach ($mod in $actions.suppressions) {
            $modPath = Join-Path $modsFolder $mod
            if (Test-Path $modPath) {
                Remove-Item $modPath -Force
                Write-Host "Mod supprim� : $mod"
            } else {
                Write-Host "Mod introuvable (d�j� supprim� ?) : $mod"
            }
        }

        # === Ajouter les nouveaux mods ===
        foreach ($mod in $actions.ajouts) {
            $sourcePath = Join-Path $modsUpdatedFolder $mod
            $destPath = Join-Path $modsFolder $mod
            if (Test-Path $sourcePath) {
                Copy-Item -Path $sourcePath -Destination $destPath -Force
                Write-Host "Nouveau mod ajout� : $mod"
            } else {
                Write-Host "Mod � ajouter non trouv� : $mod"
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
                Write-Host "Mod mis � jour (ancien supprim�) : $ancien"
            }

            if (Test-Path $nouveauPath) {
                Copy-Item $nouveauPath -Destination $modsFolder -Force
                Write-Host "Mod mis � jour (nouveau copi�) : $nouveau"
            } else {
                Write-Host "Fichier pour mise � jour manquant : $nouveau"
            }
        }

    } else {
        Write-Host "`nFichier actions_mods.json introuvable. Mise � jour annul�e."
    }
}

Read-Host "`nAppuyez sur Entr�e pour fermer"
