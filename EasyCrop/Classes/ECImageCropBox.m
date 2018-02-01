//
//  ECImageCropBox.m
//  EasyMenu
//
//  Created by Leo Ni on 6/4/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECImageCropBox.h"
#import "ECImageCropView.h"
#import "ECCropBoxFrameConverter.h"
#import "UIView+ECAutolayoutService.h"

@interface ECImageCropBox() <UIGestureRecognizerDelegate>
@property (nonatomic, readwrite, assign) CGRect boundary; // crop区域允许移动的范围, 默认值为crop view的bounds
@property (nonatomic, readwrite, strong) NSMutableSet *activeGestureSet;
@property (nonatomic, readwrite, assign) BOOL isViewLoaded;
@end

@implementation ECImageCropBox {
    UIView *_topEdge; // top
    UIView *_rightEdge; // right
    UIView *_bottomEdge; // bottom
    UIView *_leftEdge; // left
    UIView *_topRightCorner; // top right
    UIView *_bottomRightCorner; // bottom right
    UIView *_bottomLeftCorner; // bottom left
    UIView *_topLeftCorner; // top left

    UIView *_topEdgeTouchArea; // top
    UIView *_rightEdgeTouchArea; // right
    UIView *_bottomEdgeTouchArea; // bottom
    UIView *_leftEdgeTouchArea; // left
    UIView *_centerTouchArea; // center
    UIView *_topRightCornerTouchArea; // top right
    UIView *_bottomRightCornerTouchArea; // bottom right
    UIView *_bottomLeftCornerTouchArea; // bottom left
    UIView *_topLeftCornerTouchArea; // top left

    ECCropBoxFrameConverter *_cropBoxFrameConverter;
}


const CGFloat LineWidth = 1.0; // 边缘线宽
const CGFloat LCornerLength = 15.0;
const CGFloat LCornerWidth = 5.0;
const CGSize CenterDotSize = {20, 20};
const CGSize CenterTouchableSize = {35, 35};
const UIEdgeInsets TouchableExtendOutsets = {40.0, 40.0, 40.0, 40.0}; // 边缘线外部触摸延展区域 (不包括边缘线)
const UIEdgeInsets TouchableExtendInsets = {20.0, 20.0, 20.0, 20.0}; // 边缘线内部触摸延展区域 (不包括边缘线)
const CGSize MinimumCropBoxSize = {75, 75}; // 最小框(不包括边缘线)

# pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame inOCRImageCropView:(ECImageCropView<ECImageCropBoxDelegate> *)ocrImageCropView {
    // Extend the frame with the touchable insets
    // negative means extend, positive means shrink
    // 线宽 + 外侧触摸区域
    UIEdgeInsets extendedInsets = UIEdgeInsetsMake(-TouchableExtendOutsets.top-LineWidth, -TouchableExtendOutsets.left-LineWidth, -TouchableExtendOutsets.bottom-LineWidth, -TouchableExtendOutsets.right-LineWidth);
    if (self = [super initWithFrame:UIEdgeInsetsInsetRect(frame, extendedInsets)]) {
        _ocrImageCropView = ocrImageCropView;
        _cropBoxFrameConverter = [[ECCropBoxFrameConverter alloc] initWithExtendedAreaInsets:TouchableExtendOutsets lineInsets:UIEdgeInsetsMake(LineWidth, LineWidth, LineWidth, LineWidth)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isViewLoaded) {
        [self p_setupUI];
        [self p_setupGestureRecognizer];
        self.isViewLoaded = YES;
    }
}

# pragma mark - UI setup
- (void)p_setupUI {
    // TEST: show the extend touch boundary
    // self.backgroundColor = [UIColor clearColor];
    // self.layer.borderColor = UIColor.redColor.CGColor;
    // self.layer.borderWidth = 1.0;

    // Visual Crop Box的frame = 内部图片区域 + 边缘线, 即 cropBoxFrameWithLineWidth
    [self p_setupVisualCropBox];

    // 设置4个边缘块儿的触摸区(用作缩放手势的识别区)
    [self p_setupExtendedTouchArea];
}

