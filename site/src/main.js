/**
 * main.js — critical-path bootstrap only
 *
 * Only the minimum needed before first paint lives here:
 *   • preloader (must run first so the overlay appears immediately)
 *   • CSS + fonts (Vite inlines/preloads these)
 *   • pilot-form event binding (tiny; no GSAP dependency)
 *
 * Everything GSAP / Lenis / Three.js is in animate.js, loaded via a dynamic
 * import scheduled with requestIdleCallback.  This moves ~130 KB of JS
 * evaluation out of the TBT window while the preloader covers the page.
 */

import { initPreloader } from './preloader.js';

initPreloader();

import './styles/base.css';
import './styles/sections.css';
import '@fontsource/inter/400.css';
import '@fontsource/inter/700.css';
import '@fontsource/inter/900.css';

import { initPilotForm } from './form.js';

initPilotForm();

// ── deferred animation layer ────────────────────────────────────────────────
// The preloader covers the viewport for at least 500 ms, so scheduling the
// animation layer idle gives a safe window: GSAP + Lenis + ScrollTrigger +
// Three.js all parse and evaluate after the browser has painted the shell.
//
// requestIdleCallback fallback: setTimeout 1500 ms — on browsers without rIC
// (e.g. Safari < 16.4) we still defer long enough to be past FCP.
// The {timeout: 2500} cap matches the preloader's own max-delay, so Three.js
// never waits longer than the preloader already keeps the page covered.

const scheduleIdle = typeof requestIdleCallback === 'function'
  ? (cb) => requestIdleCallback(cb, { timeout: 2500 })
  : (cb) => setTimeout(cb, 1500);

scheduleIdle(() => {
  import('./animate.js').then(({ initAnimations }) => initAnimations());
});
