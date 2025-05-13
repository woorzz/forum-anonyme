import { describe, it, expect } from 'vitest';
import { formatDate } from '../utils/format';

describe('formatDate', () => {
  it('formate correctement une date', () => {
    const input = '2025-05-13T12:30:00Z';
    const result = formatDate(input);
    expect(result).toMatch(/\d{2}\/\d{2}\/\d{4},? \d{2}:\d{2}/); 
  });
});
