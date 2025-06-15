# 🐧 Installation NOVALYS sur Rocky Linux 9

## 🚀 Installation automatique

### Téléchargement et exécution
```bash
# Télécharger le script
curl -O https://raw.githubusercontent.com/TheFanta200/google-gemini-clone/main/install-rocky-linux.sh

# Rendre exécutable
chmod +x install-rocky-linux.sh

# Exécuter en tant que root
sudo ./install-rocky-linux.sh
```

### Ou en une seule commande
```bash
curl -sSL https://raw.githubusercontent.com/TheFanta200/google-gemini-clone/main/install-rocky-linux.sh | sudo bash
```

## 📦 Ce qui sera installé

### Composants système
- ✅ Node.js 20 LTS + npm
- ✅ PM2 (gestionnaire de processus)
- ✅ Nginx (proxy inverse + HTTPS)
- ✅ Firewall configuré
- ✅ Service systemd
- ✅ Monitoring et logs

### Sécurité
- 🔒 Utilisateur dédié `novalys`
- 🔒 Permissions restrictives
- 🔒 Firewall configuré
- 🔒 HTTPS avec certificat auto-signé
- 🔒 Variables d'environnement sécurisées

## 🎯 Après l'installation

### 1. Configuration de la clé API
```bash
# Éditer le fichier de configuration
sudo nano /opt/novalys/.env

# Remplacer YOUR_GEMINI_API_KEY_HERE par votre vraie clé
GEMINI_API_KEY=AIzaSyDTCjL-Waay8t2GiksFZAOfaw4DeJDARtE
```

### 2. Redémarrer le service
```bash
sudo systemctl restart novalys
```

### 3. Vérifier le statut
```bash
# Commande de monitoring intégrée
novalys-status

# Ou commandes systemd classiques
sudo systemctl status novalys
sudo journalctl -u novalys -f
```

## 🌐 Accès à l'application

- **HTTP**: `http://votre-ip-serveur`
- **HTTPS**: `https://votre-ip-serveur`
- **Local**: `http://localhost` (sur le serveur)

## 🔧 Commandes de gestion

### Gestion du service
```bash
# Démarrer
sudo systemctl start novalys

# Arrêter
sudo systemctl stop novalys

# Redémarrer
sudo systemctl restart novalys

# Statut
sudo systemctl status novalys

# Logs en temps réel
sudo journalctl -u novalys -f
```

### Mise à jour de l'application
```bash
cd /opt/novalys
sudo -u novalys git pull
sudo -u novalys npm install
sudo systemctl restart novalys
```

### Chiffrement de la clé API (optionnel)
```bash
cd /opt/novalys
sudo -u novalys npm run encrypt-key
# Suivre les instructions affichées
```

## 🔍 Monitoring

### Statut global
```bash
novalys-status
```

### Logs détaillés
```bash
# Logs de l'application
sudo journalctl -u novalys --no-pager -l

# Logs Nginx
sudo tail -f /var/log/nginx/novalys_access.log
sudo tail -f /var/log/nginx/novalys_error.log
```

### Ressources système
```bash
# CPU et mémoire de l'application
ps aux | grep node

# Ports ouverts
ss -tlnp | grep :3000
netstat -tlnp | grep nginx
```

## 🛠️ Dépannage

### Service ne démarre pas
```bash
# Vérifier les logs
sudo journalctl -u novalys --no-pager -l

# Vérifier la configuration
cd /opt/novalys
sudo -u novalys node -c "console.log('Test OK')"
```

### Problème de clé API
```bash
# Vérifier le fichier .env
sudo cat /opt/novalys/.env

# Tester manuellement
cd /opt/novalys
sudo -u novalys node -e "require('dotenv').config(); console.log(process.env.GEMINI_API_KEY)"
```

### Nginx ne fonctionne pas
```bash
# Tester la configuration
sudo nginx -t

# Redémarrer nginx
sudo systemctl restart nginx

# Vérifier les logs
sudo tail -f /var/log/nginx/error.log
```

## 📁 Structure des fichiers

```
/opt/novalys/                 # Répertoire principal
├── server.js                 # Serveur Express
├── script.js                 # Code client
├── style.css                 # Styles CSS
├── index.html                # Interface web
├── .env                      # Variables d'environnement
└── package.json              # Dépendances Node.js

/etc/systemd/system/
└── novalys.service           # Service systemd

/etc/nginx/conf.d/
└── novalys.conf              # Configuration Nginx

/usr/local/bin/
└── novalys-status            # Script de monitoring
```

## 🔐 Sécurité avancée

### Changement de l'utilisateur par défaut
```bash
# Créer un nouvel utilisateur admin
sudo useradd -m -s /bin/bash admin-novalys
sudo usermod -aG wheel admin-novalys

# Configurer SSH avec clés
sudo mkdir /home/admin-novalys/.ssh
sudo chown admin-novalys:admin-novalys /home/admin-novalys/.ssh
sudo chmod 700 /home/admin-novalys/.ssh
```

### Configuration firewall avancée
```bash
# Restreindre l'accès à certaines IPs
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port protocol="tcp" port="80" accept'

# Bloquer l'accès direct au port 3000
sudo firewall-cmd --permanent --remove-port=3000/tcp
```

### SSL avec Let's Encrypt (pour domaine public)
```bash
# Installer certbot
sudo dnf install -y certbot python3-certbot-nginx

# Obtenir un certificat (remplacer votre-domaine.com)
sudo certbot --nginx -d votre-domaine.com

# Auto-renouvellement
sudo systemctl enable --now certbot-renew.timer
```

## 📞 Support

En cas de problème, vérifiez :
1. Les logs: `sudo journalctl -u novalys -f`
2. Le statut: `novalys-status`
3. La configuration: `/opt/novalys/.env`
4. Les permissions: `ls -la /opt/novalys/`

---
**NOVALYS** - Installation automatisée pour Rocky Linux 9 🚀
