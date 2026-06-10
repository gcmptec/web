# "Follow the Signal" — GCMP Landing Page Redesign

**Date:** 2026-06-10
**Status:** Approved
**Replaces:** Flutter web landing page (retired from working tree in this project; recoverable from git history)

## Summary

Rebuild the GCMP Security marketing site as a hand-built HTML/CSS/JS one-pager using
GSAP (ScrollTrigger + SplitText), Three.js, and Lenis. The page tells one story —
a signal's journey from panic-button press to resolution — then pivots to the B2B
pitch and the pilot application form. Deployed to the same GitHub Pages URL
(https://gcmptec.github.io/web/) from the `sub` branch root, same as today.

**Audience:** security companies (B2B). **Conversion:** pilot applications.
**Bar:** award-quality visual experience that still loads fast on a mid-range
Android on Botswana mobile data.

## Decisions made (with user)

1. **Architecture:** retire Flutter web; rebuild in plain HTML/JS. GSAP/Three.js
   cannot run inside Flutter's canvas; every award-tier site is DOM-based.
2. **Creative direction:** A+B combo — Three.js "Signal Pulse" hero + GSAP
   scroll-told story.
3. **Content:** full rework — new narrative, new sections, new copy.
4. **Audience:** security companies; pilot CTA primary.
5. **Story arc:** "Follow the Signal" (ride the signal press → resolution, then
   B2B pivot).
6. **Repo plan:** new `site/` directory; Flutter source removed from working tree;
   same deploy pipeline (build output copied to repo root on `sub`).

## Narrative & page structure

One page, eight beats. A single persistent Three.js canvas (night network) sits
behind beats 1–5; scroll progress drives camera and scene state. All copy is real
HTML text layered above the canvas — selectable, SEO-visible, accessible.

| # | Beat | Visual | Copy beat |
|---|------|--------|-----------|
| 0 | Preloader | Eye/sensor logo mark draws in while Three.js assets load. <2s, skipped on repeat visits (sessionStorage flag). | — |
| 1 | Hero — The Press *(pinned)* | Dark particle grid suggesting Gaborone at night. Glowing green core pulses. First scroll = the press: rings ripple outward, camera dives after the signal. Minimal nav: logo + "Apply for pilot". | "When something goes wrong, the last thing you should need is words." / *Signal first. Explain later.* |
| 2 | Captured | Signal resolves into a data object: live audio waveform + GPS coordinates materialize. | "One press. Ten seconds of audio, exact location. No call. No questions." |
| 3 | Understood *(classifier hero moment)* | Waveform feeds the classifier. Seven class chips orbit (medical, fire, crime, accident, disaster, domestic, unclear); probability bars race; **CRIME** locks in green. | "Machine learning reads the situation and decides what kind of help is needed — in seconds, not minutes." |
| 4 | Routed | Classified signal streaks across the network to a dispatcher node; dispatcher console card lights up: class, location, audio, one-tap dispatch. | "The right team. The first time." |
| 5 | Resolved | Responder marker converges; timeline stamps itself: 0:00 press → 0:04 classified → 0:07 on dispatcher screen. Pulse settles. | — |
| 6 | The Pivot | Hard tonal cut; background shifts to surface-dark. B2B pitch: partner deliverables (dispatch console, responder app, discreet tier), commercial terms (partner pays BWP 15–25/user/mo, sells at BWP 50–80), proof points (patent filed, classifier live in production, E2E verified). Honest pre-revenue, first-mover pilot framing. | "Now imagine being the company that catches it." |
| 7 | Pilot CTA + form | Form: name, company, role, phone, email → Firestore `pilot_applications`. Same field set and client validation as the hardened Flutter form. | "Free 60-day pilot for the first 3 partners." |
| 8 | FAQ + footer | Compact accordion rewritten for B2B objections (pricing, coverage, integration, data handling). Footer: contact email, LinkedIn (linkedin.com/in/didintle-motshubi-41944716a), © GCMP Security (Pty) Ltd. | — |

**Copy tone:** terse, second person, confident. One idea per beat, lines written
for scroll rhythm. Final copy drafted at implementation time and reviewed by
Didintle before deploy.

## Tech architecture

### Stack (all free, no licenses)

- **Vite** — dev server + build. Plain JS modules (ES2020+), no framework.
- **GSAP ≥3.13** with **ScrollTrigger** and **SplitText** (all GSAP plugins free
  as of 2025).
- **Three.js** — one renderer, one canvas, one scene graph for the whole page.
  No per-section scenes.
- **Lenis** — smooth scroll, driven by GSAP's ticker; ScrollTrigger reads Lenis
  scroll position (standard `lenis.on('scroll', ScrollTrigger.update)` pairing).
- **Firebase JS SDK (modular)** — Firestore only; project `gcmpvoice`, collection
  `pilot_applications`. Tree-shaken import (~40KB gzip).
- **Inter** — self-hosted woff2 subset (latin, weights 400/700/900). No external
  font request.

### Brand

Background `#0E0E1C`, surface `#13131F`, card `#16162A`, border `#1F1F35`,
green `#00FF94`, text `#E8F0FF` / `#7D92B8` / `#4A5E7A`. Logo: existing
eye/sensor mark assets. Tagline: "Signal first. Explain later."

### File structure

```
site/
  index.html          ← all copy lives here as real HTML
  vite.config.js      ← base: '/web/'
  package.json
  src/
    main.js           ← boot: Lenis + ScrollTrigger registration + scene init
    three/
      scene.js        ← renderer, camera, RAF loop, visibility pause
      network.js      ← node grid + connection lines
      pulse.js        ← press pulse, signal particle, ring shaders
      quality.js      ← device tiering (DPR cap, particle counts)
    story/
      chapter-*.js    ← one module per beat: ScrollTrigger timeline + scene cues
    form.js           ← validation + Firestore submit + fallbacks
    styles/
      base.css        ← reset, tokens, typography
      sections.css    ← per-beat layout
  public/
    logo.svg / png, og-image, favicons, demo poster, .nojekyll
```

### Deploy

`vite build` (base `/web/`) → copy `site/dist/*` to repo root on `sub` → push →
GitHub Pages serves it. Identical pipeline shape to the current Flutter flow,
zero URL/DNS change. The same commit that first deploys the new site removes
Flutter source (`lib/`, `web/`, `test/`, `pubspec.*`, `analysis_options.yaml`)
and stale Flutter build artifacts from the root.

### Performance budget (mid-range Android is the bar)

- **JS ≤ 300KB gzip total** (Three ~155 + GSAP ~75 + Firebase ~40 + app code).
  Current Flutter site ships ~1.5MB CanvasKit before first paint — this is a 5× cut.
- DPR capped at 2 desktop / 1.5 mobile; particle counts tiered by
  `hardwareConcurrency` + viewport; renderer paused when canvas off-screen or
  tab hidden.
- Fonts preloaded; hero renders on first paint without waiting for Firebase
  (form module lazy-loaded on scroll approach).
- Lighthouse mobile performance ≥ 90.

### Fallback ladder

1. **WebGL unavailable** → poster image + CSS pulse animation in the hero; the
   GSAP scroll story (DOM-only) still runs fully.
2. **`prefers-reduced-motion`** → no pinning, no parallax; simple opacity fades;
   static scene frame. Page is fully readable top-to-bottom.
3. **WebGL context lost** → one rebuild attempt, then fall to (1).

### Error handling

- Form: client validation mirroring `docs/SECURITY-NOTES.md` field rules
  (name/company/role/phone required; phone 7–15 digits; optional well-formed
  email; max lengths 80/120/20/120). Double-submit guard. Firestore failure →
  inline error + `mailto:tsotlhedidintle@gmail.com` fallback link.
- No analytics, no cookies, no consent banner needed.
- Firestore security boundary remains the server-side rules (deployed from the
  app repo — see `docs/SECURITY-NOTES.md`); the public Firebase web config is
  expected and fine.

### SEO / meta

Real HTML headings and copy (major upgrade over canvas-rendered Flutter).
Title/description/OG/Twitter tags, OG image, canonical URL, favicon set.

## Testing & verification

1. **Visual loop:** existing Playwright scroll-capture scripts (desktop +
   mobile) screenshot every beat; inspect before deploy.
2. **Lighthouse:** mobile emulation, performance ≥ 90, accessibility ≥ 90.
3. **Form E2E:** one real submission against Firestore, verify doc shape,
   delete test doc.
4. **Fallback passes:** forced reduced-motion and WebGL-disabled runs.
5. **Post-deploy:** live URL smoke check (hero renders, form loads, assets 200).

## Out of scope

- Custom domain migration (gcmpsecurity.com) — separate task.
- Firestore rules deployment — owned by the app repo (documented in
  `docs/SECURITY-NOTES.md`).
- Blog/news, multi-page routes, CMS, analytics.
- Demo video section — the old site's video embed is dropped; the story beats
  replace it. Can be added later as a beat-6 inset if wanted.
