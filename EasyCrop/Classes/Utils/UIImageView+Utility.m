//
//  UIImageView+Utility.m
//  EasyCrop
//
//  Created by Leo Ni on 1/31/18.
//

#import "UIImageView+Utility.h"
#import "ECGraphicsUtility.h"

@implementation UIImageView (Utility)

- (CGRect)imageFrameAfterAspectFitScaled {
    return [ECGraphicsUtility aspectFitSize:self.image.size inRect:self.frame];
}

- (CGRect)imageFrameAfterAspectFillScaled {
    return [ECGraphicsUtility aspectFillSize:self.image.size inRect:self.frame];
}

@end
