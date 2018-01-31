//
//  ECLayerAnimationMaker.h
//  EasyCrop
//
//  Created by Leo Ni on 1/31/18.
//

#import <UIKit/UIKit.h>

@interface ECLayerAnimationMaker : NSObject

+ (CAAnimationGroup *)layerAnimationFromFrame:(CGRect)fromFrame
                                      toFrame:(CGRect)toFrame
                                 withDuration:(CGFloat)duration;

+ (CABasicAnimation *)layerAnimationFromPosition:(CGPoint)fromPosition
                                      toPosition:(CGPoint)toPosition
                                    withDuration:(CGFloat)duration;

+ (CABasicAnimation *)layerAnimationFromBounds:(CGRect)fromBounds
                                      toBounds:(CGRect)toBounds
                                  withDuration:(CGFloat)duration;

+ (CABasicAnimation *)layerAnimationFromPath:(CGPathRef)fromPath
                                      toPath:(CGPathRef)toPath
                                withDuration:(CGFloat)duration;

@end
