const express = require('express');
const cors = require('cors');
const path = require('path');
const { decryptString } = require('./crypto-utils');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// API configuration avec déchiffrement
let API_KEY;
try {
    // Si vous utilisez la clé chiffrée
    if (process.env.ENCRYPTED_API_KEY) {
        const encryptedData = {
            encrypted: process.env.ENCRYPTED_API_KEY,
            iv: process.env.API_IV,
            authTag: process.env.API_AUTH_TAG
        };
        API_KEY = decryptString(encryptedData);
        console.log('🔓 Clé API déchiffrée avec succès');
    } else {
        // Fallback vers la clé en clair (pour la transition)
        API_KEY = process.env.GEMINI_API_KEY;
        console.log('⚠️  Utilisation de la clé API en clair - Pensez à la chiffrer !');
    }
} catch (error) {
    console.error('❌ Erreur lors du déchiffrement de la clé API:', error.message);
    process.exit(1);
}

const API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${API_KEY}`;

// Route pour servir l'index.html
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Route API sécurisée pour Gemini
app.post('/api/chat', async (req, res) => {
    try {
        const { message } = req.body;
        
        if (!message) {
            return res.status(400).json({ error: 'Message is required' });
        }

        if (!API_KEY) {
            return res.status(500).json({ error: 'API key not configured' });
        }

        // Appel à l'API Gemini
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                contents: [
                    {
                        parts: [{ text: message }],
                    },
                ],
            }),
        });

        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error?.message || 'API request failed');
        }

        res.json(data);
        
    } catch (error) {
        console.error('API Error:', error);
        res.status(500).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
