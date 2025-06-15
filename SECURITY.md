# 🔐 Sécurité de la clé API - Guide d'utilisation

## 📋 Options de sécurité disponibles

### 1. **Niveau de base** (actuel)
- Clé API stockée en clair dans `.env`
- Protégée côté serveur uniquement
- ✅ Acceptable pour le développement

### 2. **Niveau avancé** (recommandé)
- Clé API chiffrée avec AES-256-GCM
- Clé de chiffrement séparée
- 🔒 Sécurité renforcée

## 🚀 Comment activer le chiffrement

### Étape 1: Générer la clé chiffrée
```bash
npm run encrypt-key
```

### Étape 2: Mettre à jour le .env
Copiez les valeurs générées dans votre `.env`:
```
ENCRYPTED_API_KEY=valeur_generee
API_IV=valeur_generee  
API_AUTH_TAG=valeur_generee
```

### Étape 3: Supprimer l'ancienne clé
Commentez ou supprimez:
```
# GEMINI_API_KEY=AIzaSy...
```

### Étape 4: Changer la clé de chiffrement
Modifiez `ENCRYPTION_KEY` dans `.env` avec une valeur unique.

## 🛡️ Bonnes pratiques

1. **Différentes clés par environnement**
   - Dev: `ENCRYPTION_KEY=dev-key-32-chars`
   - Prod: `ENCRYPTION_KEY=prod-key-32-chars`

2. **Rotation régulière**
   - Changez les clés tous les 3-6 mois
   - Utilisez un gestionnaire de secrets en production

3. **Sauvegarde sécurisée**
   - Stockez les clés dans un coffre-fort numérique
   - Ne les commitez jamais dans Git

## ⚡ État actuel
- ✅ Protection côté serveur
- ⏳ Chiffrement disponible (optionnel)
- 🔄 Transition transparente
