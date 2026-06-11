import './styles/base.css';
import './styles/sections.css';
import '@fontsource/inter/400.css';
import '@fontsource/inter/700.css';
import '@fontsource/inter/900.css';

import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { SplitText } from 'gsap/SplitText';
import Lenis from 'lenis';

import { detectWebGL, getQualityTier } from './three/quality.js';
import { initPilotForm } from './form.js';

gsap.registerPlugin(ScrollTrigger, SplitText);

// smooth scroll
const lenis = new Lenis();
lenis.on('scroll', ScrollTrigger.update);
gsap.ticker.add((t) => lenis.raf(t * 1000));
gsap.ticker.lagSmoothing(0);

// deep-link: scroll to hash on load
if (window.location.hash) {
  try {
    lenis.scrollTo(window.location.hash, { immediate: true });
  } catch (_) {}
}

// anchor links scroll smoothly
document.querySelectorAll('a[href^="#"]').forEach((a) => {
  a.addEventListener('click', (e) => {
    e.preventDefault();
    lenis.scrollTo(a.getAttribute('href'), { offset: 0 });
  });
});

initPilotForm();

const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const canvas = document.getElementById('gl');

function showPoster() {
  canvas.remove();
  document.getElementById('poster-fallback').hidden = false;
  document.body.classList.add('no-webgl');
}

if (detectWebGL() && !reduceMotion) {
  bootScene().catch(() => showPoster());
} else {
  showPoster();
}

async function bootScene() {
  const tier = getQualityTier({
    cores: navigator.hardwareConcurrency,
    width: window.innerWidth,
    dpr: window.devicePixelRatio,
  });
  const [{ initScene }, { buildNetwork }, { buildPulse }, { initJourney }] = await Promise.all([
    import('./three/scene.js'),
    import('./three/network.js'),
    import('./three/pulse.js'),
    import('./story/journey.js'),
  ]);
  const ctx = initScene(canvas, tier, showPoster);
  const net = buildNetwork(tier);
  ctx.scene.add(net.group);
  ctx.onFrame(net.update);

  const pulse = buildPulse();
  ctx.scene.add(pulse.group);

  initJourney({ camera: ctx.camera, pulse });

  // Set asynchronously after bootScene resolves — consumers must not read at module load.
  window.__gcmp = { ctx, tier };
}
