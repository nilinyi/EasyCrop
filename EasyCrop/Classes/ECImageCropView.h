//
//  ECImageCropView.h
//  EasyMenu
//
//  Created by Leo Ni on 6/4/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

@interface ECImageCropView : UIView

/// The image displayed in ECImageCropView. Default is nil.
@property (nonatomic, readwrite, strong) UIImage *image;
/// The cropped image based on the crop box.
@property (nonatomic, readonly, strong) UIImage *croppedImage;
/// A flag indicating whether ECImageCropView could receive any editing gestures.
@property (atomic, readwrite, assign) BOOL cropLocked;

- (instancetype)initWithImage:(UIImage *)image;

/**
 Setup a crop box with the default proper frame.
 */
- (BOOL)setupCropBox;

/**
 Setup the crop box. Return NO if setup failed, for example, a crop box is already in ECImageCropView. The boxFrame will be constrained inside image's bound if it's too large.

 @param boxFrame The frame of the crop box to set.
 @param isBasedOnImageCoordinate Pass in YES means boxFrame is based on the image's local coordinate system(image's bound). Otherwise, it will treat boxFrame under ECImageCropView's local coordinate system(this view's bound).
 */
- (BOOL)setupCropBox:(CGRect)boxFrame basedOnImageCoordinate:(BOOL)isBasedOnImageCoordinate;

/**
 Remove the crop box.
 */
- (BOOL)removeCropBox;

@end
