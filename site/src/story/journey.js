import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

// camera keyframes per beat: position (x,y,z) and lookAt target (tx,ty,tz)
const KEYS = [
  { x: 0, y: 40, z: 60, tx: 0, ty: 0, tz: 0 },    // hero — wide over the grid
  { x: 8, y: 12, z: 20, tx: 0, ty: 0, tz: 0 },    // captured — close on the signal
  { x: 0, y: 28, z: 6, tx: 0, ty: 0, tz: 0 },     // understood — overhead
  { x: 18, y: 10, z: 4, tx: 24, ty: 0, tz: -18 }, // routed — toward the dispatcher node
  { x: 0, y: 34, z: 46, tx: 12, ty: 0, tz: -9 },  // resolved — pull back over both
];

export function initJourney({ camera, pulse }) {
  const cam = { ...KEYS[0] };
  const apply = () => {
    camera.position.set(cam.x, cam.y, cam.z);
    camera.lookAt(cam.tx, cam.ty, cam.tz);
  };
  apply();

  const mm = gsap.matchMedia();
  mm.add('(prefers-reduced-motion: no-preference)', () => {
    const tl = gsap.timeline({
      defaults: { ease: 'none', duration: 1, onUpdate: apply },
      scrollTrigger: {
        trigger: '#story',
        start: 'top bottom',
        end: 'bottom bottom',
        scrub: 0.6,
      },
    });
    for (const k of KEYS.slice(1)) tl.to(cam, { ...k });

    // the press fires once, as the hero scroll begins
    ScrollTrigger.create({
      trigger: '#hero',
      start: '2% top',
      once: true,
      onEnter: () => pulse.firePress(),
    });

    // the signal travels press → dispatcher across understood → routed
    const sig = { p: 0 };
    gsap.to(sig, {
      p: 1,
      ease: 'none',
      onUpdate: () => pulse.setSignalProgress(sig.p),
      scrollTrigger: {
        trigger: '#understood',
        start: 'top bottom',
        endTrigger: '#routed',
        end: 'bottom center',
        scrub: 0.5,
      },
    });
  });
}
