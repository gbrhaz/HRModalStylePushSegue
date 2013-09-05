//
//  ModalStylePushSegue.m
//  DeskJockeyWorkout
//
//  Created by Harry Richardson on 22/07/2013.
//  Copyright (c) 2013 Harry Richardson. All rights reserved.
//

#import "ModalStylePushSegue.h"
#import "QuartzCore/QuartzCore.h"

static NSTimeInterval const kTransitionDuration = 0.5f;

@interface ModalStylePushSegue()

@property (nonatomic, strong) UIViewController *sourceController;
@property (nonatomic, strong) UIViewController *destinationController;
@property (nonatomic, strong) UIViewController *tempController;

@property (nonatomic, strong) CALayer *currentLayer;
@property (nonatomic, strong) CALayer *nextLayer;

@end


@implementation ModalStylePushSegue

-(void)perform
{    
    self.sourceController = (UIViewController*)[self sourceViewController];
    self.destinationController = (UIViewController*)[self destinationViewController];
    self.tempController = [[UIViewController alloc] init];
    self.tempController.view = [[UIView alloc] initWithFrame:self.sourceController.navigationController.view.frame];
    
    self.currentLayer = [self snapshotLayerForView:self.sourceController.navigationController.view];
    
    [self.tempController.view.layer addSublayer:self.currentLayer];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.tempController.view];
    
    [self.sourceController.navigationController pushViewController:self.destinationController animated:NO];
    
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self.tempController.view removeFromSuperview];
        self.nextLayer = [self snapshotLayerForView:self.sourceController.navigationController.view];
        self.nextLayer.transform = CATransform3DTranslate(CATransform3DIdentity,
                                                          0.f,
                                                          CGRectGetHeight(self.nextLayer.frame),
                                                          0.f);
        
        [self.sourceController.navigationController.view.layer addSublayer:self.currentLayer];
        [self.sourceController.navigationController.view.layer addSublayer:self.nextLayer];
        
        [CATransaction flush];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DTranslate(CATransform3DIdentity, 0.f,
                                                                                   0.f, 0.f)];
        animation.duration = kTransitionDuration;
        animation.delegate = self;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFilterLinear;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        [self.nextLayer addAnimation:animation forKey:nil];
    });
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    [self.currentLayer removeFromSuperlayer];
    [self.nextLayer removeFromSuperlayer];
}

- (CALayer*)snapshotLayerForView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CALayer *snapshotLayer = [CALayer layer];
    snapshotLayer.frame = view.frame;
    snapshotLayer.contents = (id)snapshot.CGImage;
    return snapshotLayer;
}

@end
