//
//  ImageUtil.h
//  ImageProcessing
//
//  Created by Evangel on 10-11-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

@interface ImageUtil : NSObject 

+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize;
+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize;
+ (UIImage *)blackWhite:(UIImage *)inImage;
+ (UIImage *)cartoon:(UIImage *)inImage;
+ (UIImage *)memory:(UIImage *)inImage;
+ (UIImage *)bopo:(UIImage *)inImage;
+ (UIImage *)scanLine:(UIImage *)inImage;
+ (UIImage *)film:(UIImage *)inImage;      //胶片
+ (UIImage *)history:(UIImage *)inImage;   //复古
+ (UIImage *)lomo:(UIImage *)inImage;      //LOMO
+ (UIImage *)contrast:(UIImage *)inImage;  //反转
+ (UIImage *)reversal:(UIImage *)inImage;  //对比
+ (UIImage *)impression:(UIImage *)inImage;//印象
+ (UIImage *)studio:(UIImage *)inImage;    //影楼
+ (UIImage *)blackWhiteAndcontrast:(UIImage *)inImage;
+ (UIImage *)blackWhiteAndreversal:(UIImage *)inImage;
+ (UIImage *)blackWhiteAndhistory:(UIImage *)inImage;

@end
