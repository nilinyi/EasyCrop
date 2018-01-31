//
//  UIBezierPath+Utility.h
//  EasyMenu
//
//  Created by Leo Ni on 8/6/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Utility)

/// Combine multiple paths and return a single path.
+ (UIBezierPath *)combinedPathFromPaths:(NSArray <UIBezierPath *> *)paths;

/// Append multiple paths and return a single path.
- (UIBezierPath *)pathAfterAppendingPaths:(NSArray <UIBezierPath *> *)paths;

@end