- (void)p_setupVisualCropBox {
    UIView *visualCropBox = [UIView new];
    visualCropBox.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:visualCropBox];
    [visualCropBox ec_alignToContainerWithTop:@(TouchableExtendOutsets.top) right:@(TouchableExtendOutsets.right) bottom:@(TouchableExtendOutsets.bottom) left:@(TouchableExtendOutsets.left)]; // 距离四周是ExtendOutsets的距离(外侧触摸区)

    _topEdge = [self p_createHorizontalEdge];
    _bottomEdge = [self p_createHorizontalEdge];
    _leftEdge = [self p_createVerticalEdge];
    _rightEdge = [self p_createVerticalEdge];
    [visualCropBox addSubview:_topEdge];
    [visualCropBox addSubview:_bottomEdge];
    [visualCropBox addSubview:_leftEdge];
    [visualCropBox addSubview:_rightEdge];
    [_topEdge ec_alignToContainerWithTop:@0.0 right:@0.0 bottom:nil left:@0.0];
    [_bottomEdge ec_alignToContainerWithTop:nil right:@0.0 bottom:@0.0 left:@0.0];
    [_leftEdge ec_alignToContainerWithTop:@0.0 right:nil bottom:@0.0 left:@0.0];
    [_rightEdge ec_alignToContainerWithTop:@0.0 right:@0.0 bottom:@0.0 left:nil];

    _topRightCorner = [self p_createLCorner:TopRight];
    _bottomRightCorner = [self p_createLCorner:BottomRight];
    _bottomLeftCorner = [self p_createLCorner:BottomLeft];
    _topLeftCorner = [self p_createLCorner:TopLeft];
    [visualCropBox addSubview:_topRightCorner];
    [visualCropBox addSubview:_bottomRightCorner];
    [visualCropBox addSubview:_bottomLeftCorner];
    [visualCropBox addSubview:_topLeftCorner];
    [_topRightCorner ec_alignToContainerWithTop:@0 right:@0 bottom:nil left:nil];
    [_bottomRightCorner ec_alignToContainerWithTop:nil right:@0 bottom:@0 left:nil];
    [_bottomLeftCorner ec_alignToContainerWithTop:nil right:nil bottom:@0 left:@0];
    [_topLeftCorner ec_alignToContainerWithTop:@0 right:nil bottom:nil left:@0];
}

- (void)p_setupExtendedTouchArea {
    // edge touch area
    _centerTouchArea = [self p_createCenterTouchArea];
    [self addSubview:_centerTouchArea];
    [_centerTouchArea ec_alignCenterVerticallyToView:self];
    [_centerTouchArea ec_alignCenterHorizontallyToView:self];

    _topEdgeTouchArea = [self p_createHorizontalExtendedTouchArea];
    [self addSubview:_topEdgeTouchArea];
    [_topEdgeTouchArea ec_alignToContainerWithTop:@0.0 right:@0.0 bottom:nil left:@0.0];
    [_topEdgeTouchArea ec_alignCenterHorizontallyToView:self];

    _bottomEdgeTouchArea = [self p_createHorizontalExtendedTouchArea];
    [self addSubview:_bottomEdgeTouchArea];
    [_bottomEdgeTouchArea ec_alignToContainerWithTop:nil right:@0.0 bottom:@0.0 left:@0.0];
    [_bottomEdgeTouchArea ec_alignCenterHorizontallyToView:self];

    _leftEdgeTouchArea = [self p_createVerticalExtendedTouchArea];
    [self addSubview:_leftEdgeTouchArea];
    [_leftEdgeTouchArea ec_alignToContainerWithTop:@0.0 right:nil bottom:@0.0 left:@0.0];
    [_leftEdgeTouchArea ec_alignCenterVerticallyToView:self];

    _rightEdgeTouchArea = [self p_createVerticalExtendedTouchArea];
    [self addSubview:_rightEdgeTouchArea];
    [_rightEdgeTouchArea ec_alignToContainerWithTop:@0.0 right:@0.0 bottom:@0.0 left:nil];
    [_rightEdgeTouchArea ec_alignCenterVerticallyToView:self];

    // corner touch area
    _topRightCornerTouchArea = [self p_createCornerExtendedTouchArea];
    [self addSubview:_topRightCornerTouchArea];
    [_topRightCornerTouchArea ec_alignToContainerWithTop:@0.0 right:@0.0 bottom:nil left:nil];

    _bottomRightCornerTouchArea = [self p_createCornerExtendedTouchArea];
    [self addSubview:_bottomRightCornerTouchArea];
    [_bottomRightCornerTouchArea ec_alignToContainerWithTop:nil right:@0.0 bottom:@0.0 left:nil];

    _bottomLeftCornerTouchArea = [self p_createCornerExtendedTouchArea];
    [self addSubview:_bottomLeftCornerTouchArea];
    [_bottomLeftCornerTouchArea ec_alignToContainerWithTop:nil right:nil bottom:@0.0 left:@0.0];

    _topLeftCornerTouchArea = [self p_createCornerExtendedTouchArea];
    [self addSubview:_topLeftCornerTouchArea];
    [_topLeftCornerTouchArea ec_alignToContainerWithTop:@0.0 right:nil bottom:nil left:@0.0];
}

