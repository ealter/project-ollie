attribute vec4 a_position;
attribute vec2 a_texCoord;
 
 
#ifdef GL_ES
varying  mediump vec2 v_texCoord;
#else
varying vec2 v_texCoord;
#endif
 
void main()
{
//5
  gl_Position = a_position;
//6
  v_texCoord = a_texCoord;
}