
//
//  ViewController.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-18.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "ViewController.h"
#import "Tools.h"
#import "HttpServiceHelper.h"
#import "NSDate-Helper.h"
#import "NSString+MD5.h"
#import "pinyin.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioRecorder.h"
#import "ImageDownloader.h"
#import "UIImageView+WebCache.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TSPopoverController.h"
#import "TSActionSheet.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define Constant 189327
#define Video_Height 600

@interface NSURLRequest(ForSSL)

+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end

@implementation NSURLRequest(ForSSL)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host
{
    
}
@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
 	// Do any additional setup after loading the view, typically from a nib.
    /*
     测试OC中的多态性
     A *a = [[B alloc] init];
     [a eat];
     */
    
    /*
     测试父类对象指向子类引用
     UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 300)];
     label.backgroundColor = [UIColor yellowColor];
     label.tag = 102;
     [self.view addSubview:label];
     
     UIView *view = [self.view viewWithTag:102];
     NSLog(@"view tag:%d",view.tag);
     view.frame = CGRectMake(0, 400, 200, 300);
     */
    
    
    /*
     //只是个示例，模拟for循环中的内容
     float y = 0.0f;
     for(int i = 0; i < [_sourceArray count]; ++i)
     {
     NSDictionary *dic = [_sourceArray objectAtIndex:i];
     if ([[dic objectForKey:@"caption"] isEqualToString:@"img"])
     {
     ImageDownloader *imageDownloader = [[ImageDownloader alloc] init];
     [imageDownloader setIndex:i + Constant];
     [imageDownloader setImageWithURL:[NSURL URLWithString:@""]];
     
     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
     imageView.center = CGPointMake(kScreen_Width / 2, y + 100 / 2);
     imageView.tag = i + Constant;
     [self.view addSubview:imageView];
     [imageView release];
     
     y += 100;
     }
     else if ([[dic objectForKey:@"caption"] isEqualToString:@"video"])
     {
     NSURL *url = [NSURL fileURLWithPath:[dic objectForKey:@"content"]];
     
     //视频播放对象
     _movie = [[MPMoviePlayerController alloc] initWithContentURL:url];
     _movie.controlStyle = MPMovieControlStyleEmbedded;
     [_movie.view setFrame:CGRectMake(60, y, kScreen_Width - 120, Video_Height)];
     _movie.scalingMode = MPMovieScalingModeAspectFit;
     _movie.view.tag = i + Constant;
     [self.view addSubview:_movie.view];
     
     // 注册一个播放结束的通知
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(myMovieFinishedCallback:)
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:_movie];
     
     //获取视频缩略图
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveNotification:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
     
     NSMutableArray * allThumbnails = [NSMutableArray  arrayWithObjects:[NSNumber numberWithDouble:2.0],nil];
     [_movie requestThumbnailImagesAtTimes:allThumbnails timeOption:MPMovieTimeOptionExact];
     
     y += Video_Height;
     }
     else //剩下都用UILabel
     {
     CGRect frame = CGRectMake(0, y, kScreen_Width,kScreen_Height);
     CGSize labelsize = [[dic objectForKey:@"content"] sizeWithFont:[UIFont boldSystemFontOfSize: 16.0f]
     constrainedToSize:CGSizeMake(kScreen_Width, kScreen_Height)
     lineBreakMode:NSLineBreakByWordWrapping];
     
     frame.size.width = labelsize.width;
     frame.size.height = labelsize.height;
     
     UILabel *label = [[UILabel alloc] initWithFrame:frame];
     label.lineBreakMode = NSLineBreakByWordWrapping;
     label.numberOfLines = 0;
     label.text = [dic objectForKey:@"content"];
     [self.view addSubview:label];
     [label release];
     
     y += labelsize.height;
     }
     }
     
     */
    
    /*
     UIImage *tmpImage = [self getImageFromURL:@"http://photos.tuchong.com/292105/f/6750405.jpg"];
     
     UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tmpImage.size.width , tmpImage.size.height)];
     imageView.center = CGPointMake(kScreen_Width/2,imageView.frame.size.height/2);
     imageView.image = tmpImage;
     imageView.contentMode = UIViewContentModeScaleAspectFit;
     [self.view addSubview:imageView];
     [imageView release];
     
     imageView = nil;
     imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 250, 200, 200)];
     [imageView setImageWithURL:[NSURL URLWithString:@"http://img2.3lian.com/img2007/13/29/20080409094710646.png"] placeholderImage:[UIImage imageNamed:@"photo-6.png"]];
     imageView.contentMode = UIViewContentModeScaleAspectFit;
     [self.view addSubview:imageView];
     [imageView release];
     */