- (void)p_highlightEdgeWhenTouchAreaPressed:(UIView *)touchArea hightlight:(BOOL)isHighlight {
    NSLayoutAttribute attributeToChange;
    UIView *edgeToChange;
    if (touchArea == _topEdgeTouchArea) {
        attributeToChange = NSLayoutAttributeHeight;
        edgeToChange = _topEdge;
    } else if (touchArea == _bottomEdgeTouchArea) {
        attributeToChange = NSLayoutAttributeHeight;
        edgeToChange = _bottomEdge;
    } else if (touchArea == _leftEdgeTouchArea) {
        attributeToChange = NSLayoutAttributeWidth;
        edgeToChange = _leftEdge;
    } else if (touchArea == _rightEdgeTouchArea) {
        attributeToChange = NSLayoutAttributeWidth;
        edgeToChange = _rightEdge;
    } else if (touchArea == _topRightCornerTouchArea) {
        [self p_highlightEdgeWhenTouchAreaPressed:_topEdgeTouchArea hightlight:isHighlight];
        [self p_highlightEdgeWhenTouchAreaPressed:_rightEdgeTouchArea hightlight:isHighlight];
        return;
    } else if (touchArea == _bottomRightCornerTouchArea) {
        [self p_highlightEdgeWhenTouchAreaPressed:_bottomEdgeTouchArea hightlight:isHighlight];
        [self p_highlightEdgeWhenTouchAreaPressed:_rightEdgeTouchArea hightlight:isHighlight];
        return;
    } else if (touchArea == _bottomLeftCornerTouchArea) {
        [self p_highlightEdgeWhenTouchAreaPressed:_bottomEdgeTouchArea hightlight:isHighlight];
        [self p_highlightEdgeWhenTouchAreaPressed:_leftEdgeTouchArea hightlight:isHighlight];
        return;
    } else if (touchArea == _topLeftCornerTouchArea) {
        [self p_highlightEdgeWhenTouchAreaPressed:_topEdgeTouchArea hightlight:isHighlight];
        [self p_highlightEdgeWhenTouchAreaPressed:_leftEdgeTouchArea hightlight:isHighlight];
        return;
    } else {
        return;
    }
    NSLayoutConstraint *constraintToChange;
    for (NSLayoutConstraint *constraint in edgeToChange.constraints) {
        if (constraint.firstAttribute == attributeToChange) {
            constraintToChange = constraint;
            break;
        }
    }
    constraintToChange.constant = isHighlight ? LineWidth * 3.0 : LineWidth;
}

# pragma mark - Gesture Recognizer Setup
- (void)p_setupGestureRecognizer {
    // Center Dot Gesture
    [_centerTouchArea addGestureRecognizer:[self p_createTranslationGesture]];

    // Edge Gesture
    [_topEdgeTouchArea addGestureRecognizer:[self p_createEdgeGesture]];
    [_bottomEdgeTouchArea addGestureRecognizer:[self p_createEdgeGesture]];
    [_leftEdgeTouchArea addGestureRecognizer:[self p_createEdgeGesture]];
    [_rightEdgeTouchArea addGestureRecognizer:[self p_createEdgeGesture]];

    // Corner Gesture
    [_topRightCornerTouchArea addGestureRecognizer:[self p_createCornerGesture]];
    [_bottomRightCornerTouchArea addGestureRecognizer:[self p_createCornerGesture]];
    [_bottomLeftCornerTouchArea addGestureRecognizer:[self p_createCornerGesture]];
    [_topLeftCornerTouchArea addGestureRecognizer:[self p_createCornerGesture]];

    // Initialize
    self.activeGestureSet = [NSMutableSet new];
}

