//
//  EMCropBoxFrameConverter.m
//  EMCropBoxFrameConverter
//
//  Created by Leo Ni on 6/19/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import "EMCropBoxFrameConverter.h"

@implementation EMCropBoxFrameConverter {
    UIEdgeInsets _extendedAreaInsets;
    UIEdgeInsets _lineInsets;
    UIEdgeInsets _extendedAreaOutsets;
    UIEdgeInsets _lineOutsets;
}

- (instancetype)initWithExtendedAreaInsets:(UIEdgeInsets)extendedAreaInsets lineInsets:(UIEdgeInsets)lineInsets {
    if (self = [super init]) {
        _extendedAreaInsets = extendedAreaInsets;
        _extendedAreaOutsets = [self p_invertedEdgeInsets:_extendedAreaInsets];
        _lineInsets = lineInsets;
        _lineOutsets = [self p_invertedEdgeInsets:_lineInsets];
    }
    return self;
}

- (CGPoint)minimumOriginOfCropBoxWithExtendedAreaAndLineWidthInArea:(CGRect)bigArea {
    CGPoint minimumOriginWithLineWidth = [self minimumOriginOfCropBoxWithLineWidthInArea:bigArea];
    return CGPointMake(minimumOriginWithLineWidth.x + _extendedAreaOutsets.left, minimumOriginWithLineWidth.y + _extendedAreaOutsets.top);
}

- (CGPoint)minimumOriginOfCropBoxWithLineWidthInArea:(CGRect)bigArea {
    return bigArea.origin;
}

- (CGPoint)minimumOriginOfCropBoxInArea:(CGRect)bigArea {
    CGPoint minimumOriginWithLineWidth = [self minimumOriginOfCropBoxWithLineWidthInArea:bigArea];
    return CGPointMake(minimumOriginWithLineWidth.x + _lineInsets.left, minimumOriginWithLineWidth.y + _lineInsets.top);
}

- (CGPoint)maximumOriginOfCropBoxWithExtendedAreaAndLineWidthInArea:(CGRect)bigArea {
    CGPoint maximumOriginWithLineWidth = [self maximumOriginOfCropBoxWithLineWidthInArea:bigArea];
    return CGPointMake(maximumOriginWithLineWidth.x + _extendedAreaOutsets.left, maximumOriginWithLineWidth.y + _extendedAreaOutsets.top);
}

- (CGPoint)maximumOriginOfCropBoxWithLineWidthInArea:(CGRect)bigArea {
    CGFloat maxX = bigArea.origin.x + (bigArea.size.width - self.cropBoxFrameWithLineWidth.size.width);
    CGFloat maxY = bigArea.origin.y + (bigArea.size.height - self.cropBoxFrameWithLineWidth.size.height);
    return CGPointMake(maxX, maxY);
}

- (CGPoint)maximumOriginOfCropBoxInArea:(CGRect)bigArea {
    CGPoint maximumOriginWithLineWidth = [self maximumOriginOfCropBoxWithLineWidthInArea:bigArea];
    return CGPointMake(maximumOriginWithLineWidth.x + _lineInsets.left, maximumOriginWithLineWidth.y + _lineInsets.top);
}

# pragma mark - Setters
- (void)setCropBoxFrame:(CGRect)cropBoxFrame {
    if (CGRectEqualToRect(cropBoxFrame, _cropBoxFrame) || CGRectIsNull(cropBoxFrame)) {
        return;
    }
    _cropBoxFrame = cropBoxFrame;
    _cropBoxFrameWithLineWidth = UIEdgeInsetsInsetRect(_cropBoxFrame, _lineOutsets);
    _cropBoxFrameWithExtendedAreaAndLineWidth = UIEdgeInsetsInsetRect(_cropBoxFrameWithLineWidth, _extendedAreaOutsets);
}

- (void)setCropBoxFrameWithLineWidth:(CGRect)cropBoxFrameWithLineWidth {
    if (CGRectEqualToRect(cropBoxFrameWithLineWidth, _cropBoxFrameWithLineWidth) || CGRectIsNull(cropBoxFrameWithLineWidth)) {
        return;
    }
    _cropBoxFrameWithLineWidth = cropBoxFrameWithLineWidth;
    _cropBoxFrame = UIEdgeInsetsInsetRect(_cropBoxFrameWithLineWidth, _lineInsets);
    _cropBoxFrameWithExtendedAreaAndLineWidth = UIEdgeInsetsInsetRect(_cropBoxFrameWithLineWidth, _extendedAreaOutsets);
}

- (void)setCropBoxFrameWithExtendedAreaAndLineWidth:(CGRect)cropBoxFrameWithExtendedAreaAndLineWidth {
    if (CGRectEqualToRect(cropBoxFrameWithExtendedAreaAndLineWidth, _cropBoxFrameWithExtendedAreaAndLineWidth) || CGRectIsNull(cropBoxFrameWithExtendedAreaAndLineWidth)) {
        return;
    }
    _cropBoxFrameWithExtendedAreaAndLineWidth = cropBoxFrameWithExtendedAreaAndLineWidth;
    _cropBoxFrameWithLineWidth = UIEdgeInsetsInsetRect(_cropBoxFrameWithExtendedAreaAndLineWidth, _extendedAreaInsets);
    _cropBoxFrame = UIEdgeInsetsInsetRect(_cropBoxFrameWithLineWidth, _lineInsets);
}

# pragma mark - Private
- (UIEdgeInsets)p_invertedEdgeInsets:(UIEdgeInsets)edgeInsets {
    return UIEdgeInsetsMake(-edgeInsets.top, -edgeInsets.left, -edgeInsets.bottom, -edgeInsets.right);
}

@end
