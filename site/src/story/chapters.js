import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { SplitText } from 'gsap/SplitText';

const CLASS_RESULTS = {
  medical: 4, fire: 2, crime: 96, accident: 5, disaster: 1, domestic: 9, unclear: 3,
};

export function initChapters() {
  buildWave();
  const mm = gsap.matchMedia();
  mm.add('(prefers-reduced-motion: no-preference)', () => {
    hero();
    captured();
    understood();
    routed();
    resolved();
    reveals();
  });
  mm.add('(prefers-reduced-motion: reduce)', () => {
    document.body.classList.add('no-js');
  });
  // reduced motion: CSS baseline is fully readable; no animations registered.
}

function buildWave() {
  const wave = document.querySelector('#captured .wave');
  if (!wave) return;
  for (let i = 0; i < 44; i++) wave.appendChild(document.createElement('span'));
}

function chapterIntro(sel) {
  return gsap.timeline({
    scrollTrigger: {
      trigger: `${sel} .pin-inner`,
      start: 'top 35%',
      toggleActions: 'play none none reverse',
    },
  }).from(`${sel} .chapter-copy > *`, {
    y: 36, opacity: 0, stagger: 0.1, duration: 0.6, ease: 'power3.out',
  });
}

function hero() {
  gsap.to('#hero .hero-inner', {
    opacity: 0, y: -90, ease: 'none',
    scrollTrigger: { trigger: '#hero', start: 'top top', end: '60% top', scrub: true },
  });
  document.fonts.ready.then(() => {
    const split = new SplitText('#hero h1', { type: 'words' });
    gsap.from(split.words, {
      yPercent: 110, opacity: 0, stagger: 0.06, duration: 0.9, ease: 'power3.out', delay: 0.25,
    });
    gsap.from('#hero .kicker, #hero .hero-sub, #hero .scroll-cue', {
      opacity: 0, y: 18, stagger: 0.12, duration: 0.7, delay: 0.9,
    });
  });
}

function captured() {
  chapterIntro('#captured')
    .from('#captured .wave span', {
      scaleY: 0.08, opacity: 0.2, duration: 0.4,
      stagger: { each: 0.015, from: 'center' },
    }, '-=0.3')
    .from('#captured .coords', { scale: 0.85, opacity: 0, duration: 0.4, ease: 'back.out(2)' });

  // live waveform while the chapter is on screen
  gsap.to('#captured .wave span', {
    scaleY: () => gsap.utils.random(0.15, 1),
    duration: 0.22,
    repeatRefresh: true,
    ease: 'sine.inOut',
    stagger: { each: 0.02, repeat: -1 },
    scrollTrigger: {
      trigger: '#captured',
      start: 'top bottom',
      end: 'bottom top',
      toggleActions: 'play pause resume pause',
    },
  });
}

function understood() {
  const tl = chapterIntro('#understood');
  tl.from('#understood .classes li', { y: 24, opacity: 0, stagger: 0.07, duration: 0.45 });
  for (const [cls, pct] of Object.entries(CLASS_RESULTS)) {
    tl.to(`#understood li[data-class="${cls}"] .fill`, { width: `${pct}%`, duration: 1.1, ease: 'power2.out' }, 'race');
    tl.to(`#understood li[data-class="${cls}"] .pct`, { textContent: pct, snap: { textContent: 1 }, duration: 1.1 }, 'race');
  }
  const list = document.querySelector('#understood .classes');
  if (list) {
    tl.to({}, {
      duration: 0.01,
      onComplete: () => list.classList.add('locked-state'),
      onReverseComplete: () => list.classList.remove('locked-state'),
    }, '+=0.15');
  }
}

function routed() {
  chapterIntro('#routed')
    .from('#routed .console', {
      y: 60, opacity: 0, rotateX: 8, transformPerspective: 600, duration: 0.7, ease: 'power3.out',
    }, '-=0.2')
    .from('#routed .console .row', { x: -18, opacity: 0, stagger: 0.09, duration: 0.4 })
    .fromTo('#routed .dispatch-btn',
      { boxShadow: '0 0 0 0 rgba(0,255,148,0.5)' },
      { boxShadow: '0 0 0 18px rgba(0,255,148,0)', duration: 0.9, repeat: 2, clearProps: 'boxShadow' });
}

function resolved() {
  chapterIntro('#resolved')
    .from('#resolved .stamps li', { x: -30, opacity: 0, stagger: 0.18, ease: 'power3.out', duration: 0.5 }, '-=0.2')
    .from('#resolved .resolved-kicker', { opacity: 0, y: 16, duration: 0.5 });
}

function reveals() {
  gsap.utils.toArray('[data-reveal]').forEach((el) => {
    gsap.from(el, {
      y: 40, opacity: 0, duration: 0.8, ease: 'power3.out',
      scrollTrigger: { trigger: el, start: 'top 82%', toggleActions: 'play none none reverse' },
    });
  });
}
