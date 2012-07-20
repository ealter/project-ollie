
#ifdef GL_ES
precision lowp float;
#endif												

uniform vec4 u_color;

varying vec2 v_texCoord;							
uniform sampler2D u_texture;						

void main()											
{
    gl_FragColor = vec4( u_color.rgb,                                    // RGB from uniform	
                         u_color.a * texture2D(u_texture, v_texCoord).a  // A from texture & uniform	
)

