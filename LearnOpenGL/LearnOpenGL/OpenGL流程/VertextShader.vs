attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

void main() {
  colorVarying = color;
  gl_Position = vec4(0.5216, 0.3725, 0.3725, 1.0);
}