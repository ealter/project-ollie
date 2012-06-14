#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;
uniform sampler2D u_mask;
uniform float textureWidth;
uniform float textureHeight;

void main()
{
    vec2 texCoordTiled = vec2(v_texCoord.x*480.0/textureWidth, v_texCoord.y*320.0/textureHeight);
    vec4 texColor = texture2D(u_texture, texCoordTiled);
    vec4 maskColor = texture2D(u_mask, v_texCoord);
    vec4 finalColor = vec4(texColor.r, texColor.g, texColor.b, maskColor.r * texColor.a);
    //vec4 finalColor = vec4(1.0, maskColor.g, maskColor.b, 1.0);
    gl_FragColor = v_fragmentColor * finalColor;
}
