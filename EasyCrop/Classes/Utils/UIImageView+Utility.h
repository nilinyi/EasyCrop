//
//  UIImageView+Utility.h
//  EasyCrop
//
//  Created by Leo Ni on 1/31/18.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Utility)

/// Get the image's frame after being aspect fit scaled. Return a CGRect under this imageView's coordinate system.
- (CGRect)imageFrameAfterAspectFitScaled;

/// Get the image's frame after being aspect fill scaled. Return a CGRect under this imageView's coordinate system.
- (CGRect)imageFrameAfterAspectFillScaled;

@end
