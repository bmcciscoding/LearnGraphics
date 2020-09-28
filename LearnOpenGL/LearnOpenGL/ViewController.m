//
//  ViewController.m
//  LearnOpenGL
//
//  Created by qiupeng on 2020/9/27.
//

#import "ViewController.h"

#import "QPOpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    QPOpenGLView *glView = [[QPOpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
    
    
}


@end
