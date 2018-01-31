//
//  UIImage+Utility.h
//  EasyMenu
//
//  Created by Leo Ni on 7/19/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

/// Return an UIImage with portrait orientation.
- (UIImage *)imageWithPortraitOrientation;

/// Return an UIImage cropped in the given CGRect.
- (UIImage *)imageCroppedInRect:(CGRect)rect;

/// Serialize an UIImage object. Use PNG conversion whenever it's possible.
- (NSData *)binaryRepresentation;

/// Return an UIImage obejct from a CALayer;
+ (UIImage *)imageFromLayer:(CALayer *)layer;

@end
