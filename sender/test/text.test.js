import { describe, it, expect } from 'vitest';
import { capitalize } from '../utils/text';

describe('capitalize', () => {
  it('met la première lettre en majuscule', () => {
    expect(capitalize('marine')).toBe('Marine');
    expect(capitalize('')).toBe('');
  });
});
