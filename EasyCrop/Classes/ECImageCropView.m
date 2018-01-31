//
//  ECImageCropView.m
//  EasyMenu
//
//  Created by Leo Ni on 6/4/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

#import "ECImageCropBox.h"
#import "ECGraphicsUtility.h"
#import "ECLayerAnimationMaker.h"
#import "UIImageView+Utility.h"
#import "ECImageCropView.h"
#import "UIBezierPath+Utility.h"
#import "UIImage+Utility.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+ECAutolayoutService.h"

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

@interface ECImageCropView () <ECImageCropBoxDelegate, UIGestureRecognizerDelegate>

# pragma mark - Public 
@property (atomic, readwrite, assign) BOOL isGestureBusy;

# pragma mark - Subviews
@property (nonatomic, readwrite, strong) ECImageCropBox *cropBox;
@property (nonatomic, readwrite, strong) UIImageView *imageView;

# pragma mark - Shadow and highlight areas
/// A layer representing all the background and highlighted area
@property (nonatomic, readwrite, strong) CAShapeLayer *highlightedLayer;

# pragma mark - Private accessors
@property (nonatomic, readonly, assign) CGRect imagePresentingFrame;
@property (nonatomic, readonly, assign) CGRect imageOriginalFrame;
@property (nonatomic, readonly, assign) BOOL isCropBoxInsideImage;
@property (nonatomic, readonly, assign) CGRect preferredCropRect;
@property (atomic, readwrite, assign) BOOL isAnchoring;

@end

@implementation ECImageCropView {
    CGRect _initialImageViewFrame; // Transform Bug required.
}

@synthesize isAnchoring = _isAnchoring;
@synthesize cropLocked = _cropLocked;

// TODO:
// Constrain max and min scale
const CGFloat MAX_IMAGE_SCALE = 5.0;
const CGFloat MIN_IMAGE_SCALE = 0.7;

# pragma mark - Public
- (void)setupCropBox:(CGRect)boxFrame isOriginalFrame:(BOOL)isOriginalFrame {
    if (self.cropBox) {
        return; // no operation if crop box already exists
    }

    CGRect actualBoxFrame = boxFrame;
    if (isOriginalFrame) {
        // calculate transform matrix which transforms from originalImageFrame to actualImageFrame
        CGAffineTransform t = [ECGraphicsUtility transformMatrixFromRect:self.imageOriginalFrame toRect:self.imagePresentingFrame];
        // transform originalboxFrame to actualBoxFrame
        actualBoxFrame = CGRectApplyAffineTransform(boxFrame, t);
    }
    self.cropBox = [[ECImageCropBox alloc] initWithFrame:actualBoxFrame inOCRImageCropView:self];
    [self addSubview:self.cropBox];

    // show highlighted layer
    [self p_addHighlightedLayer];
    self.highlightedLayer.path = [self p_createPathWithHighlightedRect:self.cropBox.cropBoxFrameWithLineWidth].CGPath;
}

- (void)setupCropBox {
    CGRect validCropBoxRect = CGRectIntersection(self.preferredCropRect, self.imageView.imageFrameAfterAspectFitScaled);
    [self setupCropBox:validCropBoxRect isOriginalFrame:NO];
}

- (void)removeCropBox {
    if (!self.cropBox) {
        return;
    }

    // reset all animations
    [self.cropBox.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations];
    // reset flags
    self.isAnchoring = NO;
    self.isGestureBusy = NO;
    // remove views
    [self.cropBox removeFromSuperview];
    self.cropBox = nil;
    [self p_removeHighlightedLayer];

    // Transform Bug required.
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.frame = _initialImageViewFrame;
}

# pragma mark - Initializers
- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super initWithFrame:CGRectZero]) {
        [self p_setupUI];
        [self p_setupGesture];
        self.image = image; // populate imageView
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithImage:nil];
}

- (instancetype)init {
    return [self initWithImage:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self p_setupUI];
        [self p_setupGesture];
    }
    return self;
}

- (void)didMoveToWindow {
    _initialImageViewFrame = self.imageView.frame; // Transform Bug required.
}

# pragma mark - UI setup
- (void)p_setupUI {
    self.backgroundColor = UIColor.clearColor;
    // add subviews
    [self addSubview:self.imageView];
    // setup constraints
    [self.imageView ec_alignToContainer];
}

