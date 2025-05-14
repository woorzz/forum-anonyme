jest.mock('../db', () => ({
  query: jest.fn()
}));

const request = require('supertest');
const app = require('../index');
const pool = require('../db');

describe('GET /hello', () => {
  it('return hello world', async () => {
    const res = await request(app).get('/hello');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ message: 'Hello World!' });
  });
});

describe('GET /messages', () => {
  it('should return messages from DB (mocked)', async () => {
    pool.query.mockResolvedValueOnce({
      rows: [
        { id: 1, pseudo: 'Marine', text: 'Coucou', created_at: new Date() },
        { id: 2, pseudo: 'Bob', text: 'Hello', created_at: new Date() }
      ]
    });

    const res = await request(app).get('/messages');
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(2);
  });
});

describe('POST /messages', () => {
  it('should add a message (mocked)', async () => {
    const message = {
      id: 3,
      pseudo: 'Testeur',
      text: 'Message test',
      created_at: new Date()
    };

    pool.query.mockResolvedValueOnce({ rows: [message] });

    const res = await request(app).post('/messages').send({
      pseudo: 'Testeur',
      text: 'Message test'
    });

    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({
      pseudo: 'Testeur',
      text: 'Message test'
    });
  });

  it('should return 400 if data is missing', async () => {
    const res = await request(app).post('/messages').send({});
    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });
});
