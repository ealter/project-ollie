#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;
uniform sampler2D u_texture;
uniform float u_time;

// 1
uniform float speed;
uniform float invdistance;//higher = smaller distance
void main()
{
    vec2 tc = v_texCoord;
    vec2 p = -1.0+2.0*tc;
    float len = max(length(p),pow(length(p),15.0));
    vec2 uv = tc + (p/len/80.0)*cos(len*invdistance-u_time*speed);
    vec4 col = texture2D(u_texture, uv);
    gl_FragColor = col;
}