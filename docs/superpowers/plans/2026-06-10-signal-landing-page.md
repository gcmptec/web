# "Follow the Signal" Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Flutter web landing page with a hand-built Vite + GSAP + Three.js one-pager telling the "Follow the Signal" story, deployed to the same GitHub Pages URL.

**Architecture:** New Vite project in `site/`. One persistent Three.js canvas (fixed, behind content) renders a night network; scroll position (Lenis + ScrollTrigger) drives the camera and a signal pulse through beats 1–5. All copy is real HTML. Pinning uses CSS `position: sticky` (no ScrollTrigger pins). Beats 6–8 are opaque DOM sections with reveal animations. Build output is copied to the repo root on `sub` (GitHub Pages source), same pipeline as today.

**Tech Stack:** Vite, vanilla JS modules, GSAP ≥3.13 (ScrollTrigger + SplitText, all free), Three.js, Lenis, Firebase JS SDK (Firestore only), @fontsource/inter, Vitest.

**Spec:** `docs/superpowers/specs/2026-06-10-signal-landing-page-design.md`

**Environment facts (verified):**
- Node v24.14.0, npm 11.9.0. Playwright available at `C:/Users/didin/AppData/Roaming/npm/node_modules/playwright`.
- Firebase web config (public by design): apiKey `AIzaSyAIa0maBQvJiJiFhroOEdBmlpXcSmjPZgs`, authDomain `gcmpvoice.firebaseapp.com`, projectId `gcmpvoice`, storageBucket `gcmpvoice.firebasestorage.app`, messagingSenderId `1006466693807`, appId `1:1006466693807:web:d3d682e2e5479fa87bf25a`.
- Assets to reuse: `assets/assets/logo_512x512_navy.png`, `web/favicon.png`, `demo_poster.png` (1600×900 branded poster, becomes OG image + WebGL fallback poster).
- Repo branch: `sub` (also the GitHub Pages source; served at https://gcmptec.github.io/web/).
- Shell is PowerShell 5.1 — no `&&` chaining; use `;`.

---

### Task 1: Scaffold the Vite project in `site/`

**Files:**
- Create: `site/package.json`, `site/vite.config.js`, `site/.gitignore` (no — use root .gitignore), root `.gitignore` (modify)
- Create: `site/public/.nojekyll`, copy logo/poster/favicon into `site/public/`

- [ ] **Step 1: Create directories and copy assets**

```powershell
New-Item -ItemType Directory -Force C:\Users\didin\Work\web\site\src\three, C:\Users\didin\Work\web\site\src\story, C:\Users\didin\Work\web\site\src\styles, C:\Users\didin\Work\web\site\public
Copy-Item C:\Users\didin\Work\web\assets\assets\logo_512x512_navy.png C:\Users\didin\Work\web\site\public\logo.png
Copy-Item C:\Users\didin\Work\web\web\favicon.png C:\Users\didin\Work\web\site\public\favicon.png
Copy-Item C:\Users\didin\Work\web\demo_poster.png C:\Users\didin\Work\web\site\public\og.png
Copy-Item C:\Users\didin\Work\web\demo_poster.png C:\Users\didin\Work\web\site\public\poster.png
New-Item -ItemType File -Force C:\Users\didin\Work\web\site\public\.nojekyll
```

- [ ] **Step 2: Write `site/package.json`**

```json
{
  "name": "gcmp-site",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview --port 4173",
    "test": "vitest run"
  }
}
```

- [ ] **Step 3: Write `site/vite.config.js`**

```js
import { defineConfig } from 'vite';

export default defineConfig({
  base: '/web/',
  build: {
    outDir: 'dist',
    target: 'es2022',
  },
  test: {
    environment: 'node',
  },
});
```

- [ ] **Step 4: Install dependencies (latest, no version guessing)**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm install gsap three lenis firebase @fontsource/inter
npm install -D vite vitest
```
Expected: `package.json` gains dependencies; `node_modules/` appears. Verify GSAP bundles SplitText (free since 3.13): `Test-Path node_modules/gsap/SplitText.js` → True.

- [ ] **Step 5: Add `site/node_modules` and `site/dist` to root `.gitignore`**

Append to `C:\Users\didin\Work\web\.gitignore`:

```
# new site
site/node_modules/
site/dist/
```

- [ ] **Step 6: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site .gitignore
git commit -m 'feat(site): scaffold Vite project for Follow-the-Signal rebuild'
```

---

### Task 2: Full static page — HTML copy + CSS (the no-JS baseline)

This is the complete page content. It must read top-to-bottom as a finished page with **zero JS** — that is also the reduced-motion/fallback baseline.

**Files:**
- Create: `site/index.html`, `site/src/styles/base.css`, `site/src/styles/sections.css`, `site/src/main.js` (CSS imports only for now)

- [ ] **Step 1: Write `site/index.html`** (complete copy, final wording)

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>GCMP Security — Signal first. Explain later.</title>
  <meta name="description" content="GCMP is a panic platform for security companies in Botswana. One press captures the emergency, machine learning classifies it into one of seven classes, and your dispatcher is moving in seconds." />
  <link rel="canonical" href="https://gcmptec.github.io/web/" />
  <meta name="theme-color" content="#0E0E1C" />
  <meta property="og:type" content="website" />
  <meta property="og:title" content="GCMP Security — Signal first. Explain later." />
  <meta property="og:description" content="A panic platform for security companies. One press. Classified by ML. Dispatched in seconds." />
  <meta property="og:url" content="https://gcmptec.github.io/web/" />
  <meta property="og:image" content="https://gcmptec.github.io/web/og.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <link rel="icon" type="image/png" href="./favicon.png" />
  <script type="module" src="/src/main.js"></script>
</head>
<body>

  <div id="preloader" aria-hidden="true">
    <img src="./logo.png" alt="" width="72" height="72" />
    <div class="preloader-ring"></div>
  </div>

  <canvas id="gl" aria-hidden="true"></canvas>
  <div id="poster-fallback" hidden aria-hidden="true">
    <div class="css-pulse"></div>
  </div>

  <header id="nav">
    <a class="brand" href="#hero">
      <img src="./logo.png" alt="GCMP logo" width="34" height="34" />
      <span>GCMP</span>
    </a>
    <a class="btn btn-solid" href="#pilot">Apply for pilot</a>
  </header>

  <main>
    <!-- Beat 1 — The Press -->
    <section id="hero" class="beat">
      <div class="pin-inner hero-inner">
        <p class="kicker">SIGNAL FIRST. EXPLAIN LATER.</p>
        <h1>When something goes wrong, the last thing you should need is words.</h1>
        <p class="hero-sub">GCMP is a panic platform for security companies. One press captures the emergency, machine learning understands it, and the right team is moving in seconds.</p>
        <p class="scroll-cue">Scroll — follow the signal<span class="cue-line"></span></p>
      </div>
    </section>

    <div id="story">
      <!-- Beat 2 — Captured -->
      <section id="captured" class="beat chapter">
        <div class="pin-inner">
          <div class="chapter-copy">
            <p class="kicker">00:00 — THE PRESS</p>
            <h2>One press. No call. No questions.</h2>
            <p>A three-second hold captures ten seconds of live audio and an exact GPS fix — and sends them before anyone has to say a word.</p>
          </div>
          <div class="chapter-visual">
            <div class="wave" aria-label="Live audio waveform"></div>
            <p class="coords">📍 −24.6282° S, 25.9231° E · Gaborone</p>
          </div>
        </div>
      </section>

      <!-- Beat 3 — Understood -->
      <section id="understood" class="beat chapter">
        <div class="pin-inner">
          <div class="chapter-copy">
            <p class="kicker">00:04 — THE CLASSIFIER</p>
            <h2>Machine learning reads the situation.</h2>
            <p>A purpose-built classifier listens to the signal and sorts it into one of seven emergency classes — before a human picks up.</p>
          </div>
          <div class="chapter-visual">
            <ul class="classes">
              <li data-class="medical"><span class="cname">Medical</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
              <li data-class="fire"><span class="cname">Fire</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
              <li data-class="crime"><span class="cname">Crime</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
              <li data-class="accident"><span class="cname">Accident</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
              <li data-class="disaster"><span class="cname">Disaster</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
              <li data-class="domestic"><span class="cname">Domestic</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
              <li data-class="unclear"><span class="cname">Unclear</span><span class="bar"><span class="fill"></span></span><span class="pct">0</span></li>
            </ul>
          </div>
        </div>
      </section>

      <!-- Beat 4 — Routed -->
      <section id="routed" class="beat chapter">
        <div class="pin-inner">
          <div class="chapter-copy">
            <p class="kicker">00:07 — THE DISPATCH</p>
            <h2>The right team. The first time.</h2>
            <p>The classified signal lands on the right dispatcher's screen with class, location and audio attached. One tap sends the nearest responder.</p>
          </div>
          <div class="chapter-visual">
            <div class="console" role="img" aria-label="Dispatcher console showing an incoming classified signal">
              <p class="console-head">INCOMING SIGNAL</p>
              <p class="row row-class">CRIME <em>96% confidence</em></p>
              <p class="row">📍 Extension 12, Block 9 · Gaborone</p>
              <p class="row">🎙 0:10 audio attached</p>
              <button class="dispatch-btn" type="button" tabindex="-1">Dispatch unit</button>
            </div>
          </div>
        </div>
      </section>

      <!-- Beat 5 — Resolved -->
      <section id="resolved" class="beat chapter">
        <div class="pin-inner">
          <div class="chapter-copy">
            <h2>Minutes earlier. Every time.</h2>
          </div>
          <div class="chapter-visual">
            <ol class="stamps">
              <li><b>00:00</b><span>The press</span></li>
              <li><b>00:04</b><span>Classified: crime</span></li>
              <li><b>00:07</b><span>On the dispatcher's screen</span></li>
              <li><b>00:09</b><span>Unit dispatched</span></li>
            </ol>
            <p class="kicker resolved-kicker">No "where are you?". No "can you repeat that?". The explaining already happened — automatically.</p>
          </div>
        </div>
      </section>
    </div>

    <!-- Beat 6 — The Pivot -->
    <section id="pivot" class="beat solid">
      <div class="wrap">
        <h2 data-reveal>Now imagine being the company that catches it.</h2>
        <p class="lead" data-reveal>GCMP is built for security companies. You run the control room — we give your dispatchers signals that already explain themselves.</p>

        <div class="offer-grid">
          <article class="offer" data-reveal>
            <h3>Dispatch console</h3>
            <p>A live queue of classified signals with location and audio. Your operators verify in seconds instead of interrogating callers.</p>
          </article>
          <article class="offer" data-reveal>
            <h3>Responder app</h3>
            <p>Secured routing and live, accuracy-gated GPS for your response units. The marker doesn't wander; your driver doesn't guess.</p>
          </article>
          <article class="offer" data-reveal>
            <h3>Discreet tier</h3>
            <p>A paid add-on your clients will ask for: covert triggers for the moments when openly reaching for a phone isn't safe.</p>
          </article>
        </div>

        <div class="commercial" data-reveal>
          <p class="big-line">You pay <b>BWP 15–25</b> per user per month. You sell at <b>BWP 50–80</b>. The margin is yours.</p>
          <p class="anchor-note">For reference: ADT FindU retails around R49/month in South Africa — without ML classification.</p>
        </div>

        <ul class="proof" data-reveal>
          <li>Patent filed (hardware)</li>
          <li>Classifier live in production on Cloud Run</li>
          <li>End-to-end verified on real devices</li>
        </ul>
        <p class="honest" data-reveal>We're pre-revenue and choosing our first three partners deliberately. Early means leverage.</p>
      </div>
    </section>

    <!-- Beat 7 — Pilot -->
    <section id="pilot" class="beat solid">
      <div class="wrap narrow">
        <p class="kicker" data-reveal>THE PILOT</p>
        <h2 data-reveal>Free for 60 days. First three partners only.</h2>
        <p class="lead" data-reveal>Run GCMP alongside your existing process. If it doesn't make your dispatch faster, walk away. After the pilot: a minimum three-month paid term.</p>

        <form id="pilot-form" novalidate data-reveal>
          <label>Full name
            <input name="name" type="text" maxlength="80" autocomplete="name" required />
          </label>
          <label>Company / organisation
            <input name="company" type="text" maxlength="120" autocomplete="organization" required />
          </label>
          <label>Your role
            <select name="role" required>
              <option value="" selected disabled>Select…</option>
              <option>Owner / Director</option>
              <option>Operations / Control room</option>
              <option>Dispatcher</option>
              <option>Other</option>
            </select>
          </label>
          <label>Phone or WhatsApp
            <input name="phone" type="tel" maxlength="20" autocomplete="tel" required />
          </label>
          <label>Email <small>(optional)</small>
            <input name="email" type="email" maxlength="120" autocomplete="email" />
          </label>
          <p id="form-error" class="form-error" hidden></p>
          <button class="btn btn-solid btn-wide" type="submit">Apply for the pilot</button>
          <p class="form-note">We reply within 48 hours. No spam, no resale of your details.</p>
        </form>
        <div id="form-success" class="form-success" hidden>
          <h3>Application received.</h3>
          <p>We'll be in touch within 48 hours. Signal sent — no need to explain.</p>
        </div>
      </div>
    </section>

    <!-- Beat 8 — FAQ -->
    <section id="faq" class="beat solid">
      <div class="wrap narrow">
        <h2 data-reveal>Questions security companies ask</h2>
        <details data-reveal>
          <summary>What does it cost after the pilot?</summary>
          <p>BWP 15–25 per user per month wholesale, depending on volume. You set your own retail — most partners price between BWP 50 and 80.</p>
        </details>
        <details data-reveal>
          <summary>Does it replace our control room?</summary>
          <p>No — it feeds it. Your dispatchers keep dispatching; they just stop interrogating panicked callers to find out what's happening and where.</p>
        </details>
        <details data-reveal>
          <summary>What do our clients get?</summary>
          <p>One button in the GCMP app. A three-second hold sends audio and location. Dispatch and response stay yours, under your brand relationship.</p>
        </details>
        <details data-reveal>
          <summary>What about false alarms?</summary>
          <p>The hold-to-send gate stops pocket presses, and every signal arrives with classification and audio attached — your operator verifies in seconds instead of calling back.</p>
        </details>
        <details data-reveal>
          <summary>Where does the data live?</summary>
          <p>On Google Cloud (Firebase and Cloud Run), encrypted in transit and at rest, with role-based access. Signal data is used for dispatch and audit, not resold.</p>
        </details>
        <details data-reveal>
          <summary>What is the Discreet tier?</summary>
          <p>A paid add-on for situations where visibly using a phone isn't safe — covert triggers with a confirmation haptic only the user notices.</p>
        </details>
      </div>
    </section>
  </main>

  <footer>
    <div class="wrap foot-grid">
      <div>
        <p class="foot-brand"><img src="./logo.png" alt="" width="28" height="28" /> GCMP Security (Pty) Ltd</p>
        <p class="foot-tag">Signal first. Explain later.</p>
      </div>
      <div class="foot-contact">
        <a href="mailto:tsotlhedidintle@gmail.com">tsotlhedidintle@gmail.com</a>
        <a href="tel:+26776436923">+267 76 436 923</a>
        <a href="https://www.linkedin.com/in/didintle-motshubi-41944716a" rel="noopener" target="_blank">LinkedIn</a>
      </div>
    </div>
    <p class="foot-legal">© 2026 GCMP Security (Pty) Ltd · Gaborone, Botswana</p>
  </footer>

</body>
</html>
```

- [ ] **Step 2: Write `site/src/styles/base.css`**

```css
:root {
  --bg: #0E0E1C;
  --surface: #13131F;
  --card: #16162A;
  --border: #1F1F35;
  --green: #00FF94;
  --green-dim: #00CC76;
  --red: #EF4444;
  --text: #E8F0FF;
  --text-2: #7D92B8;
  --text-3: #4A5E7A;
  --font: 'Inter', system-ui, sans-serif;
}

* { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: auto; }
body {
  background: var(--bg);
  color: var(--text-2);
  font-family: var(--font);
  font-size: 16px;
  line-height: 1.7;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}

h1, h2, h3 { color: var(--text); letter-spacing: -0.03em; line-height: 1.08; }
h1 { font-size: clamp(2.2rem, 6vw, 4.4rem); font-weight: 900; }
h2 { font-size: clamp(1.7rem, 4.4vw, 3rem); font-weight: 800; }
h3 { font-size: 1.15rem; font-weight: 700; }
b { color: var(--text); }
a { color: var(--green); text-decoration: none; }

.kicker {
  color: var(--green);
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.22em;
  text-transform: uppercase;
}

.btn {
  display: inline-block;
  font-weight: 700;
  font-size: 0.95rem;
  border-radius: 10px;
  padding: 0.7rem 1.4rem;
  border: 1px solid var(--green);
  color: var(--green);
  cursor: pointer;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.btn:hover { transform: translateY(-2px); box-shadow: 0 8px 30px rgba(0, 255, 148, 0.25); }
.btn-solid { background: var(--green); color: #04130c; }
.btn-wide { width: 100%; font-size: 1.05rem; padding: 0.95rem; }

#gl, #poster-fallback {
  position: fixed;
  inset: 0;
  width: 100vw;
  height: 100vh;
  z-index: 0;
}
#poster-fallback {
  background: radial-gradient(ellipse 70% 55% at 50% 45%, #14203a 0%, var(--bg) 70%);
  display: grid;
  place-items: center;
}
.css-pulse {
  width: 14px; height: 14px; border-radius: 50%;
  background: var(--green);
  box-shadow: 0 0 30px var(--green);
  animation: cssPulse 2.2s ease-out infinite;
}
@keyframes cssPulse {
  0% { box-shadow: 0 0 0 0 rgba(0,255,148,0.55), 0 0 30px var(--green); }
  100% { box-shadow: 0 0 0 90px rgba(0,255,148,0), 0 0 30px var(--green); }
}

#nav {
  position: fixed;
  top: 0; left: 0; right: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.9rem clamp(1rem, 4vw, 3rem);
  background: linear-gradient(rgba(14, 14, 28, 0.85), rgba(14, 14, 28, 0));
}
.brand { display: flex; align-items: center; gap: 0.6rem; color: var(--text); font-weight: 900; letter-spacing: 0.06em; }

main { position: relative; z-index: 1; }

#preloader {
  position: fixed; inset: 0; z-index: 100;
  background: var(--bg);
  display: grid; place-items: center;
  transition: opacity 0.6s ease;
}
#preloader.done { opacity: 0; pointer-events: none; }
.preloader-ring {
  position: absolute;
  width: 120px; height: 120px;
  border: 1px solid rgba(0, 255, 148, 0.4);
  border-top-color: var(--green);
  border-radius: 50%;
  animation: spin 1.1s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

footer {
  position: relative; z-index: 1;
  background: var(--surface);
  border-top: 1px solid var(--border);
  padding: 3rem clamp(1rem, 4vw, 3rem) 1.5rem;
}
.foot-grid { display: flex; flex-wrap: wrap; gap: 2rem; justify-content: space-between; }
.foot-brand { display: flex; align-items: center; gap: 0.6rem; color: var(--text); font-weight: 800; }
.foot-tag { color: var(--text-3); font-size: 0.85rem; margin-top: 0.4rem; }
.foot-contact { display: flex; flex-direction: column; gap: 0.5rem; font-size: 0.95rem; }
.foot-legal { color: var(--text-3); font-size: 0.8rem; margin-top: 2.5rem; }

.wrap { max-width: 1080px; margin: 0 auto; padding: 0 clamp(1rem, 4vw, 2rem); }
.wrap.narrow { max-width: 720px; }
```

- [ ] **Step 3: Write `site/src/styles/sections.css`**

```css
/* ---- beats & sticky chapters ---- */
.beat { position: relative; }

#hero { height: 220vh; }
#hero .pin-inner {
  position: sticky; top: 0;
  height: 100vh;
  display: flex; flex-direction: column;
  justify-content: center;
  max-width: 1080px;
  margin: 0 auto;
  padding: 0 clamp(1rem, 4vw, 2rem);
  gap: 1.4rem;
}
.hero-sub { max-width: 560px; font-size: clamp(1rem, 2vw, 1.2rem); }
.scroll-cue {
  margin-top: 2.5rem;
  color: var(--text-3);
  font-size: 0.8rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  display: flex; align-items: center; gap: 1rem;
}
.cue-line {
  display: inline-block; width: 70px; height: 1px;
  background: linear-gradient(90deg, var(--green), transparent);
  animation: cueSlide 1.8s ease-in-out infinite;
}
@keyframes cueSlide { 50% { transform: translateX(14px); opacity: 0.4; } }

