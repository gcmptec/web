import * as THREE from 'three';

const VERT = /* glsl */ `
attribute float aSeed;
uniform float uTime;
uniform float uDpr;
varying float vTwinkle;
void main() {
  vec4 mv = modelViewMatrix * vec4(position, 1.0);
  vTwinkle = 0.45 + 0.55 * sin(uTime * 1.4 + aSeed * 6.2831);
  gl_PointSize = (1.6 + 1.8 * vTwinkle) * (160.0 / -mv.z) * uDpr;
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
    uniforms: {
      uTime: { value: 0 },
      uDpr: { value: Math.min(window.devicePixelRatio || 1, tier.dprCap) },
    },
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
