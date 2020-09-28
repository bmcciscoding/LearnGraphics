//
//  QPOpenGLProgram.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/27.
//

#import "QPOpenGLProgram.h"
#import <OpenGLES/ES2/gl.h>

@implementation QPOpenGLProgram {
    
    GLuint _program, _vertexShader, _fragmentShader;
    
    NSMutableArray<NSString *> *_logs;
}

#define _SHADER_CODE(name, type) [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:type] encoding:NSUTF8StringEncoding error:nil];

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _program = glCreateProgram();
        _logs = @[].mutableCopy;
        
        NSString *vs = _SHADER_CODE(@"VertextShader", @"vs");
        [self complieShader:&_vertexShader type:GL_VERTEX_SHADER code:vs];
        NSString *fs = _SHADER_CODE(@"FragmentShader", @"fs");
        [self complieShader:&_fragmentShader type:GL_FRAGMENT_SHADER code:fs];
        
        glAttachShader(_program, _vertexShader);
        glAttachShader(_program, _fragmentShader);
        
    }
    return self;
}


- (BOOL)complieShader:(GLuint *)shader type:(GLenum)type code:(NSString *)code {
    NSParameterAssert(code != nil);
    GLint status;
    const GLchar *sourceCode;
    sourceCode = (GLchar *)[code UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &sourceCode, NULL);
    glCompileShader(*shader);
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status != GL_TRUE) {
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSString *logStr = [NSString stringWithFormat:@"%s", log];
        if (logStr) {
            [_logs insertObject:logStr atIndex:0];
            NSLog(@"%@", logStr);
        }
        free(log);
    }
    return status == GL_TRUE;
}


- (BOOL)link {
    /*
     当 program 被 link 之后,该 program 对应的 shader 可以被修改、重新编译、 detach、attach 其他 shader 等操作,而这些操作不会影响 link 的 log 以及 program 的可执行文件。
     */
    GLint status;
    glLinkProgram(_program);
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        GLint logLength;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSString *logStr = [NSString stringWithFormat:@"%s", log];
        if (logStr) {
            [_logs insertObject:logStr atIndex:0];
            NSLog(@"%@", logStr);
        }
    }
    return status == GL_TRUE;
}

- (void)use {
    glUseProgram(_program);
}

#pragma mark - Setter & Getter
- (NSArray<NSString *> *)logs {
    return [_logs copy];
}

- (uint)currentProgram {
    return _program;
}

@end