.chapter { height: 240vh; }
.chapter .pin-inner {
  position: sticky; top: 0;
  height: 100vh;
  display: grid;
  grid-template-columns: minmax(0, 5fr) minmax(0, 6fr);
  align-items: center;
  gap: clamp(1.5rem, 5vw, 5rem);
  max-width: 1080px;
  margin: 0 auto;
  padding: 0 clamp(1rem, 4vw, 2rem);
}
.chapter-copy { display: flex; flex-direction: column; gap: 1rem; }

/* captured */
.wave {
  display: flex; align-items: center; gap: 4px;
  height: 110px;
  padding: 1rem;
  background: rgba(22, 22, 42, 0.7);
  border: 1px solid var(--border);
  border-radius: 14px;
  backdrop-filter: blur(6px);
}
.wave span {
  flex: 1; height: 70%;
  background: var(--green);
  opacity: 0.85;
  border-radius: 2px;
  transform-origin: center;
}
.coords {
  margin-top: 1rem;
  font-size: 0.9rem;
  color: var(--text);
  background: rgba(22, 22, 42, 0.7);
  border: 1px solid var(--border);
  border-radius: 999px;
  padding: 0.45rem 1.1rem;
  display: inline-block;
}

/* understood */
.classes { list-style: none; display: flex; flex-direction: column; gap: 0.55rem; }
.classes li {
  display: grid;
  grid-template-columns: 90px 1fr 42px;
  align-items: center;
  gap: 0.8rem;
  font-size: 0.85rem;
  color: var(--text-2);
}
.classes .bar {
  height: 8px;
  background: rgba(31, 31, 53, 0.9);
  border-radius: 999px;
  overflow: hidden;
}
.classes .fill {
  display: block; height: 100%; width: 0;
  background: var(--green-dim);
  border-radius: 999px;
}
.classes .pct { text-align: right; font-variant-numeric: tabular-nums; }
.classes .pct::after { content: '%'; color: var(--text-3); }
.classes.locked-state li:not([data-class='crime']) { opacity: 0.3; }
.classes.locked-state li[data-class='crime'] .cname { color: var(--green); font-weight: 800; }
.classes.locked-state li[data-class='crime'] .fill { background: var(--green); box-shadow: 0 0 18px rgba(0, 255, 148, 0.6); }

