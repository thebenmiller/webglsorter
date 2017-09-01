varying vec2 vUv;
uniform float iGlobalTime;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform bool iEvenTick;
uniform bool iHorizVert;
uniform float iRes;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 compareY(vec3 color1, vec3 color2, vec3 color3, float y){

  vec3 hsv1 = rgb2hsv(color1);
  vec3 hsv2 = rgb2hsv(color2);
  vec3 hsv3 = rgb2hsv(color3);
  float c1 = hsv1.x;
  float c2 = hsv2.x;
  float c3 = hsv3.x;

  if(iEvenTick){
    if(y == iRes) return color2;
    if (mod(y, 2.0)==0.0){
      if(c3 > c2){
        return color3;
      }else{
        return color2;
      }
    }else{
      if(c1 < c2){
        return color1;
      }else{
        return color2;
      }
    }
  }else{
    if(y == 0.0) return color2;
    if (mod(y, 2.0)==0.0){
      if(c1 < c2){
        return color1;
      }else{
        return color2;
      }
    }else{
      if(c3 > c2){
        return color3;
      }else{
        return color2;
      }
    }
  }
}

vec3 compareX(vec3 color1, vec3 color2, vec3 color3, float x){

  vec3 hsv1 = rgb2hsv(color1);
  vec3 hsv2 = rgb2hsv(color2);
  vec3 hsv3 = rgb2hsv(color3);
  float c1 = hsv1.y;
  float c2 = hsv2.y;
  float c3 = hsv3.y;

  if(iEvenTick){
    if(x == iRes) return color2;
    if (mod(x, 2.0)==0.0){
      if(c3 > c2){
        return color3;
      }else{
        return color2;
      }
    }else{
      if(c1 < c2){
        return color1;
      }else{
        return color2;
      }
    }
  }else{
    if(x == 0.0) return color2;
    if (mod(x, 2.0)==0.0){
      if(c1 < c2){
        return color1;
      }else{
        return color2;
      }
    }else{
      if(c3 > c2){
        return color3;
      }else{
        return color2;
      }
    }
  }
}


vec3 sample(sampler2D texture, vec2 uv) {
  vec3 pixel = texture2D(texture, uv).rgb;

  // vec3 tl = texture2D(texture, vec2(-1.0/iRes,-1.0/iRes)+uv).rgb;
  vec3 t = texture2D(texture, vec2(0,-1.0/iRes)+uv).rgb;
  // vec3 tr = texture2D(texture, vec2(1.0/iRes,-1.0/iRes)+uv).rgb;
  vec3 l = texture2D(texture, vec2(-1.0/iRes,0)+uv).rgb;
  vec3 r = texture2D(texture, vec2(1.0/iRes,0)+uv).rgb;
  // vec3 bl = texture2D(texture, vec2(-1.0/iRes,1.0/iRes)+uv).rgb;
  vec3 b = texture2D(texture, vec2(0,1.0/iRes)+uv).rgb;
  // vec3 br = texture2D(texture, vec2(1.0/iRes,1.0/iRes)+uv).rgb;

  // vec3 v1 = compare(pixel, t);
  // vec3 v2 = compare(pixel, b);
  // vec3 v = compare(v1,v2);
  // vec3 h1 = compare(pixel, l);
  // vec3 h2 = compare(pixel, r);
  // vec3 h = compare(h1, h2);
  // vec3 final = compare(h,v);

  if(iHorizVert){
    return compareX(l, pixel, r, floor(gl_FragCoord.x));
  }else{
    return compareY(t, pixel, b, floor(gl_FragCoord.y));
  }

}

void main() {
  if (iGlobalTime == 0.){
    gl_FragColor.rgba = vec4(sample( iChannel0, vUv), 1.0);
  }else{
    gl_FragColor.rgba = vec4(sample( iChannel1, vUv), 1.0);
  }
}
