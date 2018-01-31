//
//  ECLayerAnimationMaker.m
//  EasyCrop
//
//  Created by Leo Ni on 1/31/18.
//

#import "ECLayerAnimationMaker.h"

@implementation ECLayerAnimationMaker

+ (CAAnimationGroup *)layerAnimationFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame  withDuration:(CGFloat)duration {
    CGPoint startPoint = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMidY(fromFrame));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(toFrame), CGRectGetMidY(toFrame));
    CGRect startBounds = (CGRect){CGPointZero, fromFrame.size};
    CGRect endBounds = (CGRect){CGPointZero, toFrame.size};

    CABasicAnimation * positionAnimation = [self layerAnimationFromPosition:startPoint toPosition:endPoint withDuration:duration];
    CABasicAnimation * boundsAnimation = [self layerAnimationFromBounds:startBounds toBounds:endBounds withDuration:duration];

    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.animations = @[positionAnimation, boundsAnimation];
    group.duration = duration;

    return group;
}

+ (CABasicAnimation *)layerAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition  withDuration:(CGFloat)duration {
    CABasicAnimation * positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    positionAnimation.toValue = [NSValue valueWithCGPoint:toPosition];
    positionAnimation.duration = duration;
    return positionAnimation;
}

+ (CABasicAnimation *)layerAnimationFromBounds:(CGRect)fromBounds toBounds:(CGRect)toBounds  withDuration:(CGFloat)duration {
    CABasicAnimation * boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:fromBounds];
    boundsAnimation.toValue = [NSValue valueWithCGRect:toBounds];
    boundsAnimation.duration = duration;
    return boundsAnimation;
}

+ (CABasicAnimation *)layerAnimationFromPath:(CGPathRef)fromPath toPath:(CGPathRef)toPath  withDuration:(CGFloat)duration {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id _Nullable)(fromPath);
    pathAnimation.toValue = (__bridge id _Nullable)(toPath);
    pathAnimation.duration = duration;
    return pathAnimation;
}

@end