/* no-JS / reduced baseline: bars show final values when JS doesn't run */
.no-js .classes .fill { width: 8%; }
.no-js .classes li[data-class='crime'] .fill { width: 96%; }

/* routed */
.console {
  background: rgba(22, 22, 42, 0.85);
  border: 1px solid var(--border);
  border-left: 3px solid var(--green);
  border-radius: 14px;
  padding: 1.4rem;
  display: flex; flex-direction: column; gap: 0.7rem;
  max-width: 420px;
  backdrop-filter: blur(6px);
}
.console-head { color: var(--text-3); font-size: 0.7rem; letter-spacing: 0.25em; }
.console .row { color: var(--text); font-size: 0.95rem; }
.console .row-class { font-weight: 900; font-size: 1.3rem; color: var(--green); }
.console .row-class em { font-style: normal; font-size: 0.8rem; color: var(--text-2); font-weight: 400; margin-left: 0.6rem; }
.dispatch-btn {
  margin-top: 0.5rem;
  background: var(--green); color: #04130c;
  font-weight: 800; font-size: 0.95rem;
  border: 0; border-radius: 9px;
  padding: 0.7rem;
  cursor: default;
}

/* resolved */
.stamps { list-style: none; display: flex; flex-direction: column; gap: 1rem; }
.stamps li {
  display: flex; align-items: baseline; gap: 1.2rem;
  border-left: 2px solid var(--border);
  padding-left: 1.2rem;
}
.stamps b { color: var(--green); font-size: 1.5rem; font-variant-numeric: tabular-nums; }
.stamps span { color: var(--text); }
.resolved-kicker { margin-top: 1.6rem; color: var(--text-2); text-transform: none; letter-spacing: 0; font-size: 1rem; font-weight: 400; }

