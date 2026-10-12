/**
 * Pilot-form intake: emails each application and logs it to the Google Sheet below.
 *
 * Setup (once): a standalone project at script.google.com, under the account that owns the
 * sheet below (a sheet-bound script breaks when several Google accounts are signed in).
 *   1. New project -> replace Code.gs with this file -> Save
 *   2. Deploy -> New deployment -> type "Web app"
 *        Execute as: Me    Who has access: Anyone
 *   3. Authorize, copy the Web app URL (ends in /exec) into ENDPOINT in site/src/form.js
 * Editing this file later: Deploy -> Manage deployments -> edit -> New version (URL stays the same).
 */

const NOTIFY_TO = 'tsotlhedidintle@gmail.com';
const SHEET_ID = '1KtIIBiquymPOmiL_UMYCImqfTo0q1J7LMSmfIPiDfsM'; // "GCMP Pilot Applications"

// Keep identical to ROLES in site/src/form-validate.js (form-validate.test.js checks this).
const ROLES = ['Owner / Director', 'Operations / Control room', 'Dispatcher', 'Other'];

const LIMITS = { name: 80, company: 120, role: 40, phone: 20, email: 120 };

function doPost(e) {
  const p = (e && e.parameter) || {};
  // Honeypot: real visitors never see or fill "website"; bots do. Pretend success.
  if (p.website) return json_({ ok: true });

  const f = {};
  for (const k in LIMITS) f[k] = String(p[k] || '').trim().slice(0, LIMITS[k]);
  if (!f.name || !f.company || !f.phone || ROLES.indexOf(f.role) === -1) {
    return json_({ ok: false, error: 'invalid' });
  }

  // Leading = + - @ would run as a formula when the sheet is opened.
  const cell = (v) => (/^[=+\-@]/.test(v) ? "'" + v : v);
  SpreadsheetApp.openById(SHEET_ID).getSheets()[0]
    .appendRow([new Date(), f.name, f.company, f.role, f.phone, f.email].map(cell));

  const body = [
    'Name: ' + f.name,
    'Company: ' + f.company,
    'Role: ' + f.role,
    'Phone / WhatsApp: ' + f.phone,
    'Email: ' + (f.email || '(none)'),
  ].join('\n');
  const opts = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(f.email) ? { replyTo: f.email } : {};
  MailApp.sendEmail(NOTIFY_TO, 'GCMP pilot application: ' + f.company, body, opts);

  return json_({ ok: true });
}

function json_(o) {
  return ContentService.createTextOutput(JSON.stringify(o)).setMimeType(ContentService.MimeType.JSON);
}
