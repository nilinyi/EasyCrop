//
//  EMOCRImageCropView.h
//  EasyMenu
//
//  Created by Leo Ni on 6/4/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//


/**
 An UIView for croping image.
 */
@interface EMOCRImageCropView : UIView
@property (nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readonly, strong) UIImage *croppedImage;
@property (atomic, readonly, assign) BOOL isGestureBusy;

@property (atomic, readwrite, assign) BOOL cropLocked;

- (instancetype)initWithImage:(UIImage *)image;

/**
 Add a crop box.

 @param boxFrame The frame of the added crop box.
 @param isOriginalFrame If true, this method will treat boxFrame as to the real size of image.
 */
- (void)setupCropBox:(CGRect)boxFrame isOriginalFrame:(BOOL)isOriginalFrame;

/**
 Add a crop box with a preferred frame.
 */
- (void)setupCropBox;

/**
 Remove the crop box from this view.
 */
- (void)removeCropBox;

@end
