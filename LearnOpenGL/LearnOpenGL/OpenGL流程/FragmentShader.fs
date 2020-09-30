
// triangle
//varying lowp vec4 colorVarying;
//void main(void) {
//    gl_FragColor = colorVarying;
////    gl_FragColor = vec4(0.4, 0.8, 0.5, 1);
//}

// texture2d

precision mediump float;

uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;

void main (void) {
    vec4 mask = texture2D(Texture, TextureCoordsVarying);
    gl_FragColor = vec4(mask.rgb, 1.0);
}