- (void)p_addHighlightedLayer {
    if (![self.layer.sublayers containsObject:self.highlightedLayer]) {
        [self.layer addSublayer:self.highlightedLayer];
    }
}

- (void)p_removeHighlightedLayer {
    [self.highlightedLayer removeFromSuperlayer];
    self.highlightedLayer = nil;
}

- (UIBezierPath *)p_createPathWithHighlightedRect:(CGRect)highlightedRect {
    if (!self.cropBox) {
        return nil;
    }

    [self layoutIfNeeded]; // ensure the frame is updated
    UIBezierPath *basePath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *boxNewPath = [UIBezierPath bezierPathWithRect:highlightedRect];
    boxNewPath.usesEvenOddFillRule = true;
    UIBezierPath *newPath = [basePath pathAfterAppendingPaths:@[boxNewPath]];
    return newPath;
}

# pragma mark - Gesture
/**
 * Began and move of gestures will cancel all anchorings.
 * Designated anchoring will be triggered everytime gesture is finished.(If needed)
 *
 **/

- (void)p_setupGesture {
    // create and configure the pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(p_imageViewPinchGestureDetected:)];
    [pinchGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:pinchGestureRecognizer];

    // creat and configure the pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_imageViewPanGestureDetected:)];
//    panGestureRecognizer.minimumNumberOfTouches = 2;
//    panGestureRecognizer.maximumNumberOfTouches = 2;
    [panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)p_imageViewPinchGestureDetected:(UIPinchGestureRecognizer *)recognizer {
    if (self.cropBox.isGestureBusy || self.isAnchoring) {
        return;
    }
    UIGestureRecognizerState state = recognizer.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            // Stop the anchor of crop box
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(p_autoAnchorCropBox) object:nil];

            // Gesture is busy now
            self.isGestureBusy = YES;
            break;
        case UIGestureRecognizerStateChanged: {
            UIView *pinchView = self.imageView;
            CGFloat scale = recognizer.scale;
            CGPoint pinchCenter = [recognizer locationInView:pinchView];

            // 计算pinchCenter到centroid的相对距离.
            // (因为对于UIView的所有的所有的所有的transform都是在中心进行的(anchorPoint = (0.5, 0.5));
            pinchCenter.x -= CGRectGetMidX(pinchView.bounds);
            pinchCenter.y -= CGRectGetMidY(pinchView.bounds);

            CGAffineTransform transform = pinchView.transform;
            transform = CGAffineTransformTranslate(transform, pinchCenter.x, pinchCenter.y); // 整张图移动到现在的pinchCenter
            transform = CGAffineTransformScale(transform, scale, scale); // do scaled
            transform = CGAffineTransformTranslate(transform, -pinchCenter.x, -pinchCenter.y); // Move back
            
            pinchView.transform = transform;
            recognizer.scale = 1.0;
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            // Gesture is not busy now
            self.isGestureBusy = NO;

            // Start anchor imageView, the crop box anchor will be triggered after imageView's anchor
            [self p_autoAnchorImageView];
            break;
        default:
            break;
    }
}

- (void)p_imageViewPanGestureDetected:(UIPanGestureRecognizer *)recognizer {
    if (self.cropBox.isGestureBusy || self.isAnchoring) {
        return;
    }
    UIGestureRecognizerState state = recognizer.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            // Stop the anchor of crop box
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(p_autoAnchorCropBox) object:nil];

            // Gesture is busy now
            self.isGestureBusy = YES;
            break;
        case UIGestureRecognizerStateChanged: {
            UIView *panView = self.imageView;
            CGPoint translation = [recognizer translationInView:panView];
            panView.transform = CGAffineTransformTranslate(panView.transform, translation.x, translation.y);
            [recognizer setTranslation:CGPointZero inView:panView];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
            // Gesture is not busy now
            self.isGestureBusy = NO;

            // Start anchor imageView, the crop box anchor will be triggered after imageView's anchor
            [self p_autoAnchorImageView];
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// 对于那些在crop box上的手势, 直接跳过不处理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.cropBox];
    return ![self.cropBox isPointInsideTouchArea:touchPoint];
}

# pragma mark - ECImageCropViewDelegate
/**
 * Began and move of gestures will cancel all anchorings.
 * Designated anchoring will be triggered everytime gesture is finished.(If needed)
 *
 **/

