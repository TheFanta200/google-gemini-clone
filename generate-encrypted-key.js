const crypto = require('crypto');
const { generateEncryptedApiKey } = require('./crypto-utils');

// Script pour générer la clé API chiffrée
const API_KEY = "AIzaSyDTCjL-Waay8t2GiksFZAOfaw4DeJDARtE";

console.log('🔐 Génération de la clé API chiffrée...\n');
generateEncryptedApiKey(API_KEY);
console.log('\n✅ Copiez ces valeurs dans votre fichier .env et supprimez GEMINI_API_KEY');
