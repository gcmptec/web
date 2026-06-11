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
