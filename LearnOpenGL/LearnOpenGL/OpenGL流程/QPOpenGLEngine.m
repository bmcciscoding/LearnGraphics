//
//  QPOpenGLEngine.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/27.
//

#import "QPOpenGLEngine.h"

@implementation QPOpenGLEngine {
    
    EAGLContext *_ctx;
    
    GLKView *_content;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // init context
        EAGLContext *ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        NSParameterAssert(ctx);
        _ctx = ctx;
        
    }
    return self;
}

- (void)bindContent:(GLKView *)content {
    _content = content;
    _content.context = _ctx;
    [EAGLContext setCurrentContext:_ctx];
    
    
    
}




@end
