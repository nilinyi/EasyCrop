//
//  ECGraphicsUtility.m
//  EasyCrop
//
//  Created by Leo Ni on 1/31/18.
//

#import "ECGraphicsUtility.h"

@implementation ECGraphicsUtility

+ (CGAffineTransform)transformMatrixFromRect:(CGRect)fromRect toRect:(CGRect)toRect {
    CGAffineTransform trans1 = CGAffineTransformMakeTranslation(-fromRect.origin.x,
                                                                -fromRect.origin.y);
    CGAffineTransform scale = CGAffineTransformMakeScale(toRect.size.width/fromRect.size.width,
                                                         toRect.size.height/fromRect.size.height);
    CGAffineTransform trans2 = CGAffineTransformMakeTranslation(toRect.origin.x, toRect.origin.y);
    return CGAffineTransformConcat(CGAffineTransformConcat(trans1, scale), trans2);
}

+ (CGRect)aspectFitSize:(CGSize)size inRect:(CGRect)inRect {
    CGFloat sizeRatio = size.height / size.width;
    CGFloat inRectRatio = CGRectGetHeight(inRect) / CGRectGetWidth(inRect);
    CGFloat scale = 1.0;
    if (sizeRatio > inRectRatio) {
        // rect is longer, so stretch rect's h
        scale = CGRectGetHeight(inRect) / size.height;
    } else {
        // rect is shorter, so stretch rect's w
        scale = CGRectGetWidth(inRect) / size.width;
    }
    CGAffineTransform scaleT = CGAffineTransformMakeScale(scale, scale);
    CGRect newRect = (CGRect){CGPointZero, size};
    newRect = CGRectApplyAffineTransform(newRect, scaleT);

    CGFloat tx = CGRectGetMidX(inRect) - CGRectGetMidX(newRect);
    CGFloat ty = CGRectGetMidY(inRect) - CGRectGetMidY(newRect);
    CGAffineTransform translationT = CGAffineTransformMakeTranslation(tx, ty);
    newRect = CGRectApplyAffineTransform(newRect, translationT);

    return newRect;
}

+ (CGRect)aspectFillSize:(CGSize)size inRect:(CGRect)inRect {
    CGFloat sizeRatio = size.height / size.width;
    CGFloat inRectRatio = CGRectGetHeight(inRect) / CGRectGetWidth(inRect);
    CGFloat scale = 1.0;
    if (sizeRatio > inRectRatio) {
        // rect is longer, so stretch rect's w
        scale = CGRectGetWidth(inRect) / size.width;
    } else {
        // rect is longer, so stretch rect's h
        scale = CGRectGetHeight(inRect) / size.height;
    }
    CGAffineTransform scaleT = CGAffineTransformMakeScale(scale, scale);
    CGRect newRect = (CGRect){CGPointZero, size};
    newRect = CGRectApplyAffineTransform(newRect, scaleT);

    CGFloat tx = CGRectGetMidX(inRect) - CGRectGetMidX(newRect);
    CGFloat ty = CGRectGetMidY(inRect) - CGRectGetMidY(newRect);
    CGAffineTransform translationT = CGAffineTransformMakeTranslation(tx, ty);
    newRect = CGRectApplyAffineTransform(newRect, translationT);

    return newRect;
}

@end
