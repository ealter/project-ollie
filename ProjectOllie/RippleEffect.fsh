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
    float len = length(p);
    vec2 uv = tc + (p/len)*cos(len*invdistance-u_time*speed);
    vec3 col = texture2D(u_texture, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}