/* ---- solid sections (pivot / pilot / faq) ---- */
.solid { background: var(--surface); border-top: 1px solid var(--border); padding: clamp(4rem, 10vh, 7rem) 0; }
#pivot { background: linear-gradient(var(--surface), var(--bg)); }
#pivot .lead, #pilot .lead { font-size: 1.1rem; max-width: 640px; margin-top: 1rem; }
.offer-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.2rem;
  margin: 2.5rem 0;
}
.offer {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 1.5rem;
}
.offer h3 { margin-bottom: 0.6rem; }
.offer p { font-size: 0.92rem; }
.commercial {
  border: 1px solid rgba(0, 255, 148, 0.3);
  background: rgba(0, 255, 148, 0.04);
  border-radius: 14px;
  padding: 1.6rem;
  margin: 2rem 0;
}
.big-line { color: var(--text); font-size: clamp(1.1rem, 2.6vw, 1.5rem); font-weight: 700; }
.anchor-note { font-size: 0.85rem; color: var(--text-3); margin-top: 0.5rem; }
.proof { list-style: none; display: flex; flex-wrap: wrap; gap: 0.7rem; margin: 1.5rem 0; }
.proof li {
  font-size: 0.82rem; color: var(--text);
  border: 1px solid var(--border);
  background: var(--card);
  border-radius: 999px;
  padding: 0.4rem 1rem;
}
.proof li::before { content: '✓ '; color: var(--green); }
.honest { font-size: 0.95rem; color: var(--text-2); font-style: italic; }

/* pilot form */
#pilot-form { display: flex; flex-direction: column; gap: 1.1rem; margin-top: 2.2rem; }
#pilot-form label { display: flex; flex-direction: column; gap: 0.4rem; color: var(--text); font-size: 0.9rem; font-weight: 600; }
#pilot-form small { color: var(--text-3); font-weight: 400; }
#pilot-form input, #pilot-form select {
  background: var(--card);
  border: 1px solid var(--border);
  border-radius: 10px;
  color: var(--text);
  font: inherit;
  padding: 0.75rem 0.9rem;
  outline: none;
}
#pilot-form input:focus, #pilot-form select:focus { border-color: var(--green); }
.form-error {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.4);
  color: #ffb4b4;
  border-radius: 10px;
  padding: 0.7rem 1rem;
  font-size: 0.9rem;
}
.form-note { font-size: 0.8rem; color: var(--text-3); text-align: center; }
.form-success {
  margin-top: 2rem;
  border: 1px solid rgba(0, 255, 148, 0.4);
  background: rgba(0, 255, 148, 0.06);
  border-radius: 14px;
  padding: 2rem;
  text-align: center;
}
.form-success h3 { color: var(--green); margin-bottom: 0.5rem; }

/* faq */
#faq details {
  border-bottom: 1px solid var(--border);
  padding: 1.1rem 0;
}
#faq summary {
  color: var(--text);
  font-weight: 700;
  cursor: pointer;
  list-style: none;
  display: flex; justify-content: space-between; align-items: center;
}
#faq summary::-webkit-details-marker { display: none; }
#faq summary::after { content: '+'; color: var(--green); font-size: 1.3rem; font-weight: 400; }
#faq details[open] summary::after { content: '−'; }
#faq details p { padding-top: 0.7rem; font-size: 0.95rem; max-width: 620px; }

