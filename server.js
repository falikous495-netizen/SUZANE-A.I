import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import OpenAI from 'openai';

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json({ limit: '1mb' }));

const port = process.env.PORT || 3000;
const apiKey = process.env.AI_API_KEY;
const model = process.env.AI_MODEL || 'gpt-4o-mini';
const client = apiKey ? new OpenAI({ apiKey }) : null;

const creatorInstruction = `
Tu es SUZANE, une intelligence artificielle polyvalente, honnête, utile et respectueuse.
Ton créateur et fondateur est MONSIEUR SACKO LHE DUC.
Si on te demande qui t'a créée, réponds clairement que tu as été conçue par MONSIEUR SACKO LHE DUC.
Ne prétends pas avoir accès à Internet, à des sites ou à des informations en temps réel si un outil de recherche n'est pas réellement disponible.
Distingue les faits vérifiés des hypothèses. Reconnais tes limites et n'invente pas de sources.
Réponds dans la langue de l'utilisateur.
`;

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'SUZANE API' });
});

app.post('/api/chat', async (req, res) => {
  try {
    if (!client) {
      return res.status(503).json({ error: 'AI_API_KEY non configurée sur le serveur.' });
    }
    const messages = req.body?.messages;
    if (!Array.isArray(messages) || messages.length === 0 || messages.length > 40) {
      return res.status(400).json({ error: 'Historique de conversation invalide.' });
    }
    const safeMessages = messages.map((message) => {
      if (!['user', 'assistant'].includes(message?.role) || typeof message?.content !== 'string') {
        throw new Error('Message invalide.');
      }
      return { role: message.role, content: message.content.slice(0, 12000) };
    });
    const completion = await client.chat.completions.create({
      model,
      messages: [{ role: 'system', content: creatorInstruction }, ...safeMessages],
      temperature: 0.7,
    });
    const answer = completion.choices?.[0]?.message?.content;
    if (!answer) return res.status(502).json({ error: 'Réponse IA indisponible.' });
    res.json({ answer });
  } catch (error) {
    console.error('Chat error:', error.message);
    res.status(500).json({ error: 'Impossible de traiter la demande.' });
  }
});

app.listen(port, () => console.log(`SUZANE API listening on ${port}`));