- (CGRect)boundaryForCropBox:(ECImageCropBox *)cropBox {
    return [self.imageView imageFrameAfterAspectFitScaled];
}

- (BOOL)cropBox:(ECImageCropBox *)cropBox canPerformGesture:(UIGestureRecognizer *)gesture {
    return !self.isAnchoring && !self.isGestureBusy;
}

- (void)cropBox:(ECImageCropBox *)cropBox gestureBegan:(UIGestureRecognizer *)gesture {
    // Stop the anchor of crop box
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(p_autoAnchorCropBox) object:nil];
}

- (void)cropBox:(ECImageCropBox *)cropBox gestureWillMove:(UIGestureRecognizer *)gesture {
}

- (void)cropBox:(ECImageCropBox *)cropBox gestureDidMove:(UIGestureRecognizer *)gesture {
    // 每次手势移动的时候, 让高亮区跟着cropBox走!
    UIBezierPath *newPath = [self p_createPathWithHighlightedRect:cropBox.cropBoxFrameWithLineWidth];
    self.highlightedLayer.path = newPath.CGPath;
}

- (void)cropBox:(ECImageCropBox *)cropBox gestureStopped:(UIGestureRecognizer *)gesture {
    if (cropBox.numOfGesturesInProcessing == 0) {
        // Start anchor crop box if this is the last active crop box which stop gesture
        // 这里不能使用isGestureBusy!!!
        [self performSelector:@selector(p_autoAnchorCropBox) withObject:nil afterDelay:1.5];
    }
}

# pragma mark - Autoanchor

/// Autoanchor crop box. Return YES if this autoanchor happens.
- (BOOL)p_autoAnchorCropBox {
    if (!self.cropBox || self.isAnchoring || self.isGestureBusy) {
        return NO;
    }

    // Start anchoring
    self.isAnchoring = YES;

    // Valid crop box rect
    CGRect boxActualRect = self.cropBox.cropBoxFrame;
    CGRect validBoxRect = CGRectIntersection(boxActualRect, [self.imageView imageFrameAfterAspectFitScaled]);

    // Anchored box rect
    CGRect anchoredBoxRect = AVMakeRectWithAspectRatioInsideRect(validBoxRect.size, self.preferredCropRect);

    // Transform matrix from validBoxRect to anchoredBoxRect
    CGAffineTransform t = [ECGraphicsUtility transformMatrixFromRect:validBoxRect toRect:anchoredBoxRect];

    // Final results
    CGRect finalBoxRect = anchoredBoxRect;
    CGRect finalImageViewRect = CGRectApplyAffineTransform(self.imageView.frame, t);

    if (CGRectEqualToRect(boxActualRect, finalBoxRect)) {
        // Do not do anchor if the finalRect is equal to the current rect
        self.isAnchoring = NO;
        return NO;
    }

    [self.cropBox.layer removeAllAnimations];
    [self.imageView.layer removeAllAnimations]; // reset all animations

    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.cropBox.hidden = YES;
        self.imageView.frame = finalImageViewRect;
    } completion:^(BOOL finished) {
        self.cropBox.hidden = NO;
        self.cropBox.frame = [self.cropBox frameFromCropBoxFrame:finalBoxRect];
        self.isAnchoring = NO; // Finish anchoring
    }];

    // Path animation
    CGPathRef startPath = self.highlightedLayer.path;
    CGRect finalBoxRectWithLineWidth = UIEdgeInsetsInsetRect(finalBoxRect, UIEdgeInsetsMake(-ECImageCropBox.lineWidth, -ECImageCropBox.lineWidth, -ECImageCropBox.lineWidth, -ECImageCropBox.lineWidth));
    CGPathRef endPath = [self p_createPathWithHighlightedRect:finalBoxRectWithLineWidth].CGPath;
    CAAnimation *pathAnimation = [ECLayerAnimationMaker layerAnimationFromPath:startPath toPath:endPath withDuration:0.2];
    [self.highlightedLayer addAnimation:pathAnimation forKey:nil];
    self.highlightedLayer.path = endPath;

    return YES;
}

