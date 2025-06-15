#!/bin/bash

# 🚀 Script d'installation automatique NOVALYS pour Rocky Linux 9
# Auteur: NOVALYS
# Description: Installation complète de l'application Google Gemini Clone

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables de configuration
REPO_URL="https://github.com/TheFanta200/google-gemini-clone.git"
APP_DIR="/opt/novalys"
SERVICE_USER="novalys"
NODE_VERSION="20"

# Fonction d'affichage avec couleurs
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier si le script est exécuté en tant que root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Ce script doit être exécuté en tant que root (sudo)"
        exit 1
    fi
}

# Bannière de bienvenue
show_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 INSTALLATION NOVALYS 🚀                ║"
    echo "║                                                               ║"
    echo "║           Installation automatique pour Rocky Linux 9        ║"
    echo "║                Google Gemini Clone Sécurisé                   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Mise à jour du système
update_system() {
    print_status "Mise à jour du système Rocky Linux 9..."
    dnf update -y
    dnf groupinstall -y "Development Tools"
    dnf install -y curl wget git unzip policycoreutils-python-utils firewalld
    print_success "Système mis à jour avec succès"
}

# Installation de Node.js et npm
install_nodejs() {
    print_status "Installation de Node.js ${NODE_VERSION}..."
    
    # Installation de NodeSource repository
    curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash -
    dnf install -y nodejs
    
    # Vérification de l'installation
    NODE_VER=$(node --version)
    NPM_VER=$(npm --version)
    
    print_success "Node.js ${NODE_VER} installé"
    print_success "npm ${NPM_VER} installé"
    
    # Installation de PM2 pour la gestion des processus
    npm install -g pm2
    print_success "PM2 installé pour la gestion des processus"
}

# Création de l'utilisateur pour l'application
create_user() {
    print_status "Création de l'utilisateur ${SERVICE_USER}..."
    
    if ! id "${SERVICE_USER}" &>/dev/null; then
        useradd -r -s /bin/bash -d ${APP_DIR} -m ${SERVICE_USER}
        print_success "Utilisateur ${SERVICE_USER} créé"
    else
        print_warning "L'utilisateur ${SERVICE_USER} existe déjà"
    fi
}

# Clonage et configuration de l'application
setup_application() {
    print_status "Configuration de l'application NOVALYS..."
    
    # Création du répertoire de l'application
    mkdir -p ${APP_DIR}
    cd ${APP_DIR}
    
    # Clonage du dépôt GitHub
    if [ -d "${APP_DIR}/.git" ]; then
        print_status "Mise à jour du dépôt existant..."
        git pull origin main
    else
        print_status "Clonage du dépôt GitHub..."
        git clone ${REPO_URL} .
    fi
    
    # Changement de propriétaire
    chown -R ${SERVICE_USER}:${SERVICE_USER} ${APP_DIR}
    
    print_success "Application clonée et configurée"
}

# Installation des dépendances Node.js
install_dependencies() {
    print_status "Installation des dépendances Node.js..."
    
    cd ${APP_DIR}
    sudo -u ${SERVICE_USER} npm install
    
    print_success "Dépendances installées"
}

# Configuration du fichier .env
setup_environment() {
    print_status "Configuration des variables d'environnement..."
    
    if [ ! -f "${APP_DIR}/.env" ]; then
        cat > ${APP_DIR}/.env << EOF
# Variables d'environnement NOVALYS
# Clé de chiffrement (à modifier pour la production)
ENCRYPTION_KEY=novalys-production-key-32-caracteres-minimum!

# Clé API Gemini (à renseigner)
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE

# Configuration du serveur
PORT=3000
NODE_ENV=production

# Clé API chiffrée (optionnel - à générer avec npm run encrypt-key)
# ENCRYPTED_API_KEY=
# API_IV=
# API_AUTH_TAG=
EOF
        chown ${SERVICE_USER}:${SERVICE_USER} ${APP_DIR}/.env
        chmod 600 ${APP_DIR}/.env
        
        print_warning "⚠️  IMPORTANT: Modifiez le fichier ${APP_DIR}/.env avec votre clé API Gemini"
        print_warning "⚠️  Changez aussi ENCRYPTION_KEY pour la production"
    else
        print_warning "Le fichier .env existe déjà - configuration conservée"
    fi
}

# Configuration du service systemd
setup_systemd() {
    print_status "Configuration du service systemd..."
    
    cat > /etc/systemd/system/novalys.service << EOF
[Unit]
Description=NOVALYS - Google Gemini Clone
Documentation=https://github.com/TheFanta200/google-gemini-clone
After=network.target

[Service]
Type=simple
User=${SERVICE_USER}
WorkingDirectory=${APP_DIR}
Environment=NODE_ENV=production
ExecStart=/usr/bin/node server.js
ExecReload=/bin/kill -USR1 \$MAINPID
Restart=always
RestartSec=10

# Sécurité
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=${APP_DIR}

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=novalys

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable novalys
    
    print_success "Service systemd configuré"
}

# Configuration du firewall
setup_firewall() {
    print_status "Configuration du firewall..."
    
    systemctl enable firewalld
    systemctl start firewalld
    
    firewall-cmd --permanent --add-port=3000/tcp
    firewall-cmd --reload
    
    print_success "Port 3000 ouvert dans le firewall"
}

