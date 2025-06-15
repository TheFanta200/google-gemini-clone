# 🚀 NOVALYS - Google Gemini Clone

Une application de chat AI sécurisée basée sur l'API Google Gemini 2.0-flash avec interface moderne et thème bleu/blanc.

## ✨ **Fonctionnalités**

- 🎨 **Interface moderne** avec thème bleu clair et blanc
- 🔒 **Sécurité avancée** avec chiffrement de clé API
- ⚡ **API Gemini 2.0-flash** dernière génération
- 🌓 **Mode sombre/clair** intégré
- 💾 **Sauvegarde locale** des conversations
- 📱 **Responsive design** mobile et desktop
- 🔧 **Installation automatisée** pour Rocky Linux 9

## 🏗️ **Architecture**

```
Frontend (Vanilla JS) ←→ Backend (Express.js) ←→ Google Gemini API
         ↓                        ↓                      ↓
    Interface Web          Serveur sécurisé        API IA
    Thème NOVALYS         Clé API cachée          Réponses AI
```

## 📦 **Installation automatique Rocky Linux 9**

### Installation complète en une commande :
```bash
curl -sSL https://raw.githubusercontent.com/TheFanta200/google-gemini-clone/main/install-novalys.sh | sudo bash
```

### Ou téléchargement et exécution :
```bash
wget https://raw.githubusercontent.com/TheFanta200/google-gemini-clone/main/install-novalys.sh
chmod +x install-novalys.sh
sudo ./install-novalys.sh
```

**Le script installe automatiquement :**
- ✅ Node.js 20 LTS + npm + PM2
- ✅ Nginx avec HTTPS
- ✅ Firewall configuré
- ✅ Service systemd
- ✅ Monitoring intégré

## ⚙️ **Configuration manuelle (développement)**

### 1. Cloner le projet
```bash
git clone https://github.com/TheFanta200/google-gemini-clone.git
cd google-gemini-clone
```

### 2. Installer les dépendances
```bash
npm install
```

### 3. Configuration
```bash
cp .env.example .env
nano .env
```

Modifier avec votre clé API :
```env
GEMINI_API_KEY=votre-cle-api-gemini
ENCRYPTION_KEY=votre-cle-de-chiffrement-32-caracteres
PORT=3000
```

### 4. Démarrer l'application
```bash
# Mode développement
npm start

# Mode production
npm run start:prod
```

## 🔐 **Sécurité**

### Chiffrement de la clé API (optionnel)
```bash
# Générer une clé chiffrée
npm run encrypt-key

# Copier les valeurs dans .env
ENCRYPTED_API_KEY=valeur_generee
API_IV=valeur_generee
API_AUTH_TAG=valeur_generee
```

### Variables d'environnement sécurisées
- ✅ Clé API cachée côté serveur
- ✅ Chiffrement AES-256-GCM disponible
- ✅ Variables séparées par environnement
- ✅ Fichier .env protégé par .gitignore

## 🛠️ **Gestion (Rocky Linux)**

### Commandes de service
```bash
# État du système
novalys-status

# Gestion du service
systemctl {start|stop|restart|status} novalys

# Logs en temps réel
journalctl -u novalys -f

# Mise à jour automatique
novalys-update
```

### Accès à l'application
- **HTTP :** `http://votre-ip-serveur`
- **HTTPS :** `https://votre-ip-serveur`
- **Local :** `http://localhost:3000`

## 📁 **Structure du projet**

```
google-gemini-clone/
├── 📄 index.html              # Interface utilisateur
├── 📄 script.js               # Code client JavaScript  
├── 📄 style.css               # Styles CSS avec thème NOVALYS
├── 📄 server.js               # Serveur Express.js sécurisé
├── 📄 package.json            # Configuration Node.js
├── 🔧 install-novalys.sh      # Script d'installation ALL-IN-ONE
├── 🔐 crypto-utils.js         # Utilitaires de chiffrement
├── 🔐 generate-encrypted-key.js # Générateur de clés chiffrées
├── 🖼️ gemini.png             # Avatar Gemini
├── 🖼️ user.png               # Avatar utilisateur
├── ⚙️ .env                    # Variables d'environnement
├── 📋 .gitignore              # Fichiers ignorés par Git
└── 📖 FILE-ORGANIZATION.md    # Documentation de l'organisation
```

## 🎨 **Thème NOVALYS**

- **Couleurs principales :** Bleu clair (#4299e1) et blanc (#ffffff)
- **Logo :** NOVALYS en position fixe
- **Design :** Moderne avec animations fluides
- **Responsive :** Compatible mobile et desktop
- **Mode sombre :** Disponible avec tons bleus profonds

## 🔧 **API et endpoints**

### Backend (Express.js)
- `POST /api/chat` - Envoi de messages à l'API Gemini
- `GET /` - Interface web principale

### Frontend (Vanilla JS)
- Gestion des conversations
- Sauvegarde locale
- Animations de frappe
- Copie de messages

## 📊 **Monitoring et logs**

### Fichiers de logs
- **Application :** `journalctl -u novalys`
- **Nginx :** `/var/log/nginx/novalys_*.log`
- **Système :** `/var/log/messages`

### Métriques surveillées
- ✅ État des services (NOVALYS, Nginx)
- ✅ Utilisation mémoire et CPU
- ✅ Connectivité réseau
- ✅ Temps de réponse API

## 🆘 **Dépannage**

### Problèmes courants
```bash
# Service ne démarre pas
journalctl -u novalys --no-pager -l

# Problème de clé API
nano /opt/novalys/.env

# Test de connectivité
curl -k https://localhost

# Redémarrage complet
systemctl restart novalys nginx
```

### Support
- 📧 Logs : `journalctl -u novalys -f`
- 🔍 Diagnostic : `novalys-status`
- 🔧 Configuration : `/opt/novalys/.env`

## 📝 **Licence**

MIT License - Libre d'utilisation et modification

## 🤝 **Contribution**

1. Fork du projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commit (`git commit -am 'Ajout d'une fonctionnalité'`)
4. Push (`git push origin feature/amelioration`)
5. Pull Request

---

**NOVALYS** - Installation automatisée et sécurisée pour Rocky Linux 9 🚀
