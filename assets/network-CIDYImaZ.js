import{_ as e,c as t,l as n,m as r,n as i,r as a,u as o}from"./three.module-Cp20BDta.js";var s=`
attribute float aSeed;
uniform float uTime;
uniform float uDpr;
varying float vTwinkle;
void main() {
  vec4 mv = modelViewMatrix * vec4(position, 1.0);
  vTwinkle = 0.45 + 0.55 * sin(uTime * 1.4 + aSeed * 6.2831);
  gl_PointSize = (1.6 + 1.8 * vTwinkle) * (160.0 / -mv.z) * uDpr;
  gl_Position = projectionMatrix * mv;
}`,c=`
varying float vTwinkle;
void main() {
  float d = length(gl_PointCoord - 0.5);
  if (d > 0.5) discard;
  float a = smoothstep(0.5, 0.0, d) * vTwinkle;
  gl_FragColor = vec4(0.0, 1.0, 0.58, a * 0.85);
}`;function l(l){let u=new t,d=l.nodeCount,f=new Float32Array(d*3),p=new Float32Array(d);for(let e=0;e<d;e++)f[e*3]=(Math.random()-.5)*130,f[e*3+1]=(Math.random()-.5)*1.6,f[e*3+2]=(Math.random()-.5)*130,p[e]=Math.random();let m=new a;m.setAttribute(`position`,new i(f,3)),m.setAttribute(`aSeed`,new i(p,1));let h=new e({vertexShader:s,fragmentShader:c,uniforms:{uTime:{value:0},uDpr:{value:Math.min(window.devicePixelRatio||1,l.dprCap)}},transparent:!0,depthWrite:!1,blending:2});u.add(new r(m,h));let g=[];for(let e=0;e<l.linkCount;e++){let e=Math.floor(Math.random()*d),t=e,n=1/0;for(let r=0;r<12;r++){let r=Math.floor(Math.random()*d);if(r===e)continue;let i=f[e*3]-f[r*3],a=f[e*3+2]-f[r*3+2],o=i*i+a*a;o<n&&(n=o,t=r)}g.push(f[e*3],f[e*3+1],f[e*3+2],f[t*3],f[t*3+1],f[t*3+2])}let _=new a;_.setAttribute(`position`,new i(new Float32Array(g),3));let v=new n({color:65428,transparent:!0,opacity:.07});return u.add(new o(_,v)),{group:u,update:e=>{h.uniforms.uTime.value=e}}}export{l as buildNetwork};