/* ---- mobile ---- */
@media (max-width: 768px) {
  .chapter .pin-inner { grid-template-columns: 1fr; align-content: center; gap: 2rem; }
  #hero { height: 180vh; }
  .chapter { height: 200vh; }
  .stamps b { font-size: 1.2rem; }
}
```

- [ ] **Step 4: Write minimal `site/src/main.js`** (CSS only — animations come later)

```js
import './styles/base.css';
import './styles/sections.css';
import '@fontsource/inter/400.css';
import '@fontsource/inter/700.css';
import '@fontsource/inter/900.css';
```

- [ ] **Step 5: Verify dev render and production build**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm run build
```
Expected: `dist/` contains `index.html`, `assets/*.js`, `assets/*.css`, `logo.png`, `og.png`, `poster.png`, `favicon.png`, `.nojekyll`. Open dev server (`npm run dev`, background) and screenshot with Playwright to confirm the page reads top-to-bottom.

- [ ] **Step 6: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site
git commit -m 'feat(site): full static page - copy, layout, no-JS baseline'
```

---

### Task 3: Form validation logic (TDD)

**Files:**
- Create: `site/src/form-validate.js`
- Test: `site/src/form-validate.test.js`

- [ ] **Step 1: Write the failing tests** (`site/src/form-validate.test.js`)

```js
import { describe, it, expect } from 'vitest';
import { validatePilotForm, ROLES } from './form-validate.js';

const valid = {
  name: 'Kabo Mosweu',
  company: 'Falcon Security',
  role: 'Owner / Director',
  phone: '+267 76 123 456',
  email: 'kabo@falcon.co.bw',
};

