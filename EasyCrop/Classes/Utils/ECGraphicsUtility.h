//
//  ECGraphicsUtility.h
//  EasyCrop
//
//  Created by Leo Ni on 1/31/18.
//

#import <UIKit/UIKit.h>

@interface ECGraphicsUtility : NSObject

/// Return the matrix which could transform one rect to another. Rotation is not considered in the calculation.
+ (CGAffineTransform)transformMatrixFromRect:(CGRect)fromRect toRect:(CGRect)toRect;

/// Aspect fit a CGSize inside a given CGRect. Return a CGRect under the given CGRect's coordinate system.
+ (CGRect)aspectFitSize:(CGSize)size inRect:(CGRect)inRect;

/// Aspect fill a CGSize inside a given CGRect. Return a CGRect under the given CGRect's coordinate system.
+ (CGRect)aspectFillSize:(CGSize)size inRect:(CGRect)inRect;

@end
