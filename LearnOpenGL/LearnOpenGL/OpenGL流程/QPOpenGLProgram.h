//
//  QPOpenGLProgram.h
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/27.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/gltypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface QPOpenGLProgram : NSObject

@property (nonatomic, copy) NSArray<NSString*> *logs;

- (void)bindAttrbuteWithName:(NSString *)name value:(id)value;

@property (nonatomic, assign, readonly) GLuint currentProgram;

- (BOOL)link;

@end

NS_ASSUME_NONNULL_END
