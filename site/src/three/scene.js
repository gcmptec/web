import * as THREE from 'three';

export function initScene(canvas, tier, onFatalLoss) {
  const renderer = new THREE.WebGLRenderer({
    canvas,
    antialias: false,
    powerPreference: 'high-performance',
  });
  renderer.setClearColor(0x0e0e1c, 1);

  const scene = new THREE.Scene();
  scene.fog = new THREE.Fog(0x0e0e1c, 60, 150);

  const camera = new THREE.PerspectiveCamera(55, 1, 0.1, 320);

  const setSize = () => {
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, tier.dprCap));
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
  };
  window.addEventListener('resize', setSize);
  setSize();

  const updatables = [];
  let running = true;
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      running = false;
      clock.stop();
    } else {
      clock.start();
      running = true;
    }
  });

  const clock = new THREE.Clock();
  const loopFn = () => {
    if (!running) return;
    const t = clock.getElapsedTime();
    for (const fn of updatables) fn(t);
    renderer.render(scene, camera);
  };
  renderer.setAnimationLoop(loopFn);

  // Context loss: allow one automatic restore; if it doesn't come back, bail to poster.
  let lossTimer = null;
  let fatalFired = false;
  canvas.addEventListener('webglcontextlost', (e) => {
    e.preventDefault();
    running = false;
    clock.stop();
    lossTimer = setTimeout(() => {
      if (!fatalFired) { fatalFired = true; if (onFatalLoss) onFatalLoss(); }
    }, 3000);
  });
  canvas.addEventListener('webglcontextrestored', () => {
    clearTimeout(lossTimer);
    clock.start();
    running = true;
    setSize();
    renderer.setAnimationLoop(loopFn);
  });

  return {
    scene,
    camera,
    renderer,
    onFrame: (fn) => updatables.push(fn),
  };
}
