export const ROLES = [
  'Owner / Director',
  'Operations / Control room',
  'Dispatcher',
  'Other',
];

export function validatePilotForm({ name = '', company = '', role = '', phone = '', email = '' }) {
  if (!name.trim()) return 'Please enter your full name.';
  if (name.trim().length > 80) return 'That name is too long.';
  if (!company.trim()) return 'Please enter your company or organisation.';
  if (company.trim().length > 120) return 'That company name is too long.';
  if (!ROLES.includes(role)) return 'Please select your role.';

  const p = phone.trim();
  if (!p) return 'Please enter a phone or WhatsApp number.';
  const digits = p.replace(/\D/g, '');
  if (digits.length < 7 || digits.length > 15 || !/^\+?[\d\s\-()]+$/.test(p)) {
    return "That phone number doesn't look right — please check it.";
  }

  const e = email.trim();
  if (e && (e.length > 120 || !/^[\w.+-]+@[\w-]+(\.[\w-]+)+$/.test(e))) {
    return "That email address doesn't look right — please check it.";
  }
  return null;
}
