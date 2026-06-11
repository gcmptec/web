import { defineConfig } from 'vite';

/**
 * Vite plugin: inject <link rel="modulepreload"> for the anim-vendor chunk
 * (GSAP + Lenis) into the built index.html.
 *
 * Vite automatically preloads static-import chunks, but not dynamic-import
 * chunks.  The animate.js chunk is loaded via requestIdleCallback, so the
 * browser doesn't know to pre-fetch anim-vendor until animate.js is evaluated.
 * Adding the modulepreload here means anim-vendor starts downloading from
 * HTML parse time, in parallel with the main JS entry — arriving before rIC
 * fires and avoiding the serial waterfall penalty on slow 4G.
 */
function preloadAnimVendor() {
  let animVendorFile = '';
  return {
    name: 'preload-anim-vendor',
    generateBundle(_, bundle) {
      for (const [fileName] of Object.entries(bundle)) {
        if (fileName.startsWith('assets/anim-vendor')) {
          animVendorFile = fileName;
        }
      }
    },
    transformIndexHtml(html) {
      if (!animVendorFile) return html;
      const tag = `  <link rel="modulepreload" href="/web/${animVendorFile}" />\n`;
      return html.replace('</head>', tag + '</head>');
    },
  };
}

export default defineConfig({
  base: '/web/',
  plugins: [preloadAnimVendor()],
  build: {
    outDir: 'dist',
    target: 'es2022',
    rollupOptions: {
      output: {
        // Merge GSAP (core + all plugins) and Lenis into one vendor chunk.
        // Vite's default splits every node_module separately, producing a
        // 3-file serial waterfall (animate.js → gsap → ScrollTrigger) on
        // slow 4G that delays rIC execution until after FCP.
        // One ~137 KB chunk + modulepreload means the browser fetches it
        // during HTML parse, in parallel with the entry script, so the rIC
        // callback has everything cached and evaluates before FCP.
        //
        // Three.js: own chunk — interaction-gated, 523 KB, fetch on demand.
        // Firebase: own chunk — lazy on form submit.
        manualChunks(id) {
          if (id.includes('node_modules/three')) return 'three.module';
          if (id.includes('node_modules/firebase')) return 'firebase';
          if (
            id.includes('node_modules/gsap') ||
            id.includes('node_modules/lenis')
          ) return 'anim-vendor';
        },
      },
    },
  },
  test: {
    environment: 'node',
  },
});