# pragma mark - Gesture Handler
- (void)p_translationGestureHandler:(UIPanGestureRecognizer *)gesture {
    if (![self.ocrImageCropView cropBox:self canPerformGesture:gesture]) {
        return;
    }

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self.activeGestureSet addObject:[NSValue valueWithNonretainedObject:gesture.view]];
            [self.ocrImageCropView cropBox:self gestureBegan:gesture];
            break;
        case UIGestureRecognizerStateChanged: {
            [self.ocrImageCropView cropBox:self gestureWillMove:gesture];

            CGPoint translation = [gesture translationInView:self];

            CGRect boundary = self.boundary;
            _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth = self.frame;
            CGPoint minOrigin = [_cropBoxFrameConverter minimumOriginOfCropBoxWithExtendedAreaAndLineWidthInArea:boundary];
            CGPoint maxOrigin = [_cropBoxFrameConverter maximumOriginOfCropBoxWithExtendedAreaAndLineWidthInArea:boundary];

            CGFloat x = MAX(MIN(maxOrigin.x, self.frame.origin.x + translation.x), minOrigin.x);
            CGFloat y = MAX(MIN(maxOrigin.y, self.frame.origin.y + translation.y), minOrigin.y); // constraint the range of x and y

            self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
            
            [gesture setTranslation:CGPointMake(0, 0) inView:self]; // reset, avoid accumulation

            [self.ocrImageCropView cropBox:self gestureDidMove:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.activeGestureSet removeObject:[NSValue valueWithNonretainedObject:gesture.view]];
            [self.ocrImageCropView cropBox:self gestureStopped:gesture];
            break;
        default:
            break;
    }
}

- (void)p_edgeGestureHandler:(UIPanGestureRecognizer *)gesture {
    if (![self.ocrImageCropView cropBox:self canPerformGesture:gesture]) {
        return;
    }

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self.activeGestureSet addObject:[NSValue valueWithNonretainedObject:gesture.view]];
            [self p_highlightEdgeWhenTouchAreaPressed:gesture.view hightlight:YES];
            [self.ocrImageCropView cropBox:self gestureBegan:gesture];
            break;
        case UIGestureRecognizerStateChanged: {
            [self.ocrImageCropView cropBox:self gestureWillMove:gesture];

            CGPoint edgeMoveDistance = [gesture translationInView:self];
            CGFloat x1 = self.frame.origin.x,
            y1 = self.frame.origin.y,
            w1 = self.frame.size.width,
            h1 = self.frame.size.height;
            // This newFrame will be the self.frame after moving cropBox's edge. However, this frame contains the outside extended touch area and also the Linewidth.
            CGRect newFrame = self.frame; // The coordinate system is ocrImageCropView.

            if (gesture.view == _topEdgeTouchArea) {
                newFrame = CGRectMake(x1, y1 + edgeMoveDistance.y, w1, h1 - edgeMoveDistance.y);
            } else if (gesture.view == _bottomEdgeTouchArea) {
                newFrame = CGRectMake(x1, y1, w1, h1 + edgeMoveDistance.y);
            } else if (gesture.view == _leftEdgeTouchArea) {
                newFrame = CGRectMake(x1 + edgeMoveDistance.x, y1, w1 - edgeMoveDistance.x, h1);
            } else if (gesture.view == _rightEdgeTouchArea) {
                newFrame = CGRectMake(x1, y1, w1 + edgeMoveDistance.x, h1);
            } else {
                return;
            }

            _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth = newFrame;
            CGRect cropBoxFrame = _cropBoxFrameConverter.cropBoxFrame;
            CGRect boundary = self.boundary;
            // 1. Make sure not too small
            if (cropBoxFrame.size.width >= MinimumCropBoxSize.width && cropBoxFrame.size.height >= MinimumCropBoxSize.height) {
                // 2. Make sure not too big by intersection operation
                CGRect validCropBoxFrameWithLineWidth = CGRectIntersection(boundary, _cropBoxFrameConverter.cropBoxFrameWithLineWidth);
                _cropBoxFrameConverter.cropBoxFrameWithLineWidth = validCropBoxFrameWithLineWidth;

                // 3. Assign the new value
                self.frame = _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth;
            }
            
            [gesture setTranslation:CGPointMake(0, 0) inView:self]; // reset, avoid accumulation

            [self.ocrImageCropView cropBox:self gestureDidMove:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.activeGestureSet removeObject:[NSValue valueWithNonretainedObject:gesture.view]];
            [self p_highlightEdgeWhenTouchAreaPressed:gesture.view hightlight:NO];
            [self.ocrImageCropView cropBox:self gestureStopped:gesture];
            break;
        default:
            break;
    }
}

