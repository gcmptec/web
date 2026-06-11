import './styles/base.css';
import './styles/sections.css';
import '@fontsource/inter/400.css';
import '@fontsource/inter/700.css';
import '@fontsource/inter/900.css';

import { detectWebGL, getQualityTier } from './three/quality.js';
import { initPilotForm } from './form.js';

initPilotForm();

const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const canvas = document.getElementById('gl');

function showPoster() {
  canvas.remove();
  document.getElementById('poster-fallback').hidden = false;
  document.body.classList.add('no-webgl');
}

if (detectWebGL() && !reduceMotion) {
  bootScene();
} else {
  showPoster();
}

async function bootScene() {
  const tier = getQualityTier({
    cores: navigator.hardwareConcurrency,
    width: window.innerWidth,
    dpr: window.devicePixelRatio,
  });
  const [{ initScene }, { buildNetwork }] = await Promise.all([
    import('./three/scene.js'),
    import('./three/network.js'),
  ]);
  const ctx = initScene(canvas, tier, showPoster);
  const net = buildNetwork(tier);
  ctx.scene.add(net.group);
  ctx.onFrame(net.update);
  ctx.camera.position.set(0, 40, 60);
  ctx.camera.lookAt(0, 0, 0);
  window.__gcmp = { ctx, tier }; // journey hooks in next task
}
