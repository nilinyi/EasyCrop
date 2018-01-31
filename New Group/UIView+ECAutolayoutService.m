//
//  ECAutolayoutService.m
//  EasyCrop
//
//  Created by Leo Ni on 5/12/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import "UIView+ECAutolayoutService.h"

@implementation UIView (ECAutolayoutService)

- (ECConstraints *)ec_alignToContainer {
    return [self ec_alignToContainerWithTop:@0 right:@0 bottom:@0 left:@0];
}

- (ECConstraints *)ec_alignToContainerWithTop:(NSNumber *)top right:(NSNumber *)right bottom:(NSNumber *)bottom left:(NSNumber *)left {
    NSMutableArray *constraints = [NSMutableArray new];
    if (top) {
        [constraints addObject:[self.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:top.integerValue]];
    }
    if (right) {
        [constraints addObject:[self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor constant:-right.integerValue]];
    }
    if (bottom) {
        [constraints addObject:[self.bottomAnchor constraintEqualToAnchor:self.superview.bottomAnchor constant:-bottom.integerValue]];
    }
    if (left) {
        [constraints addObject:[self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor constant:left.integerValue]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
    return constraints;
}

- (ECConstraints *)ec_alignWidth:(CGFloat)w height:(CGFloat)h {
    return @[[self ec_alignWidthToConstant:w relation:@"=="][0], [self ec_alignHeightToConstant:h relation:@"=="][0]];
}

- (ECConstraints *)ec_alignWidthToConstant:(CGFloat)c relation:(NSString *)r {
    NSMutableArray *constraints = [NSMutableArray new];
    if ([r isEqualToString:@"=="]) {
        [constraints addObject:[self.widthAnchor constraintEqualToConstant:c]];
    } else if ([r isEqualToString:@"<="]) {
        [constraints addObject:[self.widthAnchor constraintLessThanOrEqualToConstant:c]];
    } else if ([r isEqualToString:@">="]) {
        [constraints addObject:[self.widthAnchor constraintGreaterThanOrEqualToConstant:c]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
    return constraints;
}

- (ECConstraints *)ec_alignHeightToConstant:(CGFloat)c relation:(NSString *)r {
    NSMutableArray *constraints = [NSMutableArray new];
    if ([r isEqualToString:@"=="]) {
        [constraints addObject:[self.heightAnchor constraintEqualToConstant:c]];
    } else if ([r isEqualToString:@"<="]) {
        [constraints addObject:[self.heightAnchor constraintLessThanOrEqualToConstant:c]];
    } else if ([r isEqualToString:@">="]) {
        [constraints addObject:[self.heightAnchor constraintGreaterThanOrEqualToConstant:c]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
    return constraints;
}

- (ECConstraints *)ec_alignWidthToView:(UIView *)view relation:(NSString *)r multiplier:(CGFloat)m constant:(CGFloat)c {
    NSMutableArray *constraints = [NSMutableArray new];
    if ([r isEqualToString:@"=="]) {
        [constraints addObject:[self.widthAnchor constraintEqualToAnchor:view.widthAnchor multiplier:m constant:c]];
    } else if ([r isEqualToString:@"<="]) {
        [constraints addObject:[self.widthAnchor constraintLessThanOrEqualToAnchor:view.widthAnchor multiplier:m constant:c]];
    } else if ([r isEqualToString:@">="]) {
        [constraints addObject:[self.widthAnchor constraintGreaterThanOrEqualToAnchor:view.widthAnchor multiplier:m constant:c]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
    return constraints;
}

- (ECConstraints *)ec_alignHeightToView:(UIView *)view relation:(NSString *)r multiplier:(CGFloat)m constant:(CGFloat)c {
    NSMutableArray *constraints = [NSMutableArray new];
    if ([r isEqualToString:@"=="]) {
        [constraints addObject:[self.heightAnchor constraintEqualToAnchor:view.heightAnchor multiplier:m constant:c]];
    } else if ([r isEqualToString:@"<="]) {
        [constraints addObject:[self.heightAnchor constraintLessThanOrEqualToAnchor:view.heightAnchor multiplier:m constant:c]];
    } else if ([r isEqualToString:@">="]) {
        [constraints addObject:[self.heightAnchor constraintGreaterThanOrEqualToAnchor:view.heightAnchor multiplier:m constant:c]];
    }
    [NSLayoutConstraint activateConstraints:constraints];
    return constraints;
}

- (ECConstraints *)ec_alignWidthEqualToView:(UIView *)view {
    return [self ec_alignWidthToView:view relation:@"==" multiplier:1.0 constant:0.0];
}

- (ECConstraints *)ec_alignHeightEqualToView:(UIView *)view {
    return [self ec_alignHeightToView:view relation:@"==" multiplier:1.0 constant:0.0];
}

- (ECConstraints *)ec_alignCenterVerticallyToView:(UIView *)view {
    NSLayoutConstraint *centerY = [self.centerYAnchor constraintEqualToAnchor:view.centerYAnchor];
    centerY.active = YES;
    return @[centerY];
}

- (ECConstraints *)ec_alignCenterHorizontallyToView:(UIView *)view {
    NSLayoutConstraint *centerX = [self.centerXAnchor constraintEqualToAnchor:view.centerXAnchor];
    centerX.active = YES;
    return @[centerX];
}

@end
