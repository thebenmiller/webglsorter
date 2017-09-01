const THREE = require('three');
const glslify = require('glslify');

const frustumSize = 512;
const aspect = 1.0;

const camera = new THREE.OrthographicCamera(
  frustumSize * aspect / -2,
  frustumSize * aspect / 2,
  frustumSize / 2,
  frustumSize / -2,
  0,
  2000
);
const scene = new THREE.Scene();
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(window.devicePixelRatio);
renderer.setSize(0, 0);
renderer.setClearColor(0x000000, 1);

document.body.appendChild(renderer.domElement);
renderer.domElement.id = 'canvas';

//our basic full-screen application and render loop
let time = 0,
  i = 0;

//load up a test image
const imageTexture = new THREE.TextureLoader().load('baboon.png', texture => {
  texture.minFilter = THREE.NearestFilter;
  texture.magFilter = THREE.NearestFilter;
  mat.uniforms.iRes.value = texture.image.width;
  renderer.setSize(texture.image.width, texture.image.width);
  render();
});

let bufferA = new THREE.WebGLRenderTarget(512, 512, {
  minFilter: THREE.NearestFilter,
  magFilter: THREE.NearestFilter,
  format: THREE.RGBAFormat,
  type: THREE.FloatType
});

let bufferB = new THREE.WebGLRenderTarget(512, 512, {
  minFilter: THREE.NearestFilter,
  magFilter: THREE.NearestFilter,
  format: THREE.RGBAFormat,
  type: THREE.FloatType
});

//here we create a custom shader with glslify
//note USE_MAP is needed to get a 'uv' attribute
const mat = new THREE.ShaderMaterial({
  vertexShader: glslify('./vert.glsl'),
  fragmentShader: glslify('./frag.glsl'),
  uniforms: {
    iChannel0: { type: 't', value: imageTexture },
    iChannel1: { type: 't', value: bufferA.texture },
    iGlobalTime: { type: 'f', value: 0 },
    iEvenTick: { type: 'b', value: true },
    iHorizVert: { type: 'b', value: true },
    iRes: { type: 'f', value: 1 }
  },
  defines: {
    USE_MAP: ''
  }
});

const geo = new THREE.PlaneGeometry(512.0, 512.0);
const plane = new THREE.Mesh(geo, mat);
scene.add(plane);

var render = function() {
  time += i / 1000;
  mat.uniforms.iGlobalTime.value = time;
  mat.uniforms.iEvenTick.value = i % 2 == 0;
  mat.uniforms.iHorizVert.value = Math.floor(i / 2) % 2 == 0;

  renderer.render(scene, camera, bufferB, true);

  const t = bufferA;
  bufferA = bufferB;
  bufferB = t;
  // plane.material.map = bufferB.texture;
  mat.uniforms.iChannel1.value = bufferA.texture;

  renderer.render(scene, camera);
  requestAnimationFrame(render);
  // setTimeout(render, 500);
  i++;
};