- (void)p_cornerGestureHandler:(UIPanGestureRecognizer *)gesture {
    if (![self.ocrImageCropView cropBox:self canPerformGesture:gesture]) {
        return;
    }

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self.activeGestureSet addObject:[NSValue valueWithNonretainedObject:gesture.view]];
            [self p_highlightEdgeWhenTouchAreaPressed:gesture.view hightlight:YES];
            [self.ocrImageCropView cropBox:self gestureBegan:gesture];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self.ocrImageCropView cropBox:self gestureWillMove:gesture];

            CGPoint edgeMoveDistance = [gesture translationInView:self];
            CGFloat x1 = self.frame.origin.x,
            y1 = self.frame.origin.y,
            w1 = self.frame.size.width,
            h1 = self.frame.size.height;
            // This newFrame will be the self.frame after moving cropBox's edge. However, this frame contains the outside extended touch area and also the Linewidth.
            CGRect newFrame = self.frame; // The coordinate system is ocrImageCropView.

            if (gesture.view == _topRightCornerTouchArea) {
                newFrame = CGRectMake(x1, y1 + edgeMoveDistance.y, w1 + edgeMoveDistance.x, h1 - edgeMoveDistance.y);
            } else if (gesture.view == _bottomRightCornerTouchArea) {
                newFrame = CGRectMake(x1, y1, w1 + edgeMoveDistance.x, h1 + edgeMoveDistance.y);
            } else if (gesture.view == _bottomLeftCornerTouchArea) {
                newFrame = CGRectMake(x1 + edgeMoveDistance.x, y1, w1 - edgeMoveDistance.x, h1 + edgeMoveDistance.y);
            } else if (gesture.view == _topLeftCornerTouchArea) {
                newFrame = CGRectMake(x1 + edgeMoveDistance.x, y1 + edgeMoveDistance.y, w1 - edgeMoveDistance.x, h1 - edgeMoveDistance.y);
            } else {
                return;
            }

            _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth = newFrame;
            CGRect cropBoxFrame = _cropBoxFrameConverter.cropBoxFrame;
            CGRect boundary = self.boundary;
            // 1. Make sure not too small
            if (cropBoxFrame.size.width >= MinimumCropBoxSize.width && cropBoxFrame.size.height >= MinimumCropBoxSize.height) {
                // 2. Make sure not too big by intersection operation
                CGRect validCropBoxFrameWithLineWidth = CGRectIntersection(boundary, _cropBoxFrameConverter.cropBoxFrameWithLineWidth);
                _cropBoxFrameConverter.cropBoxFrameWithLineWidth = validCropBoxFrameWithLineWidth;

                // 3. Assign the new value
                self.frame = _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth;
            }

            [gesture setTranslation:CGPointMake(0, 0) inView:self]; // reset, avoid accumulation

            [self.ocrImageCropView cropBox:self gestureDidMove:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self.activeGestureSet removeObject:[NSValue valueWithNonretainedObject:gesture.view]];
            [self p_highlightEdgeWhenTouchAreaPressed:gesture.view hightlight:NO];
            [self.ocrImageCropView cropBox:self gestureStopped:gesture];
            break;
        default:
            break;
    }

}

# pragma mark - Gesture Creation
- (UIPanGestureRecognizer *)p_createTranslationGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_translationGestureHandler:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    return panGesture;
}

- (UIPanGestureRecognizer *)p_createEdgeGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_edgeGestureHandler:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    return panGesture;
}

- (UIPanGestureRecognizer *)p_createCornerGesture {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_cornerGestureHandler:)];
    panGesture.delegate = self;
    panGesture.maximumNumberOfTouches = 1;
    return panGesture;
}

# pragma mark - UI Creation
- (UIView *)p_createHorizontalEdge {
    UIView *horizontalEdge = [UIView new];
    horizontalEdge.translatesAutoresizingMaskIntoConstraints = NO;
    horizontalEdge.backgroundColor = self.edgeColor;
    [horizontalEdge ec_alignHeightToConstant:LineWidth relation:@"=="]; // h of middle line

    return horizontalEdge;
}

- (UIView *)p_createVerticalEdge {
    UIView *verticalEdge = [UIView new];
    verticalEdge.translatesAutoresizingMaskIntoConstraints = NO;
    verticalEdge.backgroundColor = self.edgeColor;
    [verticalEdge ec_alignWidthToConstant:LineWidth relation:@"=="]; // w of middle line

    return verticalEdge;
}

