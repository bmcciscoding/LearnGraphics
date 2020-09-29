
attribute vec4 pos;
attribute vec4 color;

varying vec4 colorVarying;

void main(void) {
    colorVarying = color;
    gl_Position = pos;
    
}
