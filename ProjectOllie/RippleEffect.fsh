#ifdef GL_ES
precision lowp float;
#endif

varying lowp vec2 v_texCoord;
uniform sampler2D u_texture;

//assigned values
uniform float u_time;
uniform float lifetime;
uniform float speed;
uniform float invdistance;//higher = smaller distance
uniform float originX;
uniform float originY;

void main()
{
    
    vec2 origin = vec2(originX, originY);
    vec2 tc     = v_texCoord;
    vec2 p      = tc + origin;
    float len   = length(p);
    vec2 amp    = p/max(len*5.0,pow(len*5.0,2.0))*.2;
    
    amp = amp * (lifetime - u_time)/lifetime;
    
    vec2 uv = tc + (amp)*cos(len*invdistance-u_time*speed);
    vec4 col = texture2D(u_texture, uv);
     
    gl_FragColor = texture2D(u_texture,v_texCoord);
}