- (UIView *)p_createCenterTouchArea {
    UIView *dot = [UIView new];
    dot.translatesAutoresizingMaskIntoConstraints = NO;
    dot.backgroundColor = self.edgeColor;
    dot.layer.cornerRadius = CenterDotSize.width / 2.0;
    [dot ec_alignWidth:CenterDotSize.width height:CenterDotSize.height];

    UIView *touchArea = [UIView new];
    touchArea.translatesAutoresizingMaskIntoConstraints = NO;
    [touchArea ec_alignWidth:CenterTouchableSize.width height:CenterTouchableSize.height];
    [touchArea addSubview:dot];
    [dot ec_alignCenterHorizontallyToView:touchArea];
    [dot ec_alignCenterVerticallyToView:touchArea];

    return touchArea;
}

- (UIView *)p_createHorizontalExtendedTouchArea {
    UIView *touchArea = [UIView new];
    touchArea.translatesAutoresizingMaskIntoConstraints = NO;
    [touchArea ec_alignHeightToConstant:(TouchableExtendOutsets.top + LineWidth + TouchableExtendInsets.bottom) relation:@"=="];
    return touchArea;
}

- (UIView *)p_createVerticalExtendedTouchArea {
    UIView *touchArea = [UIView new];
    touchArea.translatesAutoresizingMaskIntoConstraints = NO;
    [touchArea ec_alignWidthToConstant:(TouchableExtendOutsets.top + LineWidth + TouchableExtendInsets.bottom) relation:@"=="];
    return touchArea;
}

- (UIView *)p_createCornerExtendedTouchArea {
    UIView *touchArea = [UIView new];
    touchArea.translatesAutoresizingMaskIntoConstraints = NO;
    [touchArea ec_alignWidth:(TouchableExtendInsets.right + LineWidth + TouchableExtendOutsets.right) height:(TouchableExtendInsets.bottom + LineWidth + TouchableExtendOutsets.bottom)];
    return touchArea;
}

typedef NS_ENUM(NSInteger, LCorner) {
    TopLeft,
    TopRight,
    BottomRight,
    BottomLeft
};
- (UIView *)p_createLCorner:(LCorner)corner {
    UIView *view = [UIView new];
    view.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *verticalBar = [UIView new];
    verticalBar.translatesAutoresizingMaskIntoConstraints = NO;
    verticalBar.backgroundColor = self.edgeColor;
    [verticalBar ec_alignWidth:LCornerWidth height:LCornerLength];

    UIView *horizontalBar = [UIView new];
    horizontalBar.translatesAutoresizingMaskIntoConstraints = NO;
    horizontalBar.backgroundColor = self.edgeColor;
    [horizontalBar ec_alignWidth:LCornerLength height:LCornerWidth];

    [view addSubview:verticalBar];
    [view addSubview:horizontalBar];
    [view ec_alignWidth:LCornerLength height:LCornerLength];

    switch (corner) {
        case TopLeft:
            [verticalBar ec_alignToContainerWithTop:@0 right:nil bottom:nil left:@0];
            [horizontalBar ec_alignToContainerWithTop:@0 right:nil bottom:nil left:@0];
            break;
        case TopRight:
            [verticalBar ec_alignToContainerWithTop:@0 right:@0 bottom:nil left:nil];
            [horizontalBar ec_alignToContainerWithTop:@0 right:@0 bottom:nil left:nil];
            break;
        case BottomRight:
            [verticalBar ec_alignToContainerWithTop:nil right:@0 bottom:@0 left:nil];
            [horizontalBar ec_alignToContainerWithTop:nil right:@0 bottom:@0 left:nil];
            break;
        case BottomLeft:
            [verticalBar ec_alignToContainerWithTop:nil right:nil bottom:@0 left:@0];
            [horizontalBar ec_alignToContainerWithTop:nil right:nil bottom:@0 left:@0];
            break;
        default:
            break;
    }

    return view;
}

# pragma mark - Accessors

- (UIColor *)edgeColor {
    if (!_edgeColor) {
        _edgeColor = UIColor.greenColor; // default color
    }
    return _edgeColor;
}

