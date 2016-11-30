//
//  UIView+Frame.h
//  testSegment
//
//  Created by lisongtao on 15/9/25.
//  Copyright © 2015年 lst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)
@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat right;
@property(nonatomic, assign) CGFloat bottom;
@property(nonatomic, assign) CGPoint origin;
@property(nonatomic, assign) CGSize size;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@end
