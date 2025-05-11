const express = require('express');
const app = express();
app.use(express.json());


app.get('/test', async (_, res) => {
  res.json({ message: 'Hello World!' });
});

app.listen(3000, () => console.log('API listening on 3000'));
