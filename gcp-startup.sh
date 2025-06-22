#!/bin/bash

# 🚀 Script de démarrage GCP pour NOVALYS
# Auteur: NOVALYS
# Description: Script de démarrage automatique pour Google Cloud Platform
# Utilisation: Utiliser ce script comme startup-script dans GCP

# Configuration des logs pour GCP
exec > >(tee -a /var/log/novalys-startup.log)
exec 2>&1

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}[GCP-STARTUP]${NC} $(date): Début de l'installation NOVALYS sur GCP"

# Vérifier si le script a déjà été exécuté
LOCK_FILE="/tmp/novalys-startup.lock"
if [ -f "$LOCK_FILE" ]; then
    echo -e "${YELLOW}[GCP-STARTUP]${NC} Installation déjà en cours ou terminée"
    exit 0
fi

# Créer le fichier de verrouillage
touch "$LOCK_FILE"

# Fonction de nettoyage en cas d'erreur
cleanup() {
    rm -f "$LOCK_FILE"
    echo -e "${RED}[GCP-STARTUP]${NC} $(date): Erreur lors de l'installation"
}
trap cleanup ERR

# Attendre que le système soit complètement démarré
echo -e "${BLUE}[GCP-STARTUP]${NC} Attente de la stabilisation du système..."
sleep 30

# Vérifier la connectivité Internet
echo -e "${BLUE}[GCP-STARTUP]${NC} Vérification de la connectivité Internet..."
for i in {1..5}; do
    if curl -s --connect-timeout 10 https://google.com > /dev/null; then
        echo -e "${GREEN}[GCP-STARTUP]${NC} Connectivité Internet OK"
        break
    else
        echo -e "${YELLOW}[GCP-STARTUP]${NC} Tentative $i/5 - En attente de la connectivité..."
        sleep 10
    fi
    
    if [ $i -eq 5 ]; then
        echo -e "${RED}[GCP-STARTUP]${NC} Impossible d'établir la connectivité Internet"
        exit 1
    fi
done

# Télécharger et exécuter le script d'installation NOVALYS
echo -e "${BLUE}[GCP-STARTUP]${NC} Téléchargement du script d'installation NOVALYS..."

# URL du script d'installation
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/TheFanta200/google-gemini-clone/main/install-novalys-auto.sh"

# Télécharger le script avec gestion d'erreur
if curl -fsSL "$INSTALL_SCRIPT_URL" -o /tmp/install-novalys.sh; then
    echo -e "${GREEN}[GCP-STARTUP]${NC} Script téléchargé avec succès"
    
    # Rendre le script exécutable
    chmod +x /tmp/install-novalys.sh
    
    # Exécuter le script d'installation
    echo -e "${BLUE}[GCP-STARTUP]${NC} $(date): Début de l'installation NOVALYS"
    
    if bash /tmp/install-novalys.sh; then
        echo -e "${GREEN}[GCP-STARTUP]${NC} $(date): Installation NOVALYS terminée avec succès"
        
        # Récupérer l'IP de la VM pour les logs
        VM_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/external-ip)
        
        echo -e "${GREEN}[GCP-STARTUP]${NC} ================================================"
        echo -e "${GREEN}[GCP-STARTUP]${NC} 🎉 NOVALYS installé et configuré avec succès !"
        echo -e "${GREEN}[GCP-STARTUP]${NC} 🌐 Accès: http://$VM_IP"
        echo -e "${GREEN}[GCP-STARTUP]${NC} 🔒 HTTPS: https://$VM_IP"
        echo -e "${GREEN}[GCP-STARTUP]${NC} ================================================"
        
        # Marquer l'installation comme terminée
        echo "INSTALLATION_COMPLETE=$(date)" >> "$LOCK_FILE"
        
    else
        echo -e "${RED}[GCP-STARTUP]${NC} $(date): Erreur lors de l'installation NOVALYS"
        rm -f "$LOCK_FILE"
        exit 1
    fi
    
    # Nettoyer le script temporaire
    rm -f /tmp/install-novalys.sh
    
else
    echo -e "${RED}[GCP-STARTUP]${NC} Impossible de télécharger le script d'installation"
    rm -f "$LOCK_FILE"
    exit 1
fi

echo -e "${BLUE}[GCP-STARTUP]${NC} $(date): Script de démarrage GCP terminé"