# Configuration de Nginx (proxy inverse)
setup_nginx() {
    print_status "Installation et configuration de Nginx..."
    
    dnf install -y nginx
    
    # Configuration du site NOVALYS
    cat > /etc/nginx/conf.d/novalys.conf << EOF
server {
    listen 80;
    server_name _;
    
    # Logs
    access_log /var/log/nginx/novalys_access.log;
    error_log /var/log/nginx/novalys_error.log;
    
    # Proxy vers l'application Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # Gestion des fichiers statiques
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        proxy_pass http://127.0.0.1:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Sécurité
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

    # Configuration SSL (certificat auto-signé pour le développement)
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/novalys.key \
        -out /etc/nginx/ssl/novalys.crt \
        -subj "/C=FR/ST=France/L=Paris/O=NOVALYS/OU=IT/CN=novalys.local"
    
    # Ajout de la configuration HTTPS
    cat >> /etc/nginx/conf.d/novalys.conf << EOF

# Configuration HTTPS (certificat auto-signé)
server {
    listen 443 ssl http2;
    server_name _;
    
    ssl_certificate /etc/nginx/ssl/novalys.crt;
    ssl_certificate_key /etc/nginx/ssl/novalys.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Même configuration que HTTP
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    # Test de la configuration
    nginx -t
    
    systemctl enable nginx
    
    # Ouvrir les ports HTTP/HTTPS
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
    
    print_success "Nginx configuré avec support HTTP/HTTPS"
}

# Configuration des logs et monitoring
setup_monitoring() {
    print_status "Configuration du monitoring et des logs..."
    
    # Rotation des logs
    cat > /etc/logrotate.d/novalys << EOF
/var/log/nginx/novalys_*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 nginx nginx
    postrotate
        systemctl reload nginx
    endscript
}
EOF

    # Script de monitoring simple
    cat > /usr/local/bin/novalys-status << EOF
#!/bin/bash
echo "=== NOVALYS Status ==="
echo "Service: \$(systemctl is-active novalys)"
echo "Nginx: \$(systemctl is-active nginx)"
echo "Port 3000: \$(ss -tlnp | grep :3000 || echo 'Not listening')"
echo "Memory: \$(ps aux | grep node | grep -v grep | awk '{print \$4}')% RAM"
echo "Uptime: \$(systemctl show novalys --property=ActiveEnterTimestamp --value)"
EOF
    chmod +x /usr/local/bin/novalys-status
    
    print_success "Monitoring configuré - Utilisez 'novalys-status' pour vérifier l'état"
}

# Démarrage des services
start_services() {
    print_status "Démarrage des services..."
    
    systemctl start novalys
    systemctl start nginx
    
    sleep 3
    
    # Vérification du statut
    if systemctl is-active --quiet novalys; then
        print_success "Service NOVALYS démarré"
    else
        print_error "Erreur lors du démarrage du service NOVALYS"
        journalctl -u novalys --no-pager -l
    fi
    
    if systemctl is-active --quiet nginx; then
        print_success "Nginx démarré"
    else
        print_error "Erreur lors du démarrage de Nginx"
    fi
}

# Affichage du résumé final
show_summary() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   🎉 INSTALLATION TERMINÉE 🎉                ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}📋 Résumé de l'installation:${NC}"
    echo "• Application: ${APP_DIR}"
    echo "• Utilisateur: ${SERVICE_USER}"
    echo "• Service: systemctl {start|stop|restart|status} novalys"
    echo "• Logs: journalctl -u novalys -f"
    echo "• Monitoring: novalys-status"
    echo ""
    
    echo -e "${BLUE}🌐 Accès à l'application:${NC}"
    IP=$(hostname -I | awk '{print $1}')
    echo "• HTTP:  http://${IP}"
    echo "• HTTPS: https://${IP} (certificat auto-signé)"
    echo "• Local: http://localhost"
    echo ""
    
    echo -e "${YELLOW}⚠️  Actions requises:${NC}"
    echo "1. Modifier ${APP_DIR}/.env avec votre clé API Gemini"
    echo "2. Redémarrer le service: systemctl restart novalys"
    echo "3. (Optionnel) Chiffrer la clé API: cd ${APP_DIR} && npm run encrypt-key"
    echo ""
    
    echo -e "${BLUE}🔧 Commandes utiles:${NC}"
    echo "• Redémarrer NOVALYS: systemctl restart novalys"
    echo "• Voir les logs: journalctl -u novalys -f"
    echo "• Mettre à jour: cd ${APP_DIR} && git pull && npm install && systemctl restart novalys"
    echo "• Statut: novalys-status"
}

# Fonction principale
main() {
    show_banner
    check_root
    
    print_status "Début de l'installation NOVALYS sur Rocky Linux 9"
    
    update_system
    install_nodejs
    create_user
    setup_application
    install_dependencies
    setup_environment
    setup_systemd
    setup_firewall
    setup_nginx
    setup_monitoring
    start_services
    
    show_summary
    
    print_success "Installation terminée avec succès ! 🚀"
}

# Gestion des erreurs
trap 'print_error "Installation interrompue par une erreur à la ligne $LINENO"' ERR

# Exécution du script principal
main "$@"
