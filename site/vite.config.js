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
