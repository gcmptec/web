export function initPreloader() {
  const el = document.getElementById('preloader');
  if (!el) return;
  if (sessionStorage.getItem('gcmp-seen')) {
    el.remove();
    return;
  }
  sessionStorage.setItem('gcmp-seen', '1');
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
