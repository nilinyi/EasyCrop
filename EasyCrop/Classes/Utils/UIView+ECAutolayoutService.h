//
//  ECAutolayoutService.h
//  EasyCrop
//
//  Created by Leo Ni on 5/12/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NSArray<NSLayoutConstraint *> ECConstraints;

@interface UIView (ECAutolayoutService)

- (ECConstraints *)ec_alignToContainer;
- (ECConstraints *)ec_alignToContainerWithTop:(NSNumber *)top right:(NSNumber *)right bottom:(NSNumber *)bottom left:(NSNumber *)left;

- (ECConstraints *)ec_alignWidth:(CGFloat)w height:(CGFloat)h;

- (ECConstraints *)ec_alignWidthToConstant:(CGFloat)c relation:(NSString *)r;
- (ECConstraints *)ec_alignHeightToConstant:(CGFloat)c relation:(NSString *)r;

- (ECConstraints *)ec_alignWidthToView:(UIView *)view relation:(NSString *)r multiplier:(CGFloat)m constant:(CGFloat)c;
- (ECConstraints *)ec_alignHeightToView:(UIView *)view relation:(NSString *)r multiplier:(CGFloat)m constant:(CGFloat)c;

- (ECConstraints *)ec_alignWidthEqualToView:(UIView *)view;
- (ECConstraints *)ec_alignHeightEqualToView:(UIView *)view;

- (ECConstraints *)ec_alignCenterVerticallyToView:(UIView *)view;
- (ECConstraints *)ec_alignCenterHorizontallyToView:(UIView *)view;

@end
