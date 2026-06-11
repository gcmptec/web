import { validatePilotForm } from './form-validate.js';

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
      const { submitPilotApplication } = await import('./firebase.js');
      const id = await submitPilotApplication(fields);
      if (import.meta.env.DEV) console.info('pilot application id:', id);
      form.reset();
      form.hidden = true;
      okBox.hidden = false;
    } catch {
      errBox.innerHTML =
        'Something went wrong sending your application. Email us instead: ' +
        '<a href="mailto:tsotlhedidintle@gmail.com">tsotlhedidintle@gmail.com</a>';
      errBox.hidden = false;
      busy = false;
      btn.disabled = false;
      btn.textContent = 'Apply for the pilot';
    }
  });
}
