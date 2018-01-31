//
//  ECViewController.m
//  EasyCrop
//
//  Created by nilinyi on 01/31/2018.
//  Copyright (c) 2018 nilinyi. All rights reserved.
//

#import "ECViewController.h"
#import <EasyCrop/EasyCrop.h>

@interface ECViewController ()
@property (nonatomic, readwrite, strong) EMOCRImageCropView *cropImageView;
@end

@implementation ECViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.cropImageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.cropImageView.frame = self.view.bounds;
}

- (EMOCRImageCropView *)cropImageView {
    if (_cropImageView) {
        return _cropImageView;
    }
    _cropImageView = [[EMOCRImageCropView alloc] initWithImage:[UIImage imageNamed:@"test_image"]];
    return _cropImageView;
}

@end
