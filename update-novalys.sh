#!/bin/bash

# 🔧 Script de mise à jour automatique NOVALYS
# Utilisation: ./update-novalys.sh

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

APP_DIR="/opt/novalys"
SERVICE_USER="novalys"

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Vérifier si on est root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root (sudo)"
    exit 1
fi

print_status "🔄 Mise à jour de NOVALYS..."

# Sauvegarder le fichier .env
print_status "Sauvegarde de la configuration..."
cp ${APP_DIR}/.env ${APP_DIR}/.env.backup

# Arrêter le service
print_status "Arrêt du service..."
systemctl stop novalys

# Mise à jour du code
print_status "Mise à jour du code source..."
cd ${APP_DIR}
sudo -u ${SERVICE_USER} git pull origin main

# Mise à jour des dépendances
print_status "Mise à jour des dépendances..."
sudo -u ${SERVICE_USER} npm install

# Restaurer la configuration
print_status "Restauration de la configuration..."
if [ -f "${APP_DIR}/.env.backup" ]; then
    cp ${APP_DIR}/.env.backup ${APP_DIR}/.env
    chown ${SERVICE_USER}:${SERVICE_USER} ${APP_DIR}/.env
    rm ${APP_DIR}/.env.backup
fi

# Redémarrer le service
print_status "Redémarrage du service..."
systemctl start novalys

# Vérifier le statut
sleep 3
if systemctl is-active --quiet novalys; then
    print_success "✅ NOVALYS mis à jour et redémarré avec succès!"
else
    print_warning "⚠️  Erreur lors du redémarrage. Vérifiez les logs:"
    echo "journalctl -u novalys --no-pager -l"
fi
