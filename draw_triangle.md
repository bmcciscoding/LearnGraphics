# 画一个三角形
看了很多网上的文章，有些写得很详细，有些写得比较零散，对于作为零基础的我很难把握OpenGL 的大局观。经过自己的摸索，自我总结一番，决定从画一个三角形开始。希望对想入门了解 OpenGL 的有所帮助。注意，本文不会涉及一些原理解释，只是操作步骤，目的为了快速使用 OpenGL，形成正反馈。

来吧，show the code。

#### 一、初始化

首先，定一个自定义的 View

```Objective-C
@interface QPOpenGLView : UIView
@end
```

并且将其layerClass，改为 CAEAGLLayer

```Objective-C
+ (Class)layerClass {
    return [CAEAGLLayer class];
}
```

重写 initWithFrame 方法

```Objective-C
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

```

之后我们 _init 来实现 OpenGL 的工作流程。

#### 二、编写着色器

初始化的工作完成之后，思考画一个三角形，需要分为几步？

1. 确定三个顶点的坐标

2. 确定三角形的颜色

要实现这两部个步骤，OpenGL 2.0 版本是通过[ glsl](https://www.khronos.org/registry/OpenGL/specs/es/2.0/GLSL_ES_Specification_1.00.pdf) 自己的语言来实现的，可以先理解为 C 语言，也有变量，逻辑控制之类的概念。

现在提到第一个概念是**顶点着色器**，它是负责记录顶点的信息

```C
attribute vec4 pos; // 三角形的顶点
attribute vec4 color; // 三角形的颜色
varying vec4 colorVarying; // 顶点着色器和片段着色器之间传递变量
void main(void) { // 入口
    colorVarying = color; // 传递颜色
    gl_Position = pos; // gl 开头是 glsl 的内置变量 记录顶点位置
}
```

在上面的代码提到了**片段着色器**，是负责渲染颜色

```C
varying lowp vec4 colorVarying; // 顶点着色器传过来的颜色
void main(void) {
    gl_FragColor = colorVarying; // gl 开头是 glsl 的内置变量 记录颜色
}
```

好了，当我们实现了这两个着色器 glsl 之后，最核心的部分已经完成，剩下的则是一些流程上的代码。

总结 OpenGL 的工作流程就是，外部提供数据，传递给着色器，着色器工作完成之后，渲染出画面。

#### 三、串联流程

这里需要使用 OpenGL 的API，都是已 gl 开头，C 风格的样式。

剩下的流程包括以下几步：

1. 编译，链接，使用着色器

2. 传递数据给着色器

3. 绘制

着色器作为语言，是有一个自己的程序的。

```Objective-C
GLuint program = glCreateProgram(); // 创建程序
GLuint vertex_shader = glCreateShader(GL_VERTEX_SHADER); // 创建顶点着色器
NSString *vertex_shader_code = (GLchar *)[vertex_shader_string UTF8String] // 从 bundle 加载顶点着色器的代码
glShaderSource(vertex_shader, 1, &vertex_shader_code, NULL); // 绑定代码到顶点着色器
glCompileShader(vertex_shader)  // 编译顶点着色器

GLuint fragment_shader = glCreateShader(GL_FRAGMENT_SHADER); // 创建片段着色器
NSString *fragment_shader_code = (GLchar *)[fragment_shader_string UTF8String] // 从 bundle 加载片段着色器的代码
glShaderSource(fragment_shader, 1, &fragment_shader_code, NULL); // 绑定代码到片段着色器
glCompileShader(frgment_shader)  // 编译片段着色器

glAttachShader(program, vertex_shader); // 附着顶点着色器到程序上
glAttachShader(program, fragment_shader); // 附着片段着色器程序上

glLinkProgram(program); // 链接程序
glUseProgram(program)  // 使用程序
```

着色器能够使用了，我们需要把数据传递给着色器，需要通过缓存对象。可能理解为我们把数据放进了一个篮子，然后着色器把数据从这个篮子取走。

![](https://secure-static.wolai.com/static/s5WtsHwYFWfybak5PQuq4d/image.png)

![](https://secure-static.wolai.com/static/qU4CCPrSBeYNxqtN5WLBzX/image.png)

OpenGL 使用了右手坐标系统，中心坐标为（0，0，0）

```Objective-C
// 定义位置信息
const float position[] = {
  -1.0, 1.0, 0.0, // 左上角
  -1.0, -1.0, 0.0, // 左下角
  1.0, -1.0, 0.0, // 右下角
};

 GLuint buffer; // 定义缓存
 glGenBuffers(1, &buffer); // gen生成缓存
 glBindBuffer(GL_ARRAY_BUFFER, buffer); //bing 绑定缓存类型
 glBufferData(GL_ARRAY_BUFFER, 
             sizeof(vertext), 
             vertext, 
             GL_STATIC_DRAW); // 将数据放入缓存
 
 // 传递数据给 pos 变量
 GLint loc = glGetAttribLocation(program, // 获取顶点着色器的位置变量到位置
                                 "pos");  // 注意命名要一致
 glVertexAttribPointer(loc, 
                       3, 
                       GL_FLOAT, 
                       GL_FALSE, 
                       3 * sizeof(float), 
                       (void*)0); // 赋值到该变量
 glEnableVertexAttribArray(loc); // 激活使用
 
 // 传递数据给 color 变量
 GLint loc = glGetAttribLocation(program, 
                                 "color"); // 获取顶点着色器的颜色变量到位置
 glVertexAttribPointer(loc, 
                       3, 
                       GL_FLOAT, 
                       GL_FALSE, 
                       3 * sizeof(float), 
                       (void*)0); // 赋值到该变量
 glEnableVertexAttribArray(loc);  //激活使用
```

数据传递完成后，开始进行绘制

```Objective-C
// 创建上下文环境
EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
[EAGLContext setCurrentContext:context];

// 创建 渲染缓存对象
GLuint RBO;
glGenRenderbuffers(1, &RBO);
glBindRenderbuffer(GL_RENDERBUFFER, RBO);
[context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.layer];

// 创建 帧缓存对象
GLuint FBO;
glGenFramebuffers(1, &_FBO);
glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
// 讲 RBO 附加都 FBO
glFramebufferRenderbuffer(GL_FRAMEBUFFER, 
                          GL_COLOR_ATTACHMENT0, 
                          GL_RENDERBUFFER, 
                          RBO);

// 绘制
glViewport(0, 0, self.frame.size.width, self.frame.size.height);
glClearColor(0, 1, 1, 0.2);
glClear(GL_COLOR_BUFFER_BIT);
glDrawArrays(GL_TRIANGLES, 0, 3);

[context presentRenderbuffer:GL_RENDERBUFFER];

```

帧缓存对象 FBO可以理解为，OpenGL 渲染的时候，FBO里有什么，即渲染什么。

#### 四、总结

到这里，一个简单都三角形就画好了。写得并不是十分详细，也没有给出完整到解释。只是作为了解OpenGL 工作流程。当然，OpenGL还有更复杂到流程，例如数据读取还有哪些方式，帧缓存还可以包含哪些东西等等。

![](https://secure-static.wolai.com/static/8VDqQkVTFUmPF12gofJdys/image.png)
