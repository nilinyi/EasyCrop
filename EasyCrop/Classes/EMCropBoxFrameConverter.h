//
//  EMCropBoxFrameConverter.h
//  EMCropBoxFrameConverter
//
//  Created by Leo Ni on 6/19/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 因为cropBox的构成是从内到外由 1.内部图片显示区域, 2.图片外侧边缘线 3.边缘线外侧的延展触摸区 所构成的. 该类可以方便地根据其中任何一个矩形的frame计算出其他矩形的frame.
 */
@interface EMCropBoxFrameConverter : NSObject
@property (nonatomic, readwrite, assign) CGRect cropBoxFrameWithExtendedAreaAndLineWidth;
@property (nonatomic, readwrite, assign) CGRect cropBoxFrameWithLineWidth;
@property (nonatomic, readwrite, assign) CGRect cropBoxFrame;

/**
 Return a converter instance. Set any property of it will change the rest accordinly, here comes the name "Converter".

 @param extendedAreaInsets The outside extended area of the crop box.
 @param lineInsets The edgeInset that constructed from the line width.
 @return A EMCropBoxFrameConverter instance.
 */
- (instancetype)initWithExtendedAreaInsets:(UIEdgeInsets)extendedAreaInsets lineInsets:(UIEdgeInsets)lineInsets;

/// Given a big area, calculate the origin of the crop box which could let the crop box stays in the top-left corner and not over the big area's boundary.
- (CGPoint)minimumOriginOfCropBoxWithExtendedAreaAndLineWidthInArea:(CGRect)bigArea;
- (CGPoint)minimumOriginOfCropBoxWithLineWidthInArea:(CGRect)bigArea;
- (CGPoint)minimumOriginOfCropBoxInArea:(CGRect)bigArea;

/// Given a big area, calculate the origin of the crop box which could let the crop box stays in the bottom-right corner and not over the big area's boundary.
- (CGPoint)maximumOriginOfCropBoxWithExtendedAreaAndLineWidthInArea:(CGRect)bigArea;
- (CGPoint)maximumOriginOfCropBoxWithLineWidthInArea:(CGRect)bigArea;
- (CGPoint)maximumOriginOfCropBoxInArea:(CGRect)bigArea;
@end
