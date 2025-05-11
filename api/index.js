const express = require('express');
const pool   = require('./db.js');

const app = express();
app.use(express.json());

app.get('/hello', async (_, res) => {
  try {
    res.json({ message: 'Hello World!' });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});


app.get('/test', async (_, res) => {
  try {
    const { rows } = await pool.query('SELECT 1 AS ok');
    res.json({ message: 'DB OK', ok: rows[0].ok });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

app.get('/testBDD', async (_, res) => {
  try {
    const { rows } = await pool.query('SELECT * from messages');
    res.json({ messages: rows });
  } catch (err) {
    res.status(500).json({ error: 'DB error', details: err.message });
  }
});

if (require.main === module) {
  app.listen(3000, () => console.log('API listening on 3000'));
}
module.exports = app;
