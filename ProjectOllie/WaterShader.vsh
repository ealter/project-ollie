attribute vec4 a_position;
attribute vec2 a_texCoord;
 

varying  mediump vec2 v_texCoord;

void main()
{
//5
  gl_Position = a_position;
//6
  v_texCoord = a_texCoord;
}