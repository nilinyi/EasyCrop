//
//  UIBezierPath+Utility.m
//  EasyMenu
//
//  Created by Leo Ni on 8/6/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import "UIBezierPath+Utility.h"

@implementation UIBezierPath (Utility)

+ (UIBezierPath *)combinedPathFromPaths:(NSArray <UIBezierPath *> *)paths {
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (UIBezierPath *p in paths) {
        [path appendPath:p];
    }
    return path;
}

- (UIBezierPath *)pathAfterAppendingPaths:(NSArray <UIBezierPath *> *)paths {
    UIBezierPath *finalPath = self.copy;
    for (UIBezierPath *p in paths) {
        [finalPath appendPath:p];
    }
    return finalPath;
}

@end
