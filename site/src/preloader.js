export function initPreloader() {
  const el = document.getElementById('preloader');
  if (!el) return;
  // sessionStorage throws when all cookies/storage are blocked — never let
  // that take down the whole module (this runs first in main.js)
  let seen = false;
  try {
    seen = !!sessionStorage.getItem('gcmp-seen');
    sessionStorage.setItem('gcmp-seen', '1');
  } catch {
    /* storage unavailable: treat as first visit */
  }
  if (seen) {
    el.remove();
    return;
  }
  const done = () => {
    el.classList.add('done');
    setTimeout(() => el.remove(), 700);
  };
  // hide on load, min 500ms so it never flashes, max 2.5s so it never hangs
  const minDelay = new Promise((r) => setTimeout(r, 500));
  const loaded = new Promise((r) => {
    if (document.readyState === 'complete') r();
    else window.addEventListener('load', r, { once: true });
  });
  const maxDelay = new Promise((r) => setTimeout(r, 2500));
  Promise.race([Promise.all([minDelay, loaded]), maxDelay]).then(done);
}
