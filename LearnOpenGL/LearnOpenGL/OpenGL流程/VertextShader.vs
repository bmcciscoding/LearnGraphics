// triangle
//attribute vec4 pos;
//attribute vec4 color;
//
//varying vec4 colorVarying;
//
//void main(void) {
//    colorVarying = color;
//    gl_Position = pos;
//
//}


// texture2d
attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;

void main (void) {
    gl_Position = Position;
    TextureCoordsVarying = TextureCoords;
}
