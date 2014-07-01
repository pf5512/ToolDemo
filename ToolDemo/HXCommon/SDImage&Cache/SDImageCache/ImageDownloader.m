//
//  UIImage+WebCache.m
//  SunboxSoft
//
//  Created by 雷 克 on 12-1-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageDownloader.h"
#import "SDWebImageManager.h"

@implementation ImageDownloader
@synthesize index;
@synthesize delegate;

- (void)dealloc
{
    NSLog(@"ImageDownloader dealloc");
    [self cancelCurrentImageLoad];
    [super dealloc];
}
- (void)setImageWithURL:(NSURL *)url
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self];
    }
}
//如果想要此下载器正常析构，在确定不使用后应调用此方法。
- (void)cancelCurrentImageLoad
{
    [self setDelegate:nil];
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if (delegate && [delegate respondsToSelector:@selector(getImageBack:withImageDownloader:)])
    {
        [delegate getImageBack:image withImageDownloader:self];
    }
}

@end