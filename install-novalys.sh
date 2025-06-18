#!/bin/bash

# 🚀 Script d'installation NOVALYS - ALL IN ONE pour Rocky Linux 9
# Auteur: NOVALYS
# Description: Installation complète automatique avec gestion intelligente des erreurs
# Utilisation: curl -sSL https://raw.githubusercontent.com/TheFanta200/google-gemini-clone/main/install-novalys.sh | sudo bash

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

print_header() {
    echo -e "${PURPLE}[STEP]${NC} $1"
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
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    🚀 NOVALYS INSTALLER 🚀                   ║"
    echo "║                                                               ║"
    echo "║         Installation automatique ALL-IN-ONE complète         ║"
    echo "║               Rocky Linux 9 - Google Gemini Clone            ║"
    echo "║                                                               ║"
    echo "║                     Installation sécurisée                   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Détection de l'environnement et état du système
detect_environment() {
    print_header "🔍 DÉTECTION DE L'ENVIRONNEMENT"
    
    # Vérification OS
    if [ -f /etc/rocky-release ]; then
        OS_VERSION=$(cat /etc/rocky-release)
        print_success "OS détecté: $OS_VERSION"
    else
        print_warning "OS non reconnu - Tentative de compatibilité RHEL"
    fi
    
    # Vérification des ressources système
    MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
    DISK_SPACE=$(df -h / | awk 'NR==2{print $4}')
    print_status "Mémoire disponible: ${MEMORY_GB}GB"
    print_status "Espace disque disponible: ${DISK_SPACE}"
    
    if [ "$MEMORY_GB" -lt 1 ]; then
        print_warning "Attention: Mémoire faible (${MEMORY_GB}GB). Recommandé: 2GB+"
    fi
    
    # Vérification de l'installation existante
    if [ -d "$APP_DIR" ]; then
        print_warning "Installation NOVALYS existante détectée dans $APP_DIR"
        EXISTING_INSTALL=true
    else
        EXISTING_INSTALL=false
    fi
    
    echo ""
}

# Installation des outils nécessaires
install_tools() {
    print_header "📦 INSTALLATION DES OUTILS SYSTÈME"
    
    print_status "Installation des outils de base..."
    dnf install -y curl wget git unzip policycoreutils-python-utils firewalld epel-release &>/dev/null
    print_success "Outils de base installés"
    
    # Vérification et installation des dépendances de compilation si nécessaire
    if ! command -v gcc &> /dev/null; then
        print_status "Installation des outils de développement..."
        dnf groupinstall -y "Development Tools" &>/dev/null
        print_success "Outils de développement installés"
    fi
    
    echo ""
}

# Installation de Node.js et npm
install_nodejs() {
    print_header "🟢 INSTALLATION NODE.JS"
    
    # Vérifier si Node.js est déjà installé
    if command -v node &> /dev/null; then
        CURRENT_NODE=$(node --version)
        print_status "Node.js déjà installé: $CURRENT_NODE"
        
        # Vérifier la version
        MAJOR_VERSION=$(echo $CURRENT_NODE | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$MAJOR_VERSION" -ge 18 ]; then
            print_success "Version Node.js compatible"
        else
            print_warning "Version Node.js trop ancienne, mise à jour..."
            NEED_NODE_UPDATE=true
        fi
    else
        NEED_NODE_UPDATE=true
    fi
    
    if [ "$NEED_NODE_UPDATE" = true ]; then
        print_status "Installation de Node.js ${NODE_VERSION}..."
        
        # Nettoyage des anciennes sources NodeSource
        rm -f /etc/yum.repos.d/nodesource*.repo
        
        # Installation de NodeSource repository
        curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash - &>/dev/null
        dnf install -y nodejs &>/dev/null
        
        # Vérification de l'installation
        NODE_VER=$(node --version)
        NPM_VER=$(npm --version)
        
        print_success "Node.js ${NODE_VER} installé"
        print_success "npm ${NPM_VER} installé"
    fi
    
    # Installation de PM2 pour la gestion des processus
    if ! command -v pm2 &> /dev/null; then
        print_status "Installation de PM2..."
        npm install -g pm2 &>/dev/null
        print_success "PM2 installé pour la gestion des processus"
    else
        print_status "PM2 déjà installé"
    fi
    
    echo ""
}

# Création de l'utilisateur pour l'application
create_user() {
    print_header "👤 CONFIGURATION UTILISATEUR"
    
    if ! id "${SERVICE_USER}" &>/dev/null; then
        print_status "Création de l'utilisateur ${SERVICE_USER}..."
        useradd -r -s /bin/bash -d ${APP_DIR} -m ${SERVICE_USER}
        print_success "Utilisateur ${SERVICE_USER} créé"
    else
        print_status "L'utilisateur ${SERVICE_USER} existe déjà"
    fi
    
    echo ""
}

# Gestion intelligente de l'application
setup_application() {
    print_header "📁 CONFIGURATION APPLICATION"
    
    # Sauvegarder la configuration existante
    if [ "$EXISTING_INSTALL" = true ] && [ -f "${APP_DIR}/.env" ]; then
        print_status "Sauvegarde de la configuration existante..."
        cp ${APP_DIR}/.env /tmp/novalys_env_backup_$(date +%Y%m%d_%H%M%S)
        CONFIG_BACKUP=true
        print_success "Configuration sauvegardée"
    fi
    
    # Arrêter le service s'il tourne
    if systemctl is-active --quiet novalys 2>/dev/null; then
        print_status "Arrêt du service NOVALYS..."
        systemctl stop novalys
    fi
    
    # Création/nettoyage du répertoire de l'application
    mkdir -p ${APP_DIR}
    
    if [ "$EXISTING_INSTALL" = true ]; then
        print_status "Nettoyage de l'installation existante..."
        cd ${APP_DIR}
        
        # Supprimer tout sauf .env si présent
        find . -mindepth 1 -not -name '.env' -delete 2>/dev/null || true
        
        print_status "Clonage de la dernière version..."
        sudo -u ${SERVICE_USER} git clone ${REPO_URL} temp_clone
        sudo -u ${SERVICE_USER} mv temp_clone/* . 2>/dev/null || true
        sudo -u ${SERVICE_USER} mv temp_clone/.[^.]* . 2>/dev/null || true
        sudo -u ${SERVICE_USER} rmdir temp_clone
    else
        print_status "Installation fraîche - Clonage du dépôt GitHub..."
        
        # Vérifier si le répertoire est vide
        if [ "$(ls -A ${APP_DIR} 2>/dev/null)" ]; then
            print_status "Répertoire non vide détecté - Utilisation de la méthode alternative..."
            cd ${APP_DIR}
            
            # Sauvegarder les fichiers .env existants
            if [ -f ".env" ]; then
                cp .env /tmp/novalys_env_backup_$(date +%Y%m%d_%H%M%S)
                CONFIG_BACKUP=true
            fi
            
            # Nettoyer le répertoire mais garder la structure
            find . -mindepth 1 -not -name '.env' -delete 2>/dev/null || true
            
            # Cloner dans un répertoire temporaire puis déplacer
            sudo -u ${SERVICE_USER} git clone ${REPO_URL} temp_clone
            sudo -u ${SERVICE_USER} mv temp_clone/* . 2>/dev/null || true
            sudo -u ${SERVICE_USER} mv temp_clone/.[^.]* . 2>/dev/null || true
            sudo -u ${SERVICE_USER} rmdir temp_clone
        else
            # Répertoire vide, clonage direct
            cd ${APP_DIR}
            sudo -u ${SERVICE_USER} git clone ${REPO_URL} .
        fi
    fi
    
    # Restaurer la configuration si elle existait
    if [ "$CONFIG_BACKUP" = true ]; then
        BACKUP_FILE=$(ls /tmp/novalys_env_backup_* | tail -1)
        cp $BACKUP_FILE ${APP_DIR}/.env
        chown ${SERVICE_USER}:${SERVICE_USER} ${APP_DIR}/.env
        chmod 600 ${APP_DIR}/.env
        print_success "Configuration restaurée"
    fi
    
    # Changement de propriétaire
    chown -R ${SERVICE_USER}:${SERVICE_USER} ${APP_DIR}
    
    print_success "Application configurée"
    echo ""
}

# Installation des dépendances Node.js
install_dependencies() {
    print_header "📚 INSTALLATION DÉPENDANCES"
    
    cd ${APP_DIR}
    print_status "Installation des dépendances npm..."
    
    # Nettoyage du cache npm si nécessaire
    sudo -u ${SERVICE_USER} npm cache clean --force &>/dev/null || true
    
    # Installation des dépendances
    sudo -u ${SERVICE_USER} npm install &>/dev/null
    
    print_success "Dépendances installées"
    echo ""
}

# Configuration du fichier .env
setup_environment() {
    print_header "⚙️ CONFIGURATION ENVIRONNEMENT"
    
    if [ ! -f "${APP_DIR}/.env" ]; then
        print_status "Création de la configuration environnement..."
        
        # Générer une clé de chiffrement aléatoire
        RANDOM_KEY=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-32)
        
        cat > ${APP_DIR}/.env << EOF
# Variables d'environnement NOVALYS
# Clé de chiffrement (générée automatiquement)
ENCRYPTION_KEY=novalys-${RANDOM_KEY}

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
        API_CONFIG_NEEDED=true
    else
        print_status "Configuration environnement existante conservée"
        API_CONFIG_NEEDED=false
    fi
    
    echo ""
}

# Configuration du service systemd
setup_systemd() {
    print_header "🔧 CONFIGURATION SERVICE SYSTEMD"
    
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
    systemctl enable novalys &>/dev/null
    
    print_success "Service systemd configuré et activé"
    echo ""
}

# Configuration du firewall
setup_firewall() {
    print_header "🔥 CONFIGURATION FIREWALL"
    
    print_status "Configuration du firewall..."
    
    # Démarrer firewalld s'il n'est pas actif
    if ! systemctl is-active --quiet firewalld; then
        systemctl enable firewalld &>/dev/null
        systemctl start firewalld &>/dev/null
        print_status "Firewalld démarré"
    fi
    
    # Configuration des ports
    firewall-cmd --permanent --add-port=3000/tcp &>/dev/null
    firewall-cmd --permanent --add-service=http &>/dev/null
    firewall-cmd --permanent --add-service=https &>/dev/null
    firewall-cmd --reload &>/dev/null
    
    print_success "Firewall configuré (ports 80, 443, 3000)"
    echo ""
}

# Configuration de Nginx
setup_nginx() {
    print_header "🌐 CONFIGURATION NGINX"
    
    # Installation de Nginx si nécessaire
    if ! command -v nginx &> /dev/null; then
        print_status "Installation de Nginx..."
        dnf install -y nginx &>/dev/null
        print_success "Nginx installé"
    else
        print_status "Nginx déjà installé"
    fi
    
    print_status "Configuration du proxy inverse..."
    
    # Configuration du site NOVALYS
    cat > /etc/nginx/conf.d/novalys.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    # Redirection automatique vers HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name _;
    
    # Certificats SSL
    ssl_certificate /etc/nginx/ssl/novalys.crt;
    ssl_certificate_key /etc/nginx/ssl/novalys.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Logs
    access_log /var/log/nginx/novalys_access.log;
    error_log /var/log/nginx/novalys_error.log;
    
    # Proxy vers l'application Node.js
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
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
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
EOF

    # Génération du certificat SSL auto-signé
    print_status "Génération du certificat SSL..."
    mkdir -p /etc/nginx/ssl
    
    if [ ! -f "/etc/nginx/ssl/novalys.crt" ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout /etc/nginx/ssl/novalys.key \
            -out /etc/nginx/ssl/novalys.crt \
            -subj "/C=FR/ST=France/L=Paris/O=NOVALYS/OU=IT/CN=novalys.local" &>/dev/null
        print_success "Certificat SSL généré"
    fi
    
    # Test de la configuration
    if nginx -t &>/dev/null; then
        print_success "Configuration Nginx validée"
        systemctl enable nginx &>/dev/null
    else
        print_error "Erreur dans la configuration Nginx"
        nginx -t
    fi
    
    echo ""
}

# Configuration des logs et monitoring
setup_monitoring() {
    print_header "📊 CONFIGURATION MONITORING"
    
    print_status "Configuration de la rotation des logs..."
    
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

    # Script de monitoring avancé
    print_status "Installation du script de monitoring..."
    cat > /usr/local/bin/novalys-status << 'EOF'
#!/bin/bash

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           NOVALYS STATUS             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Service NOVALYS
if systemctl is-active --quiet novalys; then
    echo -e "Service NOVALYS: ${GREEN}✅ Actif${NC}"
else
    echo -e "Service NOVALYS: ${RED}❌ Inactif${NC}"
fi

# Nginx
if systemctl is-active --quiet nginx; then
    echo -e "Nginx:          ${GREEN}✅ Actif${NC}"
else
    echo -e "Nginx:          ${RED}❌ Inactif${NC}"
fi

# Port 3000
if ss -tlnp | grep -q :3000; then
    echo -e "Port 3000:      ${GREEN}✅ Ouvert${NC}"
else
    echo -e "Port 3000:      ${RED}❌ Fermé${NC}"
fi

# Ressources
MEMORY=$(ps aux | grep node | grep -v grep | awk '{sum+=$4} END {printf "%.1f", sum}')
echo -e "Mémoire:        ${YELLOW}${MEMORY}%${NC} RAM"

# Uptime
UPTIME=$(systemctl show novalys --property=ActiveEnterTimestamp --value 2>/dev/null)
if [ -n "$UPTIME" ] && [ "$UPTIME" != "0" ]; then
    echo -e "Démarré:        ${GREEN}${UPTIME}${NC}"
else
    echo -e "Démarré:        ${RED}Non disponible${NC}"
fi

# IP du serveur
IP=$(hostname -I | awk '{print $1}')
echo ""
echo -e "${BLUE}🌐 Accès:${NC}"
echo -e "• HTTP:  ${YELLOW}http://${IP}${NC}"
echo -e "• HTTPS: ${YELLOW}https://${IP}${NC}"

# Logs récents
echo ""
echo -e "${BLUE}📋 Logs récents:${NC}"
journalctl -u novalys --no-pager -l --since "5 minutes ago" | tail -3
EOF
    chmod +x /usr/local/bin/novalys-status
    
    # Script de mise à jour
    print_status "Installation du script de mise à jour..."
    cat > /usr/local/bin/novalys-update << 'EOF'
#!/bin/bash
set -e

APP_DIR="/opt/novalys"
SERVICE_USER="novalys"

echo "🔄 Mise à jour NOVALYS..."

# Sauvegarde
cp ${APP_DIR}/.env /tmp/novalys_env_backup

# Arrêt du service
systemctl stop novalys

# Mise à jour
cd ${APP_DIR}
sudo -u ${SERVICE_USER} git pull origin main
sudo -u ${SERVICE_USER} npm install

# Restauration config
cp /tmp/novalys_env_backup ${APP_DIR}/.env
chown ${SERVICE_USER}:${SERVICE_USER} ${APP_DIR}/.env

# Redémarrage
systemctl start novalys

echo "✅ Mise à jour terminée !"
EOF
    chmod +x /usr/local/bin/novalys-update
    
    print_success "Monitoring et utilitaires configurés"
    echo ""
}

# Démarrage des services
start_services() {
    print_header "🚀 DÉMARRAGE DES SERVICES"
    
    print_status "Démarrage des services..."
    
    # Démarrer NOVALYS
    systemctl start novalys
    sleep 2
    
    # Démarrer Nginx
    systemctl start nginx
    sleep 1
    
    # Vérification du statut
    if systemctl is-active --quiet novalys; then
        print_success "✅ Service NOVALYS démarré"
    else
        print_error "❌ Erreur lors du démarrage du service NOVALYS"
        echo "Logs d'erreur:"
        journalctl -u novalys --no-pager -l | tail -10
        return 1
    fi
    
    if systemctl is-active --quiet nginx; then
        print_success "✅ Nginx démarré"
    else
        print_error "❌ Erreur lors du démarrage de Nginx"
        nginx -t
        return 1
    fi
    
    echo ""
}

# Test de l'installation
test_installation() {
    print_header "🧪 TEST DE L'INSTALLATION"
    
    print_status "Test de connectivité locale..."
    
    # Test du port 3000
    if curl -s http://localhost:3000 &>/dev/null; then
        print_success "✅ Application répond sur le port 3000"
    else
        print_warning "⚠️  Application non accessible sur le port 3000"
    fi
    
    # Test Nginx
    if curl -s -k https://localhost &>/dev/null; then
        print_success "✅ Nginx fonctionne correctement"
    else
        print_warning "⚠️  Nginx non accessible"
    fi
    
    echo ""
}

# Affichage du résumé final
show_summary() {
    clear
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                   🎉 INSTALLATION TERMINÉE 🎉                ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Informations système
    IP=$(hostname -I | awk '{print $1}')
    
    echo -e "${CYAN}📋 Résumé de l'installation NOVALYS:${NC}"
    echo "• Application:    ${APP_DIR}"
    echo "• Utilisateur:    ${SERVICE_USER}"
    echo "• Configuration:  ${APP_DIR}/.env"
    echo "• Service:        systemctl {start|stop|restart|status} novalys"
    echo ""
    
    echo -e "${CYAN}🌐 Accès à l'application:${NC}"
    echo "• HTTP:           http://${IP}"
    echo "• HTTPS:          https://${IP} (certificat auto-signé)"
    echo "• Local:          http://localhost"
    echo ""
    
    echo -e "${CYAN}🔧 Commandes utiles:${NC}"
    echo "• État:           novalys-status"
    echo "• Logs:           journalctl -u novalys -f"
    echo "• Mise à jour:    novalys-update"
    echo "• Redémarrer:     systemctl restart novalys"
    echo ""
    
    if [ "$API_CONFIG_NEEDED" = true ]; then
        echo -e "${YELLOW}⚠️  ACTIONS REQUISES:${NC}"
        echo "1. Modifier ${APP_DIR}/.env avec votre clé API Gemini :"
        echo "   nano ${APP_DIR}/.env"
        echo "2. Remplacer YOUR_GEMINI_API_KEY_HERE par votre vraie clé"
        echo "3. Redémarrer le service :"
        echo "   systemctl restart novalys"
        echo ""
        echo -e "${BLUE}💡 Optionnel - Chiffrement de la clé API:${NC}"
        echo "cd ${APP_DIR} && npm run encrypt-key"
        echo ""
    fi
    
    echo -e "${GREEN}🎯 Installation ALL-IN-ONE terminée avec succès !${NC}"
    echo -e "${BLUE}📞 Support: Utilisez 'novalys-status' pour diagnostiquer${NC}"
}

# Gestion des erreurs
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Installation interrompue par une erreur à la ligne $line_number (code $exit_code)"
    
    echo ""
    echo -e "${YELLOW}🔧 Diagnostic rapide:${NC}"
    echo "• Logs NOVALYS: journalctl -u novalys --no-pager -l"
    echo "• Logs Nginx:   tail -f /var/log/nginx/error.log"
    echo "• Test config:  nginx -t"
    echo "• État:         novalys-status"
    
    exit $exit_code
}

# Fonction principale
main() {
    # Gestion des erreurs avec numéro de ligne
    trap 'handle_error $LINENO' ERR
    
    show_banner
    check_root
    detect_environment
    
    # Questions utilisateur pour installation personnalisée
    echo -e "${YELLOW}🤔 Type d'installation:${NC}"
    echo "1. Installation complète (recommandé)"
    echo "2. Installation rapide (sans Nginx)"
    echo "3. Réparation/Mise à jour"
    echo ""
    read -p "Votre choix [1-3]: " INSTALL_TYPE
    
    case $INSTALL_TYPE in
        2)
            SKIP_NGINX=true
            ;;
        3)
            REPAIR_MODE=true
            ;;
        *)
            INSTALL_TYPE=1
            ;;
    esac
    
    echo ""
    print_status "Début de l'installation NOVALYS (Type: $INSTALL_TYPE)"
    
    # Installation des composants
    install_tools
    install_nodejs
    create_user
    setup_application
    install_dependencies
    setup_environment
    setup_systemd
    setup_firewall
    
    if [ "$SKIP_NGINX" != true ]; then
        setup_nginx
    fi
    
    setup_monitoring
    start_services
    test_installation
    
    show_summary
    
    print_success "🚀 Installation ALL-IN-ONE terminée avec succès !"
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
