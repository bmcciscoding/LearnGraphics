//
//  QPOpenGLView.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/28.
//

#import "QPOpenGLView.h"


#define _GLLayer ((CAEAGLLayer *)self.layer)

@import OpenGLES;


@implementation QPOpenGLView {
    CAEAGLLayer *_glLayer;
    GLuint _FBO;
    GLuint _renderBuffer;
    EAGLContext *_ctx;
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
    self.opaque = YES;
    
    _GLLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking: @(NO),
        kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
    };
    
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_ctx];
    [self _createFBO];
    
}

- (void)_createFBO {
    
    glGenFramebuffers(1, &_FBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _FBO);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_GLLayer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    glClearColor(0, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_ctx presentRenderbuffer:GL_RENDERBUFFER];
    
}


@end
