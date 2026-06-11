import * as THREE from 'three';
import gsap from 'gsap';

export const PRESS_POINT = new THREE.Vector3(0, 0.4, 0);
export const DISPATCH_POINT = new THREE.Vector3(24, 0.4, -18);

function glowTexture() {
  const c = document.createElement('canvas');
  c.width = c.height = 64;
  const ctx = c.getContext('2d');
  const g = ctx.createRadialGradient(32, 32, 0, 32, 32, 32);
  g.addColorStop(0, 'rgba(0,255,148,1)');
  g.addColorStop(0.35, 'rgba(0,255,148,0.45)');
  g.addColorStop(1, 'rgba(0,255,148,0)');
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, 64, 64);
  return new THREE.CanvasTexture(c);
}

function glowSprite(tex, color, opacity, scale) {
  const s = new THREE.Sprite(
    new THREE.SpriteMaterial({ map: tex, color, opacity, transparent: true, depthWrite: false, blending: THREE.AdditiveBlending }),
  );
  s.scale.setScalar(scale);
  return s;
}

export function buildPulse() {
  const group = new THREE.Group();
  const tex = glowTexture();

  // the press point — heartbeat
  const core = glowSprite(tex, 0x00ff94, 1, 3);
  core.position.copy(PRESS_POINT);
  gsap.to(core.scale, { x: 4.2, y: 4.2, z: 4.2, duration: 0.9, yoyo: true, repeat: -1, ease: 'sine.inOut' });
  group.add(core);

  // the dispatcher node — dim until the signal arrives
  const disp = glowSprite(tex, 0x00ff94, 0.4, 2.2);
  disp.position.copy(DISPATCH_POINT);
  group.add(disp);

  // expanding press rings
  const rings = [];
  for (let i = 0; i < 3; i++) {
    const ring = new THREE.Mesh(
      new THREE.RingGeometry(0.96, 1, 64),
      new THREE.MeshBasicMaterial({ color: 0x00ff94, transparent: true, opacity: 0, side: THREE.DoubleSide, depthWrite: false }),
    );
    ring.rotation.x = -Math.PI / 2;
    ring.position.copy(PRESS_POINT);
    group.add(ring);
    rings.push(ring);
  }

  // the travelling signal
  const signal = glowSprite(tex, 0x9bffd6, 0, 2.4);
  group.add(signal);
  const path = new THREE.CatmullRomCurve3([
    PRESS_POINT.clone(),
    new THREE.Vector3(6, 5, -4),
    new THREE.Vector3(15, 7, -12),
    DISPATCH_POINT.clone(),
  ]);

  let arrived = false;

  function firePress() {
    rings.forEach((ring, i) => {
      gsap.fromTo(ring.scale, { x: 1, y: 1, z: 1 }, { x: 38, y: 38, z: 38, duration: 2.4, delay: i * 0.55, repeat: 3, ease: 'power1.out' });
      gsap.fromTo(ring.material, { opacity: 0.7 }, { opacity: 0, duration: 2.4, delay: i * 0.55, repeat: 3, ease: 'power1.out' });
    });
  }

  function setSignalProgress(p) {
    signal.material.opacity = p > 0.01 && p < 0.99 ? 1 : 0;
    path.getPoint(Math.min(Math.max(p, 0), 1), signal.position);
    if (p >= 0.99 && !arrived) {
      arrived = true;
      gsap.killTweensOf(disp.material);
      gsap.killTweensOf(disp.scale);
      gsap.to(disp.material, { opacity: 1, duration: 0.5 });
      gsap.to(disp.scale, { x: 4, y: 4, z: 4, duration: 0.5, ease: 'back.out(3)' });
    }
    if (p < 0.9) {
      arrived = false;
      gsap.killTweensOf(disp.material);
      gsap.killTweensOf(disp.scale);
      gsap.to(disp.material, { opacity: 0.4, duration: 0.3 });
      gsap.to(disp.scale, { x: 2.2, y: 2.2, z: 2.2, duration: 0.3 });
    }
  }

  return { group, firePress, setSignalProgress };
}
