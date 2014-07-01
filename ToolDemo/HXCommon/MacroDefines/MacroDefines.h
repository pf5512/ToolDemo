//
//  MacroDefines.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-18.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

//屏幕尺寸
#define kScreen_Height  [[UIScreen mainScreen] bounds].size.height
#define kScreen_Width   [[UIScreen mainScreen] bounds].size.width

//rgb颜色
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

//设备为iPhone 5
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//快速生成image
#define UIImageWithName(imageName) [UIImage imageNamed:imageName]

//安全释放
#define RELEASE_SAFELY(_POINTER) if (nil != (_POINTER)){[_POINTER release];_POINTER = nil; }

#define RELEASE_TIMER_SAFELY(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

