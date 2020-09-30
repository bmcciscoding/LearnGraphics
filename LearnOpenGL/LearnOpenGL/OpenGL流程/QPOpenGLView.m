//
//  QPOpenGLView.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/28.
//

#import "QPOpenGLView.h"

#import "QPOpenGLProgram.h"


#define _GLLayer ((CAEAGLLayer *)self.layer)

@import GLKit;

@import OpenGLES;


typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;


@interface  QPOpenGLView ()

@property (nonatomic, assign) SenceVertex *vertices; // 顶点数组

@end

@implementation QPOpenGLView {
    CAEAGLLayer *_glLayer;
    GLuint _FBO;
    GLuint _renderBuffer;
    EAGLContext *_ctx;
    GLuint _program;
}


+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];

    }
    return self;
}

- (void)_init {
    self.opaque = NO;
    
    _GLLayer.drawableProperties = @{
        //kEAGLDrawablePropertyRetainedBacking: @(YES),
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
    
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_ctx];
    [self _createFBO];
    
}

- (void)drawTextture2D {


    // 将 UIImage 转换为 CGImageRef
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    CGImageRef cgImageRef = [image CGImage];
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);

    // 绘制图片
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);

    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glGenerateMipmap(GL_TEXTURE_2D);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);


    {
        self.vertices = malloc(sizeof(SenceVertex) * 4); // 4 个顶点
        self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上角
        self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下角
        self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}}; // 右上角
        self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}}; // 右下角
    }

    {

    }

    {
        // 获取 shader 中的参数，然后传数据进去
        GLuint positionSlot = glGetAttribLocation(_program, "Position");
        GLuint textureSlot = glGetUniformLocation(_program, "Texture");  // 注意 Uniform 类型的获取方式
        GLuint textureCoordsSlot = glGetAttribLocation(_program, "TextureCoords");
        // 将纹理 ID 传给着色器程序
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture);
        glUniform1i(textureSlot, 0);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1

        // 创建顶点缓存
        GLuint vertexBuffer;
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
        glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);

        // 设置顶点数据
        glEnableVertexAttribArray(positionSlot);
        glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));

        // 设置纹理数据
        glEnableVertexAttribArray(textureCoordsSlot);
        glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    }
}

- (void)drawTriangle {
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);

    {
        // pass value
        // x y z
        const float vertext[] = {
            -1.0, 1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0,

            -1.0, 1.0, 0.0,
            1.0, 1.0, 0.0,
            1.0, -1.0, 0.0,
        };
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertext), vertext, GL_STATIC_DRAW);
        GLint loc = glGetAttribLocation(_program, "pos");
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(loc);
    }

    {
        const float vertext[] = {
            1.0, 0.5, 0.0,
            1.0, 0.5, 0.0,
            1.0, 0.5, 0.0,

            0.0, 1.0, 0.5,
            0.0, 1.0, 0.5,
            0.0, 1.0, 0.5,
        };
        GLuint buffer;
        glGenBuffers(1, &buffer);
        glBindBuffer(GL_ARRAY_BUFFER, buffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertext), vertext, GL_STATIC_DRAW);
        GLint loc = glGetAttribLocation(_program, "color");
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(loc);
    }
}

- (void)_createFBO {
    // use pr0gram
    QPOpenGLProgram *program = [QPOpenGLProgram new];
    if ([program link]) {
        glUseProgram(program.currentProgram);
        _program = (GLuint)program.currentProgram;
    } else {
        NSAssert(NO, @"link fail");
    }
    
//    [self drawTriangle];
    [self drawTextture2D];
    
    // draw
    GLuint RBO;
    glGenRenderbuffers(1, &RBO);
    glBindRenderbuffer(GL_RENDERBUFFER, RBO);
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_GLLayer];
    
    GLuint FBO;
    glGenFramebuffers(1, &FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, FBO);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, RBO);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glClearColor(0, 1, 1, 0.2);
    glClear(GL_COLOR_BUFFER_BIT);
    //glDrawArrays(GL_LINE_STRIP, 0, 4);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
}

@end
