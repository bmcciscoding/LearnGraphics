//
//  QPOpenGLView.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/28.
//

#import "QPOpenGLView.h"

#import "QPOpenGLProgram.h"


#define _GLLayer ((CAEAGLLayer *)self.layer)

@import OpenGLES;

@implementation QPOpenGLView {
    CAEAGLLayer *_glLayer;
    GLuint _FBO;
    GLuint _renderBuffer;
    EAGLContext *_ctx;
    QPOpenGLProgram *_program;
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
        kEAGLDrawablePropertyRetainedBacking: @(YES),
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
    
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_ctx];
    [self _createFBO];
    
}

- (void)_createFBO {
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_GLLayer];
    
    glGenFramebuffers(1, &_FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    QPOpenGLProgram *program = [QPOpenGLProgram new];
    if ([program link]) {
        glUseProgram(program.currentProgram);
    }
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glClearColor(0, 1, 1, 0.2);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // x y z
    const float vertext[] = {
        0.0, 0.0, 0.0,
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
    };
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertext), vertext, GL_STATIC_DRAW);
    
    {
        GLint loc = glGetAttribLocation(program.currentProgram, "pos");
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(loc);
    }

    
    {
        GLint loc = glGetAttribLocation(program.currentProgram, "color");
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(loc);
    }


    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
}

@end