//    UIImage *image = [UIImage imageNamed:@"photo-6.png"];
//    CGSize size = image.size;
//    
//    UILabel *aaa = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 120)];
//    aaa.numberOfLines = 0;
//    aaa.text = @"\tadjsiajduaiudjai\nadsdamdjnaidia\t";
//    [self.view addSubview:aaa];
    
    /*
     UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
     [sv setContentSize:CGSizeMake(kScreen_Width, kScreen_Height*2)];
     sv.backgroundColor = [UIColor purpleColor];
     [self.view addSubview:sv];
     
     UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, kScreen_Width,kScreen_Height-80)];
     webview.backgroundColor = [UIColor yellowColor];
     webview.scrollView.scrollEnabled = NO;
     [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://site.baidu.com"]]];
     [sv addSubview:webview];
     */
    
    /*
     NSString *pathToPdfDoc = [[NSBundle mainBundle] pathForResource:@"myPDF" ofType:@"pdf"];
     NSURL *pdfUrl = [NSURL fileURLWithPath:pathToPdfDoc];
     document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfUrl);
     NSInteger totalPage = CGPDFDocumentGetNumberOfPages(document);
     NSLog(@"%d",totalPage);
     
     UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
     [sv setContentSize:CGSizeMake(kScreen_Width, 56789)];
     sv.backgroundColor = [UIColor purpleColor];
     [self.view addSubview:sv];
     
     NSURLRequest *request = [NSURLRequest requestWithURL:pdfUrl];
     UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, kScreen_Width,kScreen_Height*totalPage)];
     webview.backgroundColor = [UIColor clearColor];
     webview.scrollView.zoomScale = 5.0f;
     [webview loadRequest:request];
     [sv addSubview:webview];
     */
    
//    PDFDrawView *pdfView = [[PDFDrawView alloc] initWithFrame:CGRectMake(0, 20, kScreen_Width,kScreen_Height*totalPage)];
//    pdfView.backgroundColor = [UIColor yellowColor];
//    [sv addSubview:pdfView];
}

