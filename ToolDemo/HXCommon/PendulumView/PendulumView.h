//
//  PendulumView.h
//  PendulumView
//
//  Created by Tu You on 14-1-19.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

/*
注释:本类用于提供一个钟摆样式的等待框
 */
#import <UIKit/UIKit.h>

@interface PendulumView : UIView

- (id)initWithFrame:(CGRect)frame;  //默认ballColor为浅蓝色
- (id)initWithFrame:(CGRect)frame ballColor:(UIColor *)ballColor;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