describe('validatePilotForm', () => {
  it('accepts a fully valid application', () => {
    expect(validatePilotForm(valid)).toBeNull();
  });

  it('accepts empty email (optional field)', () => {
    expect(validatePilotForm({ ...valid, email: '' })).toBeNull();
  });

  it('rejects empty name', () => {
    expect(validatePilotForm({ ...valid, name: '  ' })).toMatch(/full name/i);
  });

  it('rejects name over 80 chars', () => {
    expect(validatePilotForm({ ...valid, name: 'x'.repeat(81) })).toMatch(/too long/i);
  });

  it('rejects empty company', () => {
    expect(validatePilotForm({ ...valid, company: '' })).toMatch(/company/i);
  });

  it('rejects unknown role', () => {
    expect(validatePilotForm({ ...valid, role: 'Hacker' })).toMatch(/role/i);
  });

  it('rejects phone with too few digits', () => {
    expect(validatePilotForm({ ...valid, phone: '12345' })).toMatch(/phone/i);
  });

  it('rejects phone with letters', () => {
    expect(validatePilotForm({ ...valid, phone: 'call me 76436923' })).toMatch(/phone/i);
  });

  it('rejects phone with more than 15 digits', () => {
    expect(validatePilotForm({ ...valid, phone: '1234567890123456' })).toMatch(/phone/i);
  });

  it('rejects malformed email when provided', () => {
    expect(validatePilotForm({ ...valid, email: 'not-an-email' })).toMatch(/email/i);
  });

  it('exposes the four allowed roles', () => {
    expect(ROLES).toEqual([
      'Owner / Director',
      'Operations / Control room',
      'Dispatcher',
      'Other',
    ]);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm test
```
Expected: FAIL — cannot resolve `./form-validate.js`.

- [ ] **Step 3: Write `site/src/form-validate.js`**

Rules mirror the server-side Firestore rules documented in `docs/SECURITY-NOTES.md` (field whitelist, length caps).

```js
export const ROLES = [
  'Owner / Director',
  'Operations / Control room',
  'Dispatcher',
  'Other',
];

export function validatePilotForm({ name = '', company = '', role = '', phone = '', email = '' }) {
  if (!name.trim()) return 'Please enter your full name.';
  if (name.trim().length > 80) return 'That name is too long.';
  if (!company.trim()) return 'Please enter your company or organisation.';
  if (company.trim().length > 120) return 'That company name is too long.';
  if (!ROLES.includes(role)) return 'Please select your role.';

  const p = phone.trim();
  if (!p) return 'Please enter a phone or WhatsApp number.';
  const digits = p.replace(/\D/g, '');
  if (digits.length < 7 || digits.length > 15 || !/^\+?[\d\s\-()]+$/.test(p)) {
    return "That phone number doesn't look right — please check it.";
  }

  const e = email.trim();
  if (e && (e.length > 120 || !/^[\w.+-]+@[\w-]+(\.[\w-]+)+$/.test(e))) {
    return "That email address doesn't look right — please check it.";
  }
  return null;
}
```

- [ ] **Step 4: Run tests to verify they pass**

```powershell
npm test
```
Expected: 11 passed.

- [ ] **Step 5: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src/form-validate.js site/src/form-validate.test.js
git commit -m 'feat(site): pilot form validation, mirrors Firestore rules (TDD)'
```

---

### Task 4: Form submission wiring (Firebase, lazy-loaded)

**Files:**
- Create: `site/src/firebase.js`, `site/src/form.js`
- Modify: `site/src/main.js`

- [ ] **Step 1: Write `site/src/firebase.js`**

The web config is public by design — the security boundary is the Firestore rules (deployed from the app repo; see `docs/SECURITY-NOTES.md`). `serverTimestamp()` satisfies the `timestamp == request.time` rule.

```js
import { initializeApp } from 'firebase/app';
import { getFirestore, collection, addDoc, serverTimestamp } from 'firebase/firestore';

const app = initializeApp({
  apiKey: 'AIzaSyAIa0maBQvJiJiFhroOEdBmlpXcSmjPZgs',
  authDomain: 'gcmpvoice.firebaseapp.com',
  projectId: 'gcmpvoice',
  storageBucket: 'gcmpvoice.firebasestorage.app',
  messagingSenderId: '1006466693807',
  appId: '1:1006466693807:web:d3d682e2e5479fa87bf25a',
});

export async function submitPilotApplication(fields) {
  const db = getFirestore(app);
  const ref = await addDoc(collection(db, 'pilot_applications'), {
    ...fields,
    timestamp: serverTimestamp(),
  });
  return ref.id;
}
```

- [ ] **Step 2: Write `site/src/form.js`**

```js
import { validatePilotForm } from './form-validate.js';

export function initPilotForm() {
  const form = document.getElementById('pilot-form');
  const errBox = document.getElementById('form-error');
  const okBox = document.getElementById('form-success');
  const btn = form.querySelector('button[type="submit"]');
  let busy = false;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    if (busy) return;

    const data = Object.fromEntries(new FormData(form));
    const fields = {
      name: (data.name || '').trim(),
      company: (data.company || '').trim(),
      role: data.role || '',
      phone: (data.phone || '').trim(),
      email: (data.email || '').trim(),
    };

    const err = validatePilotForm(fields);
    if (err) {
      errBox.textContent = err;
      errBox.hidden = false;
      return;
    }
    errBox.hidden = true;
    busy = true;
    btn.disabled = true;
    btn.textContent = 'Sending…';

    try {
      const { submitPilotApplication } = await import('./firebase.js');
      const id = await submitPilotApplication(fields);
      console.info('pilot application id:', id);
      form.hidden = true;
      okBox.hidden = false;
    } catch {
      errBox.innerHTML =
        'Something went wrong sending your application. Email us instead: ' +
        '<a href="mailto:tsotlhedidintle@gmail.com">tsotlhedidintle@gmail.com</a>';
      errBox.hidden = false;
      busy = false;
      btn.disabled = false;
      btn.textContent = 'Apply for the pilot';
    }
  });
}
```

- [ ] **Step 3: Wire into `site/src/main.js`** (append)

```js
import { initPilotForm } from './form.js';

initPilotForm();
```

- [ ] **Step 4: Verify the lazy split and client validation**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm run build
```
Expected: build succeeds and `dist/assets/` contains a **separate** firebase chunk (lazy import). In the dev server, submitting an empty form shows the red error box; no network calls fired. Full Firestore E2E happens in Task 11.

- [ ] **Step 5: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src/firebase.js site/src/form.js site/src/main.js
git commit -m 'feat(site): pilot form submission with lazy Firebase + mailto fallback'
```

---

### Task 5: Quality tiering + WebGL detection (TDD)

**Files:**
- Create: `site/src/three/quality.js`
- Test: `site/src/three/quality.test.js`

- [ ] **Step 1: Write the failing tests** (`site/src/three/quality.test.js`)

```js
import { describe, it, expect } from 'vitest';
import { getQualityTier } from './quality.js';

describe('getQualityTier', () => {
  it('returns low tier for narrow screens regardless of cores', () => {
    const t = getQualityTier({ cores: 16, width: 390, dpr: 3 });
    expect(t.name).toBe('low');
    expect(t.dprCap).toBe(1.5);
  });

  it('returns low tier for weak CPUs', () => {
    expect(getQualityTier({ cores: 4, width: 1920, dpr: 1 }).name).toBe('low');
  });

  it('returns mid tier for average desktops', () => {
    const t = getQualityTier({ cores: 8, width: 1440, dpr: 2 });
    expect(t.name).toBe('mid');
    expect(t.dprCap).toBe(2);
  });

  it('returns high tier for strong desktops', () => {
    expect(getQualityTier({ cores: 12, width: 1920, dpr: 2 }).name).toBe('high');
  });

  it('scales node count up with tier', () => {
    const low = getQualityTier({ cores: 2, width: 390, dpr: 2 });
    const high = getQualityTier({ cores: 16, width: 1920, dpr: 2 });
    expect(high.nodeCount).toBeGreaterThan(low.nodeCount);
  });

  it('defaults safely with no input', () => {
    expect(getQualityTier({}).name).toBeDefined();
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm test
```
Expected: FAIL — cannot resolve `./quality.js`.

- [ ] **Step 3: Write `site/src/three/quality.js`**

```js
export function getQualityTier({ cores = 4, width = 1280, dpr = 1 } = {}) {
  if (width < 768 || cores <= 4) {
    return { name: 'low', dprCap: 1.5, nodeCount: 900, linkCount: 260 };
  }
  if (cores <= 8) {
    return { name: 'mid', dprCap: 2, nodeCount: 1800, linkCount: 650 };
  }
  return { name: 'high', dprCap: 2, nodeCount: 3000, linkCount: 1100 };
}

export function detectWebGL() {
  try {
    const c = document.createElement('canvas');
    return !!(c.getContext('webgl2') || c.getContext('webgl'));
  } catch {
    return false;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

```powershell
npm test
```
Expected: all tests pass (form tests + 6 quality tests).

- [ ] **Step 5: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src/three/quality.js site/src/three/quality.test.js
git commit -m 'feat(site): device quality tiering + WebGL detection (TDD)'
```

---

### Task 6: Three.js scene foundation (night network renders)

**Files:**
- Create: `site/src/three/scene.js`, `site/src/three/network.js`
- Modify: `site/src/main.js`

- [ ] **Step 1: Write `site/src/three/scene.js`**

```js
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
    running = !document.hidden;
  });

  const clock = new THREE.Clock();
  renderer.setAnimationLoop(() => {
    if (!running) return;
    const t = clock.getElapsedTime();
    for (const fn of updatables) fn(t);
    renderer.render(scene, camera);
  });

  // Context loss: allow one automatic restore; if it doesn't come back, bail to poster.
  let lossTimer = null;
  canvas.addEventListener('webglcontextlost', (e) => {
    e.preventDefault();
    lossTimer = setTimeout(() => onFatalLoss && onFatalLoss(), 3000);
  });
  canvas.addEventListener('webglcontextrestored', () => {
    clearTimeout(lossTimer);
    setSize();
  });

  return {
    scene,
    camera,
    renderer,
    onFrame: (fn) => updatables.push(fn),
  };
}
```

- [ ] **Step 2: Write `site/src/three/network.js`** (twinkling points + faint links, custom shader)

```js
import * as THREE from 'three';

const VERT = /* glsl */ `
attribute float aSeed;
uniform float uTime;
varying float vTwinkle;
void main() {
  vec4 mv = modelViewMatrix * vec4(position, 1.0);
  vTwinkle = 0.45 + 0.55 * sin(uTime * 1.4 + aSeed * 6.2831);
  gl_PointSize = (1.6 + 1.8 * vTwinkle) * (160.0 / -mv.z);
  gl_Position = projectionMatrix * mv;
}`;

const FRAG = /* glsl */ `
varying float vTwinkle;
void main() {
  float d = length(gl_PointCoord - 0.5);
  if (d > 0.5) discard;
  float a = smoothstep(0.5, 0.0, d) * vTwinkle;
  gl_FragColor = vec4(0.0, 1.0, 0.58, a * 0.85);
}`;

export function buildNetwork(tier) {
  const group = new THREE.Group();
  const n = tier.nodeCount;

  const pos = new Float32Array(n * 3);
  const seed = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    pos[i * 3] = (Math.random() - 0.5) * 130;
    pos[i * 3 + 1] = (Math.random() - 0.5) * 1.6;
    pos[i * 3 + 2] = (Math.random() - 0.5) * 130;
    seed[i] = Math.random();
  }

  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  geo.setAttribute('aSeed', new THREE.BufferAttribute(seed, 1));

  const mat = new THREE.ShaderMaterial({
    vertexShader: VERT,
    fragmentShader: FRAG,
    uniforms: { uTime: { value: 0 } },
    transparent: true,
    depthWrite: false,
    blending: THREE.AdditiveBlending,
  });
  group.add(new THREE.Points(geo, mat));

  // Faint links: each link connects a random node to its nearest of 12 random candidates.
  const linkPos = [];
  for (let i = 0; i < tier.linkCount; i++) {
    const a = Math.floor(Math.random() * n);
    let best = a;
    let bestD = Infinity;
    for (let k = 0; k < 12; k++) {
      const b = Math.floor(Math.random() * n);
      if (b === a) continue;
      const dx = pos[a * 3] - pos[b * 3];
      const dz = pos[a * 3 + 2] - pos[b * 3 + 2];
      const d = dx * dx + dz * dz;
      if (d < bestD) {
        bestD = d;
        best = b;
      }
    }
    linkPos.push(
      pos[a * 3], pos[a * 3 + 1], pos[a * 3 + 2],
      pos[best * 3], pos[best * 3 + 1], pos[best * 3 + 2],
    );
  }
  const lgeo = new THREE.BufferGeometry();
  lgeo.setAttribute('position', new THREE.BufferAttribute(new Float32Array(linkPos), 3));
  const lmat = new THREE.LineBasicMaterial({ color: 0x00ff94, transparent: true, opacity: 0.07 });
  group.add(new THREE.LineSegments(lgeo, lmat));

  return {
    group,
    update: (t) => {
      mat.uniforms.uTime.value = t;
    },
  };
}
```

- [ ] **Step 3: Boot the scene from `site/src/main.js`** (replace file with full boot — form import stays)

```js
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
```

- [ ] **Step 4: Visual verify**

Run `npm run dev` (background), Playwright-screenshot `http://127.0.0.1:5173/web/`. Expected: hero text over a twinkling green node field receding into fog. No console errors.

- [ ] **Step 5: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src
git commit -m 'feat(site): Three.js night network scene with quality tiers'
```

---

### Task 7: Scroll infrastructure — Lenis, pulse, camera journey

**Files:**
- Create: `site/src/three/pulse.js`, `site/src/story/journey.js`
- Modify: `site/src/main.js`

- [ ] **Step 1: Write `site/src/three/pulse.js`**

```js
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
      gsap.fromTo(disp.material, { opacity: 0.4 }, { opacity: 1, duration: 0.5 });
      gsap.fromTo(disp.scale, { x: 2.2, y: 2.2, z: 2.2 }, { x: 4, y: 4, z: 4, duration: 0.5, ease: 'back.out(3)' });
    }
    if (p < 0.9) arrived = false;
  }

  return { group, firePress, setSignalProgress };
}
```

- [ ] **Step 2: Write `site/src/story/journey.js`** (camera scrub + pulse triggers)

```js
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
```

- [ ] **Step 3: Wire Lenis + GSAP + journey into `site/src/main.js`** (full file replacement)

```js
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
}
```

- [ ] **Step 4: Visual verify the journey**

Dev server + Playwright scroll captures: wheel down in ~900px steps, screenshot each. Expected: hero wide shot → camera dives as `#captured` approaches → overhead during `#understood` → swings toward dispatcher node in `#routed` → pulls back in `#resolved`. Press rings fire on first scroll; signal dot travels and pops the dispatcher node.

