const request = require('supertest');
const app = require('../index');

describe('GET /hello', () => {
  it('return hello world', async () => {
    const res = await request(app).get('/hello');
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ message: 'Hello World!' });
  });
});
