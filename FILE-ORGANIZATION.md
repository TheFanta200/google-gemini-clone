# 📁 Organisation des fichiers NOVALYS

## ✅ **Fichiers ESSENTIELS (à conserver)**

### Application principale
- `index.html` - Interface utilisateur
- `script.js` - Code client JavaScript
- `style.css` - Styles CSS
- `server.js` - Serveur backend Node.js
- `package.json` - Configuration Node.js et dépendances

### Assets
- `gemini.png` - Avatar Gemini
- `user.png` - Avatar utilisateur

### Configuration et sécurité
- `.env` - Variables d'environnement (local)
- `.gitignore` - Fichiers à ignorer par Git
- `crypto-utils.js` - Utilitaires de chiffrement
- `generate-encrypted-key.js` - Générateur de clés chiffrées

### Installation
- `install-novalys.sh` - **Script d'installation ALL-IN-ONE** ⭐

## ❌ **Fichiers OBSOLÈTES (peuvent être supprimés)**

### Scripts d'installation anciens
- `install-rocky-linux.sh` - Remplacé par `install-novalys.sh`
- `fix-installation.sh` - Fonctionnalité intégrée dans `install-novalys.sh`
- `update-novalys.sh` - Fonctionnalité intégrée dans `install-novalys.sh`

### Documentation redondante
- `INSTALL-ROCKY-LINUX.md` - Remplacé par documentation dans `install-novalys.sh`
- `SECURITY.md` - Informations intégrées dans le script principal

## 🎯 **Résumé**
- **Fichiers à garder :** 9 fichiers essentiels
- **Fichiers à supprimer :** 5 fichiers obsolètes
- **Gain d'espace :** ~50% de fichiers en moins
- **Simplification :** Un seul script d'installation au lieu de 4