- (BOOL)p_autoAnchorImageView {
    if (!self.cropBox || self.isAnchoring || self.isGestureBusy) {
        return NO;
    }

    CGRect viewRect = [self.imageView imageFrameAfterAspectFitScaled];
    CGRect cropBoxRect = self.cropBox.cropBoxFrame;

    if (CGRectContainsRect(viewRect, cropBoxRect)) {
        // Crop box anchoring might be interruptted by the move of imageview, so call anchoring of cropbox again
        [self performSelector:@selector(p_autoAnchorCropBox) withObject:nil afterDelay:1.5];
        return NO; // Transform bug required.
    }

    CGFloat v_width     = viewRect.size.width;
    CGFloat v_height    = viewRect.size.height;
    CGFloat c_width     = cropBoxRect.size.width;
    CGFloat c_height    = cropBoxRect.size.height;

    // Need scaled first?
    CGAffineTransform scaleT = CGAffineTransformMakeScale(1.0, 1.0);
    if (v_width < c_width || v_height < c_height) {
        CGFloat s = 1.0;
        if (v_width < c_width) {
            s *= (c_width / v_width);
        }
        if (v_height * s < c_height) {
            // if applying s to v_height still not larger thatn c_height, then need to scale further
            s *= (c_height / (v_height * s));
        }

        CGAffineTransform goToOrigin = CGAffineTransformMakeTranslation(-CGRectGetMidX(viewRect), -CGRectGetMidY(viewRect));
        scaleT = CGAffineTransformMakeScale(s, s);
        CGAffineTransform backFromOrigin = CGAffineTransformMakeTranslation(CGRectGetMidX(viewRect), CGRectGetMidY(viewRect));

        CGAffineTransform rectT = CGAffineTransformConcat(CGAffineTransformConcat(goToOrigin, scaleT), backFromOrigin);

        //[self p_addTestView:viewRect];
        viewRect = CGRectApplyAffineTransform(viewRect, rectT); // will use this new viewRect to calculate the translate distance
        //[self p_addTestView:viewRect];
        v_width = viewRect.size.width;
        v_height = viewRect.size.height;
    }

    CGFloat v_leftX     = viewRect.origin.x;
    CGFloat v_rightX    = viewRect.origin.x + v_width;
    CGFloat v_topY      = viewRect.origin.y;
    CGFloat v_bottomY   = viewRect.origin.y + v_height;
    CGFloat c_leftX     = cropBoxRect.origin.x;
    CGFloat c_rightX    = cropBoxRect.origin.x + c_width;
    CGFloat c_topY      = cropBoxRect.origin.y;
    CGFloat c_bottomY   = cropBoxRect.origin.y + c_height;

    CGFloat transX = 0.0;
    CGFloat transY = 0.0;
    // include
    if (v_leftX <= c_leftX && v_rightX >= c_rightX) {
        transX = 0.0;
    }
    // intersect
    else if (v_leftX >= c_leftX && v_leftX <= c_rightX && v_rightX >= c_rightX) {
        transX = c_leftX - v_leftX;
    } else if (v_rightX >= c_leftX && v_rightX <= c_rightX && v_leftX <= c_leftX) {
        transX = c_rightX - v_rightX;
    }
    // exclude
    else if (v_rightX <= c_leftX) {
        transX = c_rightX - v_rightX;
    } else if (v_leftX >= c_rightX) {
        transX = c_leftX - v_leftX;
    } else {
        DLog(@"Cannot calculate transX!");
        return NO;
    }

    // include
    if (v_topY <= c_topY && v_bottomY >= c_bottomY) {
        transY = 0.0;
    }
    // intersect
    else if (v_topY >= c_topY && v_topY <= c_bottomY && v_bottomY >= c_bottomY) {
        transY = c_topY - v_topY;
    } else if (v_bottomY >= c_topY && v_bottomY <= c_bottomY && v_topY <= c_topY) {
        transY = c_bottomY - v_bottomY;
    }
    // exclude
    else if (v_bottomY <= c_topY) {
        transY = c_bottomY - v_bottomY;
    } else if (v_topY >= c_bottomY) {
        transY = c_topY - v_topY;
    } else {
        DLog(@"Cannot calculate transY!");
        return NO;
    }
    CGAffineTransform translationT = CGAffineTransformMakeTranslation(transX, transY);

    /* 一个没有修好的奇怪的Bug
        按理来说直接assign这个transform就应该anchor到位
        但是每次都会差那么一点.
        
     可以确定的是:
        单独进行translation的时候是没有一点问题的

        可能原因: frame在有transform的情况下是无效的.
     */
//    CGAffineTransform originalT = self.imageView.transform;
//    CGAffineTransform finalT = CGAffineTransformConcat(CGAffineTransformConcat(originalT, scaleT), translationT);
//    CGRect testFrame = CGRectApplyAffineTransform(self.imageView.originalFrame, finalT);
//    [self p_addTestView:testFrame color:UIColor.blueColor];

    CGRect finalFrame = CGRectApplyAffineTransform(viewRect, translationT); // viewRect has already beend scaled

    // Start anchoring
    self.isAnchoring = YES;
    [UIView animateWithDuration:0.2 animations:^{
        //self.imageView.transform = finalT; // anchor imageview

        // Transform Bug
        self.imageView.transform = CGAffineTransformIdentity;
        self.imageView.frame = finalFrame;
    } completion:^(BOOL finished) {
        // Finish anchoring
        self.isAnchoring = NO;
        // Crop box anchoring might be interruptted by the move of imageview, so call anchoring of cropbox again
        [self performSelector:@selector(p_autoAnchorCropBox) withObject:nil afterDelay:1.5];
    }];

    return YES;
}

