# TODO

Points relevés lors de la relecture des `.md` (à traiter plus tard).

## Contenu à vérifier / réécrire

- [ ] **`_projects/auction-system-odoo-16.md`** — la section "Workflow Summary" est en **français** alors que le reste du document est en anglais (fichier `draft: true`). À traduire en anglais pour l'homogénéité.
- [ ] **`_notes/odoo-19-dockerfile.md`** — post copié d'odoo-17. Le raisonnement Python est probablement **faux** pour Odoo 19 : *"Python 3.12 was not supported when Odoo 19.0 was initially released"* — Python 3.12 (2023) précède Odoo 19 (2025). Vérifier la vraie version de Python d'Odoo 19 et ajuster (dates "released 2025 / support 2028" supposées). 
- [ ] **`_notes/updating-m1015-firmware-and-bios.md`** — heure du frontmatter corrigée de `47:40:00` à `17:40:00` (**supposé**, à confirmer).
- [ ] **`_notes/cocktails.md`** — "Sweet as the Punch" : ingrédient nommé "Fresh Tropical Juice" dans la liste mais "Granini juice" dans l'étape 1. À uniformiser.
- [ ] **`_notes/windows-create-iso-image.md`** — URL cassée `http://www.worg/2001/XMLSchema-instance` → `http://www.w3.org/...` (dans un bloc de code ; copie verbatim d'un tuto externe).
- [ ] **`_notes/odoo-wsl-setup-22-04.md`** — placeholder incohérent : `ubuntu-22-04-odoo-x` (lignes 100/104) vs `ubuntu-22-04-odoo-1x` (lignes 107/110/113/116).

## Homogénéité / structure

- [ ] **nginx** : l'ordre des sections diffère entre `nginx-server-block-odoo-11-15.md` (`### SSL Certificate` avant `### Custom Location`) et `nginx-server-block-odoo-16-17.md` (après). À aligner.
- [ ] **Frontmatter `title:` manquant** sur plusieurs fichiers (incohérent avec le reste) : `odoo-101.md`, `linux-user-and-group.md`, `odoo-auto-refresh-views.md`, `odoo-create-cron.md`, `odoo-date.md`, `odoo-reopen-wizard.md`, `odoo-report.md`, `odoo-versioning-custom-modules.md`, `odoo-readme-sample.md`, `windows-11-configuration.md`, `windows-create-iso-image.md`.

## Doublons / nommage

- [ ] **Doublons possibles** : `_notes/automated-cleanup-docker-images.md` et `_notes/automated-cleanup-unused-docker-images.md` couvrent quasi le même sujet (cron de nettoyage d'images Docker). Confirmer s'ils doivent rester séparés.
- [ ] **`_notes/build-push-docker-image-with-github-action.md`** — "action" au singulier alors que le produit est "GitHub **Actions**". Renommer en `...-with-github-actions.md` ?

## Non modifié (volontaire)

- `_notes/concurrency.md` — fautes présentes mais c'est une **citation verbatim** d'un post de forum (attribué, `draft: true`). Laissé tel quel.
