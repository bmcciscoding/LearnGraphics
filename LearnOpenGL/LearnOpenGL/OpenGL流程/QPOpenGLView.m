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
        //kEAGLDrawablePropertyRetainedBacking: @(YES),
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
    
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_ctx];
    [self _createFBO];
    
}

- (void)_createFBO {
    // use pr0gram
    QPOpenGLProgram *program = [QPOpenGLProgram new];
    if ([program link]) {
        glUseProgram(program.currentProgram);
    }
    
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
        GLint loc = glGetAttribLocation(program.currentProgram, "pos");
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
        GLint loc = glGetAttribLocation(program.currentProgram, "color");
        glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(loc);
    }
    
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
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
}

@end
