const express = require('express');
const cors = require('cors');
const app = express();
const messageRoutes = require('./routes/messages');

app.use(cors());
app.use(express.json());

app.use('/messages', messageRoutes);

app.get('/hello', (_, res) => res.json({ message: 'Hello World!' }));
app.get('/', (_, res) => res.json({ message: 'API is running' }));


if (require.main === module) {
  app.listen(3000, () => console.log('API listening on 3000'));
}

module.exports = app;
