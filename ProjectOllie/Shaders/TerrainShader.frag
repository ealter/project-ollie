#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;
uniform sampler2D u_texture;
uniform sampler2D u_mask;
uniform float textureWidth;
uniform float textureHeight;
uniform float screenWidth;
uniform float screenHeight;

void main()
{
<<<<<<< HEAD
    vec4 texColor = texture2D(u_texture, v_texCoord*4.0);
=======

    vec2 texCoordTiled = vec2(v_texCoord.x, v_texCoord.y);
    vec4 texColor = texture2D(u_texture, v_texCoord);
>>>>>>> afcd8fde3767ea75b18d985d93f33139d35e732b
    vec4 maskColor = texture2D(u_mask, v_texCoord);
    vec4 finalColor = vec4(texColor.r, texColor.g, texColor.b, maskColor.r * texColor.a);
    gl_FragColor = v_fragmentColor * finalColor;

}
