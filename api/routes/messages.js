const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM messages ORDER BY created_at DESC'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Failed to get messages', details: err.message });
  }
});


router.post('/', async (req, res) => {
  const { pseudo, text } = req.body;
  if (!pseudo || !text) {
    return res.status(400).json({ error: 'pseudo and text are required' });
  }

  try {
    const { rows } = await pool.query(
      'INSERT INTO messages (pseudo, text) VALUES ($1, $2) RETURNING *',
      [pseudo, text]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to add message', details: err.message });
  }
});

router.get('/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const { rows } = await pool.query('SELECT * FROM messages WHERE id = $1', [id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Message not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to get message', details: err.message });
  }
});


router.delete('/:id', async (req, res) => {
  try {
    const { rowCount } = await pool.query('DELETE FROM messages WHERE id = $1', [
      req.params.id,
    ]);
    if (rowCount === 0) {
      return res.status(404).json({ error: 'Message not found' });
    }
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete message', details: err.message });
  }
});

module.exports = router;
