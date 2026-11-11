# SUZANE AI — première base Android

Créateur et fondateur : **MONSIEUR SACKO LHE DUC**.

## Contenu actuel
- Application Flutter Android avec interface sombre violette.
- Chat avec envoi vers un serveur distant.
- Sauvegarde locale de l'historique et restauration après fermeture/réouverture.
- Serveur Node.js séparé pour garder la clé IA hors de l'application.
- Workflow GitHub Actions pour générer un APK.

## Important
Cette version est une première base fonctionnelle, pas encore la plateforme complète promise.
La recherche Web, les citations vérifiables, la voix, la génération d'images, les pièces jointes,
les comptes utilisateurs, la synchronisation cloud, les rôles administrateur et la sécurité de production
doivent être développés avant une publication publique.

## Générer l'APK
Le workflow GitHub Actions génère les fichiers Android, analyse le code et compile l'APK.
Dans GitHub : Actions → Build SUZANE Android APK → Run workflow.

## Configurer le serveur IA
Dans `backend`, installer Node.js puis :
1. `npm install`
2. Copier `.env.example` vers `.env`
3. Renseigner une clé API valide dans `AI_API_KEY`
4. `npm start`

Déployer ensuite ce serveur sur un hébergeur HTTPS et compiler l'application avec :
`flutter build apk --release --dart-define=SUZANE_BACKEND_URL=https://VOTRE-SERVEUR`

Ne jamais publier le fichier `.env` ni placer la clé API dans l'application Android.

## Vérifications avant production
- Ajouter authentification et limites anti-abus côté serveur.
- Ajouter recherche Web réelle avec sources et dates.
- Ajouter politique de confidentialité et suppression/export des données.
- Tester restauration, mode hors ligne, réseau instable, rotation, mémoire faible et reprise après interruption.
- Configurer signature Android et sauvegarde sécurisée.
