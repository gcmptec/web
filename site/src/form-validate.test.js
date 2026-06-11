import { describe, it, expect } from 'vitest';
import { validatePilotForm, ROLES } from './form-validate.js';

const valid = {
  name: 'Kabo Mosweu',
  company: 'Falcon Security',
  role: 'Owner / Director',
  phone: '+267 76 123 456',
  email: 'kabo@falcon.co.bw',
};

describe('validatePilotForm', () => {
  it('accepts a fully valid application', () => {
    expect(validatePilotForm(valid)).toBeNull();
  });

  it('accepts empty email (optional field)', () => {
    expect(validatePilotForm({ ...valid, email: '' })).toBeNull();
  });

  it('rejects empty name', () => {
    expect(validatePilotForm({ ...valid, name: '  ' })).toMatch(/full name/i);
  });

  it('rejects name over 80 chars', () => {
    expect(validatePilotForm({ ...valid, name: 'x'.repeat(81) })).toMatch(/too long/i);
  });

  it('rejects empty company', () => {
    expect(validatePilotForm({ ...valid, company: '' })).toMatch(/company/i);
  });

  it('rejects unknown role', () => {
    expect(validatePilotForm({ ...valid, role: 'Hacker' })).toMatch(/role/i);
  });

  it('rejects phone with too few digits', () => {
    expect(validatePilotForm({ ...valid, phone: '12345' })).toMatch(/phone/i);
  });

  it('rejects phone with letters', () => {
    expect(validatePilotForm({ ...valid, phone: 'call me 76436923' })).toMatch(/phone/i);
  });

  it('rejects phone with more than 15 digits', () => {
    expect(validatePilotForm({ ...valid, phone: '1234567890123456' })).toMatch(/phone/i);
  });

  it('rejects malformed email when provided', () => {
    expect(validatePilotForm({ ...valid, email: 'not-an-email' })).toMatch(/email/i);
  });

  it('exposes the four allowed roles', () => {
    expect(ROLES).toEqual([
      'Owner / Director',
      'Operations / Control room',
      'Dispatcher',
      'Other',
    ]);
  });
});
