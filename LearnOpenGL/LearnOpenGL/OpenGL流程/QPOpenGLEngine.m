//
//  QPOpenGLEngine.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/27.
//

#import "QPOpenGLEngine.h"

@import OpenGLES;

@implementation QPOpenGLEngine {
    
    EAGLContext *_ctx;
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




@end
