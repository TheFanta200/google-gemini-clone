const crypto = require('crypto');

// Clé de chiffrement (à garder secrète et différente pour chaque environnement)
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || 'votre-cle-secrete-32-caracteres-minimum!';
const ALGORITHM = 'aes-256-gcm';

/**
 * Chiffre une chaîne de caractères
 */
function encryptString(text) {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipher(ALGORITHM, ENCRYPTION_KEY);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
        encrypted: encrypted,
        iv: iv.toString('hex'),
        authTag: authTag.toString('hex')
    };
}

/**
 * Déchiffre une chaîne de caractères
 */
function decryptString(encryptedData) {
    try {
        const decipher = crypto.createDecipher(ALGORITHM, ENCRYPTION_KEY);
        
        let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        
        return decrypted;
    } catch (error) {
        throw new Error('Erreur de déchiffrement: ' + error.message);
    }
}

/**
 * Utilitaire pour chiffrer une clé API (à utiliser une seule fois)
 */
function generateEncryptedApiKey(apiKey) {
    const encrypted = encryptString(apiKey);
    console.log('Clé API chiffrée:');
    console.log(`ENCRYPTED_API_KEY=${encrypted.encrypted}`);
    console.log(`API_IV=${encrypted.iv}`);
    console.log(`API_AUTH_TAG=${encrypted.authTag}`);
}

module.exports = {
    encryptString,
    decryptString,
    generateEncryptedApiKey
};
