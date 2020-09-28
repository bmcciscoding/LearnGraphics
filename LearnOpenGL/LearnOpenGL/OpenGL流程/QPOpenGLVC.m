//
//  QPOpenGLVC.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/28.
//

#import "QPOpenGLVC.h"


#import "QPOpenGLEngine.h"

@import OpenGLES;

@interface QPOpenGLVC ()

@property (nonatomic, strong) GLKView *contentView;

@property (nonatomic, strong) QPOpenGLEngine *engine;

@property (nonatomic, strong) CAEAGLLayer *contentLayer;

@end

@implementation QPOpenGLVC {
    EAGLContext *_ctx;
    CAEAGLLayer *_cLayer;
    
    GLuint _renderBuffer;
    GLuint _fbo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    _cLayer = [CAEAGLLayer layer];
    _cLayer.frame = self.view.bounds;
    _cLayer.opaque = YES;
    [self.view.layer addSublayer:_cLayer];
    
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    [_ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:_cLayer];
    
    glGenFramebuffers(1, &_fbo);
    glBindRenderbuffer(GL_FRAMEBUFFER, _fbo);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    
    
    
}

@end