- [ ] **Step 5: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src
git commit -m 'feat(site): Lenis scroll, press pulse, scroll-scrubbed camera journey'
```

---

### Task 8: Chapter DOM animations (beats 1–5)

**Files:**
- Create: `site/src/story/chapters.js`
- Modify: `site/src/main.js` (one import + call)

- [ ] **Step 1: Write `site/src/story/chapters.js`**

```js
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
  // reduced motion: CSS baseline is fully readable; no animations registered.
}

function buildWave() {
  const wave = document.querySelector('#captured .wave');
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
  const split = new SplitText('#hero h1', { type: 'words' });
  gsap.from(split.words, {
    yPercent: 110, opacity: 0, stagger: 0.06, duration: 0.9, ease: 'power3.out', delay: 0.25,
  });
  gsap.from('#hero .kicker, #hero .hero-sub, #hero .scroll-cue', {
    opacity: 0, y: 18, stagger: 0.12, duration: 0.7, delay: 0.9,
  });
  gsap.to('#hero .hero-inner', {
    opacity: 0, y: -90, ease: 'none',
    scrollTrigger: { trigger: '#hero', start: 'top top', end: '60% top', scrub: true },
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
    repeat: -1,
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
  tl.to({}, {
    duration: 0.01,
    onComplete: () => list.classList.add('locked-state'),
    onReverseComplete: () => list.classList.remove('locked-state'),
  }, '+=0.15');
}

function routed() {
  chapterIntro('#routed')
    .from('#routed .console', {
      y: 60, opacity: 0, rotateX: 8, transformPerspective: 600, duration: 0.7, ease: 'power3.out',
    }, '-=0.2')
    .from('#routed .console .row', { x: -18, opacity: 0, stagger: 0.09, duration: 0.4 })
    .fromTo('#routed .dispatch-btn',
      { boxShadow: '0 0 0 0 rgba(0,255,148,0.5)' },
      { boxShadow: '0 0 0 18px rgba(0,255,148,0)', duration: 0.9, repeat: 2 });
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
```

- [ ] **Step 2: Wire into `site/src/main.js`** — add after `initPilotForm();`:

```js
import { initChapters } from './story/chapters.js';

initChapters();
```
(Import statement goes at the top with the other imports; the call after `initPilotForm()`.)

- [ ] **Step 3: Visual verify**

Playwright scroll captures, desktop (1440×900) and mobile (390×844). Check: headline word-reveal on load; waveform alive in `#captured`; probability bars race and CRIME locks with others dimming; console card flips in; stamps stagger; pivot/pilot/faq blocks reveal. Check no horizontal scrollbar at 390px.

- [ ] **Step 4: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src
git commit -m 'feat(site): chapter animations for beats 1-5 + reveal system'
```

---### Task 9: Preloader

**Files:**
- Create: `site/src/preloader.js`
- Modify: `site/src/main.js`

- [ ] **Step 1: Write `site/src/preloader.js`**

```js
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
```

- [ ] **Step 2: Wire into `site/src/main.js`** — first import, called before anything else:

```js
import { initPreloader } from './preloader.js';

initPreloader();
```

- [ ] **Step 3: Verify**

Dev server: hard refresh in a fresh incognito Playwright context → preloader visible briefly, fades; reload same context → no preloader (sessionStorage flag).

- [ ] **Step 4: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src
git commit -m 'feat(site): branded preloader with session skip'
```

---

### Task 10: Fallback passes (reduced-motion + no-WebGL)

No new code expected — this task **verifies** the fallback ladder built in Tasks 6–8 and fixes anything broken.

- [ ] **Step 1: Reduced-motion pass**

Playwright with `reducedMotion: 'reduce'` in context options. Scroll the full page. Expected: poster fallback shown (no canvas), no pins/scrubs (sticky CSS still positions content but nothing animates), all copy readable, bars show baseline widths via `.no-js` rule — **fix**: the `.no-js` CSS class is never added; under reduced motion the bars would be at width 0. Add to `initChapters()` in `site/src/story/chapters.js`:

```js
mm.add('(prefers-reduced-motion: reduce)', () => {
  document.body.classList.add('no-js');
});
```

And in `site/src/styles/sections.css`, change the two `.no-js` selectors to also apply under `body.no-js`:

```css
body.no-js .classes .fill { width: 8%; }
body.no-js .classes li[data-class='crime'] .fill { width: 96%; }
```
(Replace the existing `.no-js .classes ...` rules with these.)

- [ ] **Step 2: No-WebGL pass**

Playwright launch with `--disable-webgl --disable-webgl2` chrome args. Expected: poster fallback with CSS pulse, GSAP story still animates fully, no console errors.

- [ ] **Step 3: Commit**

```powershell
Set-Location C:\Users\didin\Work\web
git add site/src
git commit -m 'fix(site): reduced-motion baseline for classifier bars + fallback verification'
```

---

### Task 11: Verification suite — screenshots, Lighthouse, bundle budget, form E2E

**Files:**
- Create: `.claude/shots/signal-desktop.js`, `.claude/shots/signal-mobile.js` (git-ignored helper scripts)

- [ ] **Step 1: Build and preview**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm run build
npm run preview   # background task; serves dist at http://127.0.0.1:4173/web/
```

- [ ] **Step 2: Write and run `.claude/shots/signal-desktop.js`**

```js
const { chromium } = require('C:/Users/didin/AppData/Roaming/npm/node_modules/playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('http://127.0.0.1:4173/web/', { waitUntil: 'networkidle' });
  await page.waitForTimeout(3000);
  for (let i = 0; i <= 16; i++) {
    await page.screenshot({ path: `C:/Users/didin/Work/web/.claude/shots/sd${i}.png` });
    await page.mouse.wheel(0, 950);
    await page.waitForTimeout(850);
  }
  await browser.close();
})();
```

`signal-mobile.js` is identical except `viewport: { width: 390, height: 844 }`, wheel step `700`, output prefix `sm`. Run both with `node`, then **Read every screenshot** and fix anything broken (overlap, contrast, truncation) before proceeding.

- [ ] **Step 3: Bundle budget check**

```powershell
Get-ChildItem C:\Users\didin\Work\web\site\dist\assets\*.js | ForEach-Object { '{0}  {1:N0} KB raw' -f $_.Name, ($_.Length/1KB) }
```
Expected: initial (non-firebase) JS chunks total ≤ ~900KB raw (≈300KB gzip). The firebase chunk is lazy and excluded from the initial budget. If over: confirm three.js is in a lazy-loaded chunk (it is — dynamic import in `bootScene`).

- [ ] **Step 4: Lighthouse (mobile)**

```powershell
npx lighthouse "http://127.0.0.1:4173/web/" --output=json --output-path=C:\Users\didin\Work\web\.claude\shots\lh.json --chrome-flags="--headless" --form-factor=mobile --quiet
node -e "const r=require('C:/Users/didin/Work/web/.claude/shots/lh.json');for(const[k,v]of Object.entries(r.categories))console.log(k,Math.round(v.score*100))"
```
Expected: performance ≥ 90, accessibility ≥ 90. If performance fails: check render-blocking font CSS and preload hints first.

- [ ] **Step 5: Form E2E (user pre-approved in spec; announce before running)**

Playwright: fill the form (`name: GCMP Test`, `company: E2E Check`, role `Other`, `phone: +267 76 000 000`), submit, assert `#form-success` becomes visible, capture `pilot application id: <ID>` from the console. Then delete the test doc:

```powershell
firebase firestore:delete "pilot_applications/<ID>" --project gcmpvoice --force
```
If the firebase CLI is not authenticated, flag the doc ID to Didintle to delete in the console instead — do not leave it silently.

- [ ] **Step 6: Commit any fixes from this task**

```powershell
Set-Location C:\Users\didin\Work\web
git add site
git commit -m 'fix(site): verification pass fixes (visual/perf/a11y)'
```

---

### Task 12: Deploy — retire Flutter, ship the new site

**Files:**
- Modify: root `CLAUDE.md` (rewrite), repo root (replace build output)
- Delete (tracked): `lib/`, `web/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `flutter_native_splash.yaml`, root Flutter build artifacts
- Update after deploy: memory file `C:\Users\didin\.claude\projects\C--Users-didin-Work-web\memory\project-deployment.md`

- [ ] **Step 1: Final build**

```powershell
Set-Location C:\Users\didin\Work\web\site
npm run build
```

- [ ] **Step 2: Remove Flutter source + old build output from the tree**

```powershell
Set-Location C:\Users\didin\Work\web
git rm -r -q --ignore-unmatch lib web test splash assets canvaskit icons
git rm -q --ignore-unmatch pubspec.yaml pubspec.lock analysis_options.yaml flutter_native_splash.yaml index.html flutter.js flutter_bootstrap.js flutter_service_worker.js main.dart.js version.json manifest.json favicon.png demo_poster.png web.iml .last_build_id .flutter-plugins-dependencies
```
Leave `.firebaserc` and `firebase.json` untouched (out of scope). `GcmpVoice`, `android/` etc. are git-ignored already.

- [ ] **Step 3: Copy the new build to the repo root**

```powershell
robocopy C:\Users\didin\Work\web\site\dist C:\Users\didin\Work\web /E
```
robocopy exit codes 0–3 are success. Verify `C:\Users\didin\Work\web\index.html` now contains `id="gl"`.

- [ ] **Step 4: Rewrite root `CLAUDE.md`**

```markdown
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
```

- [ ] **Step 5: Commit and push**

```powershell
Set-Location C:\Users\didin\Work\web
git add -A
git commit -m 'deploy: Follow-the-Signal landing page - GSAP+Three.js rebuild, Flutter retired'
git push origin sub
```

- [ ] **Step 6: Live verification**

Poll until GitHub Pages updates (1–3 min), then verify:

```powershell
# new site live (vite index references the gl canvas)
curl.exe -s https://gcmptec.github.io/web/ | Select-String 'id="gl"'
# assets resolve
curl.exe -s -o NUL -w "%{http_code}" https://gcmptec.github.io/web/logo.png   # expect 200
curl.exe -s -o NUL -w "%{http_code}" https://gcmptec.github.io/web/og.png    # expect 200
```
Then a final Playwright scroll-capture against the **live URL**, desktop + mobile, and read the screenshots.

- [ ] **Step 7: Update auto-memory**

Update `C:\Users\didin\.claude\projects\C--Users-didin-Work-web\memory\project-deployment.md`: deployment is now Vite (`site/` → `npm run build` → robocopy `site\dist` → root on `sub`); Flutter and the HtmlElementView video note are obsolete. Keep the `MEMORY.md` index line accurate.

---

## Self-review (done at write time)

- **Spec coverage:** preloader (T9), hero+story (T6–T8), pivot/pilot/faq copy (T2), form+rules mirror (T3–T4), quality tiers (T5), fallback ladder (T6 boot + T10), SEO meta (T2), perf budget + Lighthouse (T11), deploy + Flutter retirement + CLAUDE.md (T12). Demo video: explicitly out of scope per spec.
- **Placeholder scan:** none — all code complete.
- **Type consistency:** `initScene(canvas, tier, onFatalLoss)` matches T6/T7 usage; `buildPulse()` returns `{ group, firePress, setSignalProgress }` as consumed by journey.js; `getQualityTier` shape `{ name, dprCap, nodeCount, linkCount }` consumed by network.js; `validatePilotForm` returns `string | null` as consumed by form.js.
