const express = require('express');
const cors = require('cors');

const tripsRouter = require('./routes/trips');
const questsRouter = require('./routes/quests');

const app = express();

app.use(cors({ origin: process.env.ALLOWED_ORIGIN || '*' }));
app.use(express.json());

app.get('/health', (_req, res) => res.json({ status: 'ok' }));

app.use('/api/trips', tripsRouter);
app.use('/api/quests', questsRouter);

module.exports = app;
