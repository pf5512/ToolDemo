//
//  MyLabel.h
//  JieXinIphone
//
//  Created by 高大鹏 on 14-5-8.
//  Copyright (c) 2014年 sunboxsoft. All rights reserved.
//

/*
    该类继承自UILabel，实现了UILabel不具备的垂直方向居上，居中，居下功能
    调用方法：
    MyLabel *label = [[MyLabel alloc] init];
    [label setVerticalAlignment:VerticalAlignmentTop];
 */
#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface MyLabel : UILabel
{
    @private
    VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end
