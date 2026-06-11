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