/*
 
 - (void)getImageBack:(UIImage *)image withImageDownloader:(ImageDownloader *)imageDownloader
 {
 NSInteger index = imageDownloader.index - Constant;
 UIImageView *imageView = (UIImageView *)[self.view viewWithTag:index - Constant];
 imageView.image = image;
 
 //调整图片尺寸适合屏幕
 imageView.frame = [self fitToScreen:imageView.frame];
 
 if (index == 0) {
 imageView.center = CGPointMake(kScreen_Width/2, image.size.height/2);
 }
 else
 {
 imageView.center = CGPointMake(kScreen_Width/2, CGRectGetMaxY([self.view viewWithTag:index -1 ].frame) + image.size.height/2);
 }
 
 //调整后面控件的Frame
 [self reloadSubviewFromIndex:index + 1];
 
 //将该下载器析构
 [imageDownloader cancelCurrentImageLoad];
 RELEASE_SAFELY(imageDownloader);
 }
 
 - (CGRect)fitToScreen:(CGRect)rect
 {
 CGFloat width = rect.size.width;
 CGFloat height = rect.size.height;
 CGFloat x = rect.origin.x;
 CGFloat y = rect.origin.y;
 
 //暂定每次缩小比率为0.7
 float rate = 1.0;
 while (width > kScreen_Width) {
 width *= 0.7;
 rate *= 0.7;
 }
 
 height *= rate;
 
 return CGRectMake(x, y, width, height);
 }
 
 - (void)reloadSubviewFromIndex:(NSInteger)index
 {
 if (index - Constant <= 0) {
 return;
 }
 
 //从获取到图片的下一个控件开始布局
 for (int i = index; i < [_sourceArray count] ; ++i)
 {
 UIView *view = [self.view viewWithTag:index];
 [view setFrame:CGRectMake(view.frame.origin.x, CGRectGetMaxY([self.view viewWithTag:index - 1].frame) + view.frame.size.height / 2, view.frame.size.width, view.frame.size.height)];
 }
 
 }
 
 
 
 #pragma mark -
 #pragma mark 视频播放
 
 -(void)playMovie
 {
 _cover.hidden = YES;
 _playBtn.hidden = YES;
 [_movie play];
 }
 
 #pragma mark -
 #pragma mark 获取缩略图通知回调
 
 -(void)receiveNotification:(NSNotification *)notify{
 NSLog(@"%@",[notify name]);
 [_movie pause];
 NSDictionary *info = [notify userInfo];
 //图片处理
 _cover = [[UIImageView alloc] initWithFrame:_movie.view.bounds];
 _cover.userInteractionEnabled = YES;
 _cover.image = [info objectForKey:@"MPMoviePlayerThumbnailImageKey"];
 [_movie.view addSubview:_cover];
 [_cover release];
 
 _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
 [_playBtn setImage:[UIImage imageNamed:@"video_demo2.png"] forState:UIControlStateNormal];
 [_playBtn setFrame:_movie.view.frame];
 [_playBtn addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:_playBtn];
 }
 
 #pragma mark -
 #pragma mark 视频播放结束委托
 
 -(void)myMovieFinishedCallback:(NSNotification*)notify
 {
 _playBtn.hidden = NO;
 _cover.hidden = NO;
 //视频播放对象
 MPMoviePlayerController* theMovie = [notify object];
 //销毁播放通知
 [[NSNotificationCenter defaultCenter] removeObserver:self
 name:MPMoviePlayerPlaybackDidFinishNotification
 object:theMovie];
 }
 */




/*
 -(UIImage *) getImageFromURL:(NSString *)fileURL {
 
 NSLog(@"执行图片下载函数");
 
 UIImage * result;
 
 NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
 
 result = [UIImage imageWithData:data];
 
 return result;
 
 }
 
 - (UIImage *)generatePhotoThumbnail:(UIImage *)image {
 
 // Create a thumbnail version of the image for the event object.
 
 CGSize size = image.size;
 
 CGSize croppedSize;
 
 CGFloat ratioX = 75.0;
 
 CGFloat ratioY = 60.0;
 
 CGFloat offsetX = 0.0;
 
 CGFloat offsetY = 0.0;
 
 
 
 // check the size of the image, we want to make it
 
 // a square with sides the size of the smallest dimension
 
 if (size.width > size.height) {
 
 offsetX = (size.height - size.width) / 2;
 
 croppedSize = CGSizeMake(size.height, size.height);
 
 } else {
 
 offsetY = (size.width - size.height) / 2;
 
 croppedSize = CGSizeMake(size.width, size.width);
 
 }
 
 
 
 // Crop the image before resize
 
 CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
 
 CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
 
 // Done cropping
 
 // Resize the image
 
 CGRect rect = CGRectMake(0.0, 0.0, ratioX, ratioY); // 设置图片缩微图的区域（（0，0），宽：75  高：60）
 
 UIGraphicsBeginImageContext(rect.size);
 
 [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
 
 UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
 
 UIGraphicsEndImageContext();
 
 // Done Resizing
 
 return thumbnail;
 
 }
 */

/*
 //音频播放
 - (void)dosometing:(UIButton *)sender
 {
 [[AudioRecorder defaultRecorder] startRecord];
 }
 
 - (void)play
 {
 [[AudioRecorder defaultRecorder] encode];
 }
 
 - (void)fretchAppVersion
 {
 [[HttpServiceHelper sharedService] requestForType:Http_FretchAppVersion info:nil target:self successSel:@"requestFinished:" failedSel:@"requestFailed:"];
 }
 
 - (void)requestFinished:(NSDictionary *)datas
 {
 
 }
 
 - (void)requestFailed:(id)sender
 {
 NSLog(@"failed:");
 }
 */


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