- (CGRect)boundary {
    CGRect bd = [self.ocrImageCropView boundaryForCropBox:self];
    return UIEdgeInsetsInsetRect(bd, UIEdgeInsetsMake(-LineWidth, -LineWidth, -LineWidth, -LineWidth));
}

- (CGRect)cropBoxFrame {
    _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth = self.frame;
    return _cropBoxFrameConverter.cropBoxFrame;
}

- (void)setCropBoxFrame:(CGRect)cropBoxFrame {
    _cropBoxFrameConverter.cropBoxFrame = cropBoxFrame;
    self.frame = _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth;
}

- (CGRect)frameFromCropBoxFrame:(CGRect)cropBoxFrame {
    _cropBoxFrameConverter.cropBoxFrame = cropBoxFrame;
    return _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth;
}

- (CGRect)cropBoxFrameWithLineWidth {
    _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth = self.frame;
    return _cropBoxFrameConverter.cropBoxFrameWithLineWidth;
}

- (void)setCropBoxFrameWithLineWidth:(CGRect)cropBoxFrameWithLineWidth {
    _cropBoxFrameConverter.cropBoxFrameWithLineWidth = cropBoxFrameWithLineWidth;
    self.frame = _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth;
}

- (CGRect)frameFromCropBoxFrameWithLineWidth:(CGRect)cropBoxFrameWithLineWidth {
    _cropBoxFrameConverter.cropBoxFrameWithLineWidth = cropBoxFrameWithLineWidth;
    return _cropBoxFrameConverter.cropBoxFrameWithExtendedAreaAndLineWidth;
}

- (CGRect)cropBoxFrameWithLineWidthAndExtendedArea {
    return self.frame;
}

- (void)setCropBoxFrameWithLineWidthAndExtendedArea:(CGRect)cropBoxFrameWithLineWidthAndExtendedArea {
    self.frame = cropBoxFrameWithLineWidthAndExtendedArea;
}

- (CGRect)frameFromCropBoxFrameWithLineWidthAndExtendedArea:(CGRect)cropBoxFrameWithLineWidthAndExtendedArea {
    return cropBoxFrameWithLineWidthAndExtendedArea;
}

- (BOOL)isGestureBusy {
    BOOL s1_idle = _centerTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s2_idle = _topEdgeTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s3_idle = _bottomEdgeTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s4_idle = _leftEdgeTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s5_idle = _rightEdgeTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s6_idle = _topRightCornerTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s7_idle = _bottomRightCornerTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s8_idle = _bottomLeftCornerTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;
    BOOL s9_idle = _topLeftCornerTouchArea.gestureRecognizers[0].state == UIGestureRecognizerStatePossible;

    return !(s1_idle && s2_idle && s3_idle && s4_idle && s5_idle && s6_idle && s7_idle && s8_idle && s9_idle);
}

- (NSInteger)numOfGesturesInProcessing {
    return self.activeGestureSet.count;
}

- (void)setMode:(ECImageCropBoxMode)mode {
    switch (mode) {
        case ECImageCropBoxPresentingMode:
            self.userInteractionEnabled = NO;
            _centerTouchArea.hidden = YES;
            break;
        case ECImageCropBoxInteractionMode:
            self.userInteractionEnabled = YES;
            _centerTouchArea.hidden = NO;
            break;
    }
    _mode = mode;
}

# pragma mark - Touch Test
- (BOOL)isPointInsideTouchArea:(CGPoint)point {
    BOOL center = CGRectContainsPoint(_centerTouchArea.frame, point);
    BOOL top = CGRectContainsPoint(_topEdgeTouchArea.frame, point);
    BOOL bottom = CGRectContainsPoint(_bottomEdgeTouchArea.frame, point);
    BOOL left = CGRectContainsPoint(_leftEdgeTouchArea.frame, point);
    BOOL right = CGRectContainsPoint(_rightEdgeTouchArea.frame, point);
    BOOL top_right = CGRectContainsPoint(_topRightCornerTouchArea.frame, point);
    BOOL bottom_right = CGRectContainsPoint(_bottomRightCornerTouchArea.frame, point);
    BOOL bottom_left = CGRectContainsPoint(_bottomLeftCornerTouchArea.frame, point);
    BOOL top_left = CGRectContainsPoint(_topLeftCornerTouchArea.frame, point);
    return center || top || bottom || left || right || top_right || bottom_right || bottom_left || top_left;
}
# pragma mark - Some layout metrics
+ (CGFloat)lineWidth {
    return LineWidth;
}

@end
