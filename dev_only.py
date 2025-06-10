import json

def nettoyer_ligne(ligne):
    return ligne.split('#')[0].strip()

def lire_modlist(fichier):
    with open(fichier, 'r', encoding='utf-8') as f:
        lignes = [
            nettoyer_ligne(ligne)
            for ligne in f
            if ligne.strip() and not ligne.strip().startswith('#') and not ligne.startswith('---')
        ]

    ajouts = []
    suppression = []
    mises_a_jour = []

    for i in range(0, len(lignes), 2):
        ancien = lignes[i]
        nouveau = lignes[i + 1]

        if ancien == "NoMod":
            ajouts.append(nouveau)
        elif nouveau == "NoMod":
            suppression.append(ancien)
        else:
            mises_a_jour.append((ancien, nouveau))

    return ajouts, suppression, mises_a_jour

# === Execution ===
ajouts, suppressions, maj = lire_modlist("modlist.txt")

with open("actions_mods.json", "w", encoding="utf-8") as f:
    json.dump({
        "ajouts": ajouts,
        "suppressions": suppressions,
        "maj": maj
    }, f, indent=4, ensure_ascii=False)
