import { validatePilotForm } from './form-validate.js';

// Google Apps Script web app (site/apps-script/pilot-intake.gs): emails + logs to a Sheet.
const ENDPOINT = 'https://script.google.com/macros/s/AKfycbynyuN3byxH5oKT85jeRGrSoCt_d7VD-A2B03ncAcp4dPidme_ZK9M9O8RQ_kQSqFCn/exec';

export function initPilotForm() {
  const form = document.getElementById('pilot-form');
  if (!form) return;
  const errBox = document.getElementById('form-error');
  const okBox = document.getElementById('form-success');
  const btn = form.querySelector('button[type="submit"]');
  let busy = false;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (busy) return;

    const data = Object.fromEntries(new FormData(form));
    const fields = {
      name: (data.name || '').trim(),
      company: (data.company || '').trim(),
      role: data.role || '',
      phone: (data.phone || '').trim(),
      email: (data.email || '').trim(),
    };

    const err = validatePilotForm(fields);
    if (err) {
      errBox.textContent = err;
      errBox.hidden = false;
      return;
    }
    errBox.hidden = true;
    busy = true;
    btn.disabled = true;
    btn.textContent = 'Sending…';

    try {
      // Simple form-encoded POST (no CORS preflight); the honeypot rides along.
      const res = await fetch(ENDPOINT, {
        method: 'POST',
        body: new URLSearchParams({ ...fields, website: data.website || '' }),
      });
      if (!(await res.json()).ok) throw new Error('rejected');
      form.reset();
      form.hidden = true;
      okBox.hidden = false;
    } catch {
      errBox.textContent = 'Something went wrong sending your application. Email us instead: ';
      const link = document.createElement('a');
      link.href = 'mailto:tsotlhedidintle@gmail.com';
      link.textContent = 'tsotlhedidintle@gmail.com';
      errBox.append(link);
      errBox.hidden = false;
      busy = false;
      btn.disabled = false;
      btn.textContent = 'Apply for the pilot';
    }
  });
}
