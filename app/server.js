const express = require('express');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
const { Pool } = require('pg');

const app = express();
app.disable('x-powered-by'); // suppress X-Powered-By: Express header

const PORT = Number.parseInt(process.env.PORT || '3000', 10);
const REGION = process.env.AWS_REGION || 'us-east-1';

let pool = null;

async function initDb() {
  const secretArn = process.env.DB_SECRET_ARN;
  if (!secretArn) return;

  const client = new SecretsManagerClient({ region: REGION });
  const { SecretString } = await client.send(
    new GetSecretValueCommand({ SecretId: secretArn })
  );
  const secret = JSON.parse(SecretString);

  pool = new Pool({
    host:     secret.host,
    port:     Number.parseInt(secret.port, 10),
    database: secret.dbname,
    user:     secret.username,
    password: secret.password,
    ssl:      { rejectUnauthorized: false },
    max:      10,
  });
}

app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.get('/', (_req, res) => {
  res.json({
    message:     'AWS 3-Tier Terraform App Running',
    environment: process.env.ENVIRONMENT || 'local',
    database:    pool ? 'connected' : 'not configured',
  });
});

app.get('/db', async (_req, res) => {
  if (!pool) {
    return res.status(503).json({ error: 'Database not configured' });
  }
  try {
    const result = await pool.query('SELECT NOW() AS current_time');
    res.json({ database: 'connected', time: result.rows[0].current_time });
  } catch (err) {
    res.status(500).json({ error: 'Database query failed', detail: err.message });
  }
});

initDb().catch(err =>
  console.error('DB init failed (non-fatal, app will start without DB):', err.message)
);

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