# pragma mark - Getters

- (CGRect)imagePresentingFrame {
    [self layoutIfNeeded]; // Make sure the imageView has been layouted and its frame is most updated
    return [self.imageView imageFrameAfterAspectFitScaled]; // Then the calculation which based on the imageView's frame can be correct
}

- (CGRect)imageOriginalFrame {
    return CGRectMake(0, 0, self.image.size.width, self.image.size.height);
}

- (UIImage *)croppedImage {
    CGRect imageRect = self.imageView.imageFrameAfterAspectFitScaled;
    CGRect boxRect = self.cropBox.cropBoxFrame;

    CGAffineTransform t = [ECGraphicsUtility transformMatrixFromRect:imageRect toRect:(CGRect){CGPointZero, self.imageView.image.size}];
    CGRect croppedImageRect = CGRectApplyAffineTransform(boxRect, t);

    UIImage *image = self.imageView.image.imageWithPortraitOrientation; // fix orientation
    CGImageRef subImage = CGImageCreateWithImageInRect(image.CGImage, croppedImageRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:subImage];
    CGImageRelease(subImage);

    return croppedImage;
}

- (UIBezierPath *)basePath {
    [self layoutIfNeeded]; // ensure the frame is updated
    return [UIBezierPath bezierPathWithRect:self.bounds];
}

- (BOOL)isCropBoxInsideImage {
    CGRect imageRect = self.imagePresentingFrame;
    CGRect boxRect = self.cropBox.cropBoxFrame;
    return CGRectContainsRect(imageRect, boxRect);
}

- (CGRect)preferredCropRect {
    [self layoutIfNeeded];

    CGFloat preferredWidth = self.bounds.size.width * PreferredWidthPortion;
    CGFloat preferredHeight = self.bounds.size.height * PreferredHeightPortion;
    CGFloat preferredX = self.center.x - preferredWidth / 2.0;
    CGFloat preferredY = self.center.y - preferredHeight / 2.0;
    CGRect preferredRect = CGRectMake(preferredX, preferredY, preferredWidth, preferredHeight);
    return preferredRect;
}

# pragma mark - Setters

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = _image; // populate the new image
    [self removeCropBox];
}

- (void)setCropLocked:(BOOL)cropLocked {
    @synchronized (self) {
        _cropLocked = cropLocked;
        self.userInteractionEnabled = !cropLocked;
    }
}

- (BOOL)cropLocked {
    @synchronized (self) {
        return _cropLocked;
    }
}

- (void)setIsAnchoring:(BOOL)isAnchoring {
    @synchronized (self) {
        _isAnchoring = isAnchoring;
        self.userInteractionEnabled = !isAnchoring;
    }
}

- (BOOL)isAnchoring {
    @synchronized (self) {
        return _isAnchoring;
    }
}

# pragma mark - Lazy Initialization

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (CAShapeLayer *)highlightedLayer {
    if (!_highlightedLayer) {
        _highlightedLayer = [CAShapeLayer layer];
        _highlightedLayer.fillRule = kCAFillRuleEvenOdd;
        _highlightedLayer.opacity = 0.7;
    }
    return _highlightedLayer;
}

@end
