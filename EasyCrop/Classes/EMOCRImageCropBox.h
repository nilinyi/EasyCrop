//
//  EMOCRImageCropBox.h
//  EasyMenu
//
//  Created by Leo Ni on 6/4/17.
//  Copyright © 2017 ShaoXianDui. All rights reserved.
//

@class EMOCRImageCropView;
@class EMOCRImageCropBox;

@protocol EMOCRImageCropBoxDelegate <NSObject>

- (void)cropBox:(EMOCRImageCropBox *)cropBox gestureBegan:(UIGestureRecognizer *)gesture;
- (void)cropBox:(EMOCRImageCropBox *)cropBox gestureWillMove:(UIGestureRecognizer *)gesture;
- (void)cropBox:(EMOCRImageCropBox *)cropBox gestureDidMove:(UIGestureRecognizer *)gesture;
- (void)cropBox:(EMOCRImageCropBox *)cropBox gestureStopped:(UIGestureRecognizer *)gesture;
- (BOOL)cropBox:(EMOCRImageCropBox *)cropBox canPerformGesture:(UIGestureRecognizer *)gesture;
- (CGRect)boundaryForCropBox:(EMOCRImageCropBox *)cropBox;

@end

static const CGFloat PreferredWidthPortion = 0.85;
static const CGFloat PreferredHeightPortion = 0.75;

typedef NS_ENUM(NSInteger, EMOCRImageCropBoxMode) {
    EMOCRImageCropBoxInteractionMode,
    EMOCRImageCropBoxPresentingMode,
};

@interface EMOCRImageCropBox : UIView

/// 该crop box所在的crop view, 也是其delegate. 一般为该view的superview.
@property (nonatomic, readonly, weak)   EMOCRImageCropView<EMOCRImageCropBoxDelegate> *ocrImageCropView; // delegate
/// Set before view loaded
@property (nonatomic, readwrite, strong) UIColor *edgeColor;
/**
 If isGestureBusy is NO, it means all gestures are idle(not processing any gestures).
 Otherwise, some gesture is processing its gesture. It might be ongoing, might already stopped(fire cropBox:gestureStopped).
 */
@property (nonatomic, readonly, assign) BOOL isGestureBusy;
/// 当前多少gesture在处理中
@property (nonatomic, readonly, assign) NSInteger numOfGesturesInProcessing;
/// 展示模式 或者 互动模式
@property (nonatomic, readwrite, assign) EMOCRImageCropBoxMode mode;

/// 内部crop box的frame.
@property (nonatomic, readwrite, assign) CGRect cropBoxFrame;
- (CGRect)frameFromCropBoxFrame:(CGRect)cropBoxFrame;
/// 内部crop box加边缘线的frame.
@property (nonatomic, readwrite, assign) CGRect cropBoxFrameWithLineWidth;
- (CGRect)frameFromCropBoxFrameWithLineWidth:(CGRect)cropBoxFrameWithLineWidth;
/// 该view实际的frame. 内部crop box加边缘线以及外部触摸区的frame.
@property (nonatomic, readwrite, assign) CGRect cropBoxFrameWithLineWidthAndExtendedArea;
- (CGRect)frameFromCropBoxFrameWithLineWidthAndExtendedArea:(CGRect)cropBoxFrameWithLineWidthAndExtendedArea;

/// 检测一个CGPoint是否再touchArea内.
- (BOOL)isPointInsideTouchArea:(CGPoint)point;

/// 初始化传入的 frame 只是内部crop box的frame.
- (instancetype)initWithFrame:(CGRect)frame inOCRImageCropView:(EMOCRImageCropView<EMOCRImageCropBoxDelegate> *)ocrImageCropView;

/// Some layout metrics
@property (nonatomic, class, readonly, assign) CGFloat lineWidth;
@end
