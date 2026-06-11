# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

The GCMP Security marketing site — a hand-built one-page scroll experience
("Follow the Signal"). Source lives in `site/` (Vite + vanilla JS + GSAP
ScrollTrigger/SplitText + Three.js + Lenis). The repo **root** holds the built
output, because GitHub Pages serves this branch (`sub`) from the root at
https://gcmptec.github.io/web/.

## Commands (run from site/)

```bash
npm install        # install dependencies
npm run dev        # dev server at http://127.0.0.1:5173/web/
npm run build      # production build → site/dist/
npm run preview    # serve the build at http://127.0.0.1:4173/web/
npm test           # vitest (form validation, quality tiering)
```

## Architecture

- `site/index.html` — all copy, as real HTML (SEO/accessibility baseline; page must read with JS off)
- `site/src/main.js` — boot: preloader, Lenis+ScrollTrigger, scene (lazy), form
- `site/src/three/` — scene.js (renderer/loop), network.js (node field), pulse.js (press/signal), quality.js (device tiers, **unit-tested**)
- `site/src/story/` — journey.js (scroll-scrubbed camera), chapters.js (DOM animations, gsap.matchMedia reduced-motion aware)
- `site/src/form-validate.js` (**unit-tested**) + form.js + firebase.js (lazy chunk) — pilot form → Firestore `pilot_applications` in project `gcmpvoice`. Server-side rules are deployed from the app repo — see `docs/SECURITY-NOTES.md`.

## Deploy

```powershell
cd site; npm run build
robocopy site\dist . /E     # from repo root
git add -A; git commit; git push origin sub
```

## Gotchas

- Base href is `/web/` (set in vite.config.js) — never hardcode absolute asset paths.
- Pinned sections use CSS `position: sticky`, not ScrollTrigger pins.
- Fallback ladder: no WebGL → poster + CSS pulse; prefers-reduced-motion → static page (body.no-js bar widths).
- All lib files are UTF-8; if mojibake (â€, â†) ever appears, fix with ftfy wholesale, not by hand.
