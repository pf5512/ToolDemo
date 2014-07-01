//
//  ImageUtil.m
//  ImageProcessing
//
//  Created by Evangel on 10-11-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageUtil.h"

#include <sys/time.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

// Return a bitmap context using alpha/red/green/blue byte values 
CGContextRef CreateRGBABitmapContext (CGImageRef inImage) 
{
	CGContextRef context = NULL; 
	CGColorSpaceRef colorSpace; 
	void *bitmapData; 
	int bitmapByteCount; 
	int bitmapBytesPerRow;
	size_t pixelsWide = CGImageGetWidth(inImage); 
	size_t pixelsHigh = CGImageGetHeight(inImage); 
	bitmapBytesPerRow	= (pixelsWide * 4); 
	bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); 
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL) 
	{
		fprintf(stderr, "Error allocating color space\n"); return NULL;
	}
	// allocate the bitmap & create context 
	bitmapData = malloc( bitmapByteCount ); 
	if (bitmapData == NULL) 
	{
		fprintf (stderr, "Memory not allocated!"); 
		CGColorSpaceRelease( colorSpace ); 
		return NULL;
	}
	context = CGBitmapContextCreate (bitmapData, 
																	 pixelsWide, 
																	 pixelsHigh, 
																	 8, 
																	 bitmapBytesPerRow, 
																	 colorSpace, 
																	 kCGImageAlphaPremultipliedLast);
	if (context == NULL) 
	{
		free (bitmapData); 
		fprintf (stderr, "Context not created!");
	} 
	CGColorSpaceRelease( colorSpace ); 
	return context;
}

// Return Image Pixel data as an RGBA bitmap 
unsigned char *RequestImagePixelData(UIImage *inImage) 
{
	CGImageRef img = [inImage CGImage]; 
	CGSize size = [inImage size];
	CGContextRef cgctx = CreateRGBABitmapContext(img); 
	
	if (cgctx == NULL) 
		return NULL;
	
	CGRect rect = {{0,0},{size.width, size.height}}; 
	CGContextDrawImage(cgctx, rect, img); 
	unsigned char *data = CGBitmapContextGetData (cgctx); 
	CGContextRelease(cgctx);
	return data;
}

#pragma mark -
@implementation ImageUtil

+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize
{
	CGFloat scale;
	CGSize newsize;
	
	if(thisSize.width<aSize.width && thisSize.height < aSize.height)
	{
		newsize = thisSize;
	}
	else 
	{
		if(thisSize.width >= thisSize.height)
		{
			scale = aSize.width/thisSize.width;
			newsize.width = aSize.width;
			newsize.height = thisSize.height*scale;
		}
		else 
		{
			scale = aSize.height/thisSize.height;
			newsize.height = aSize.height;
			newsize.width = thisSize.width*scale;
		}
	}
	return newsize;
}

// Proportionately resize, completely fit in view, no cropping
+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) viewsize
{
	// calculate the fitted size
	CGSize size = [ImageUtil fitSize:image.size inSize:viewsize];
	
	UIGraphicsBeginImageContext(size);

	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[image drawInRect:rect];
	
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();  
	
	return newimg;  
}

#pragma mark -

+ (UIImage*)blackWhite:(UIImage*)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			int bw = (int)((red+green+blue)/3.0);
			
			imgPixel[pixOff] = bw;
			imgPixel[pixOff+1] = bw;
			imgPixel[pixOff+2] = bw;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
																			bitsPerComponent, 
																			bitsPerPixel, 
																			bytesPerRow, 
																			colorSpaceRef, 
																			bitmapInfo, 
																			provider, 
																			NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+ (UIImage*)cartoon:(UIImage*)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			int ava = (int)((red+green+blue)/3.0);
			
			int newAva = ava>128 ? 255 : 0;
			
			imgPixel[pixOff] = newAva;
			imgPixel[pixOff+1] = newAva;
			imgPixel[pixOff+2] = newAva;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
																			bitsPerComponent, 
																			bitsPerPixel, 
																			bytesPerRow, 
																			colorSpaceRef, 
																			bitmapInfo, 
																			provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+ (UIImage*)memory:(UIImage*)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			red = green = blue = ( red + green + blue ) /3;
			
			red += red*2;
			green = green*2;
			
			if(red > 255)
				red = 255;
			if(green > 255)
				green = 255;
			
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
																			bitsPerComponent, 
																			bitsPerPixel, 
																			bytesPerRow, 
																			colorSpaceRef, 
																			bitmapInfo, 
																			provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+ (UIImage*)bopo:(UIImage*)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	//printf("w:%d,h:%d",w,h);
	
	int i, j, m, n;
	int bRowOff;
	int width = 8;
	int height = 8;
	int centerW = width /2;
	int centerH = height /2;
	
	//fix the image to right size
	int modw = w%width;
	int modh = h%height;
	if(modw)	w = w - modw;
	if(modh)	h = h - modh;
	
	int br, bg, bb;
	int tr, tg, tb;
	
	double offset;
	//double **weight= malloc(height*width*sizeof(double));
	NSMutableArray *wei = [[NSMutableArray alloc] init];
	for(m = 0; m < height; m++)
	{
		NSMutableArray *t1 = [[NSMutableArray alloc] init];
		for(n = 0; n < width; n++)
		{
			[t1 addObject:[NSNull null]];
		}
		[wei	addObject:t1];
		[t1 release];
	}
	
	int total = 0;
	int max = (int)(pow(centerH, 2) + pow(centerW, 2));
	
	for(m = 0; m < height; m++)
	{
		for(n = 0; n < width; n++)
		{
			offset = max - (int)(pow((m - centerH), 2) + pow((n - centerW), 2));
			total += offset;
			//weight[m][n] = offset;
			[[wei objectAtIndex:m] insertObject:[NSNumber numberWithDouble:offset] atIndex:n];
		}
	}
	for(m = 0; m < height; m++)
	{
		for(n = 0; n < width; n++)
		{
			//weight[m][n] = weight[m][n] / total;
			double newVal = [[[wei objectAtIndex:m] objectAtIndex:n] doubleValue]/total;
			[[wei objectAtIndex:m] replaceObjectAtIndex:n 
																				withObject:[NSNumber numberWithDouble:newVal]];
		}
	}
	bRowOff = 0;
	for(j = 0; j < h; j+=height) 
	{
		int bPixOff = bRowOff;
		
		for(i = 0; i < w; i+=width) 
		{
			int bRowOff2 = bPixOff;
			
			tr = tg = tb = 0;
			
			for(m = 0; m < height; m++)
			{
				int bPixOff2 = bRowOff2;
				
				for(n = 0; n < width; n++)
				{
					tr += 255 - imgPixel[bPixOff2];
					tg += 255 - imgPixel[bPixOff2+1];
					tb += 255 - imgPixel[bPixOff2+2];
					
					bPixOff2 += 4;
				}
				
				bRowOff2 += w*4;
			}
			bRowOff2 = bPixOff;
			
			for(m = 0; m < height; m++)
			{
				int bPixOff2 = bRowOff2;
				for(n = 0; n < width; n++)
				{
					
					//offset = weight[m][n];
					offset =  [[[wei objectAtIndex:m] objectAtIndex:n] doubleValue];
					br = 255 - (int)(tr * offset);
					bg = 255 - (int)(tg * offset);
					bb = 255 - (int)(tb * offset);
					
					if(br < 0)
						br = 0;
					if(bg < 0)
						bg = 0;
					if(bb < 0)
						bb = 0;
					imgPixel[bPixOff2] = br;
					imgPixel[bPixOff2 +1] = bg;
					imgPixel[bPixOff2 +2] = bb;
					
					bPixOff2 += 4; // advance background to next pixel
				}
				bRowOff2 += w*4;
			}
			bPixOff += width*4; // advance background to next pixel
		}
		bRowOff += w * height*4;
	}
	[wei release];
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
																			bitsPerComponent, 
																			bitsPerPixel, 
																			bytesPerRow, 
																			colorSpaceRef, 
																			bitmapInfo, 
																			provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+(UIImage*)scanLine:(UIImage*)inImage
{
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y+=2)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
			int newR,newG,newB;
			int rr = red *2;
			newR = rr > 255 ? 255 : rr;
			int gg = green *2;
			newG = gg > 255 ? 255 : gg;
			int bb = blue *2;
			newB = bb > 255 ? 255 : bb;
			
			imgPixel[pixOff] = newR;
			imgPixel[pixOff+1] = newG;
			imgPixel[pixOff+2] = newB;
			
			pixOff += 4;
		}
		wOff += w * 4 *2;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
																			bitsPerComponent, 
																			bitsPerPixel, 
																			bytesPerRow, 
																			colorSpaceRef, 
																			bitmapInfo, 
																			provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+(UIImage *)film:(UIImage *)inImage {
	int d[]={
		0,0,0,20
		,1,0,0,21
		,2,0,0,21
		,3,0,0,23
		,4,0,0,24
		,5,0,0,24
		,6,0,0,26
		,7,0,0,28
		,8,0,0,28
		,9,0,0,29
		,10,0,0,31
		,11,0,0,31
		,12,0,0,33
		,13,0,0,34
		,14,0,0,34
		,15,0,0,36
		,16,0,0,37
		,17,0,0,37
		,18,0,0,39
		,19,0,0,41
		,20,0,0,41
		,21,0,0,42
		,22,0,0,44
		,23,0,0,44
		,24,0,0,46
		,25,0,0,47
		,26,0,0,47
		,27,0,0,49
		,28,0,0,50
		,29,0,0,50
		,30,0,0,52
		,31,0,0,53
		,32,0,0,53
		,33,0,0,55
		,34,0,0,57
		,35,0,0,57
		,36,0,0,58
		,37,0,0,60
		,38,0,0,60
		,39,0,0,61
		,40,0,0,63
		,41,0,0,63
		,42,0,0,65
		,43,0,0,66
		,44,0,0,66
		,45,0,0,68
		,46,0,0,69
		,47,0,0,69
		,48,0,0,71
		,49,0,0,72
		,50,0,0,72
		,51,0,0,74
		,52,0,0,75
		,53,0,0,75
		,54,0,0,77
		,55,0,0,79
		,56,0,0,79
		,57,0,0,80
		,58,0,0,82
		,59,0,0,82
		,60,0,0,83
		,61,0,2,85
		,62,0,3,85
		,63,0,5,86
		,64,0,7,88
		,65,0,8,88
		,66,0,10,89
		,67,0,11,91
		,68,0,13,91
		,69,0,15,92
		,70,0,18,94
		,71,0,20,94
		,72,0,21,95
		,73,0,23,97
		,74,0,24,97
		,75,0,28,98
		,76,2,29,100
		,77,3,31,100
		,78,7,34,101
		,79,8,36,103
		,80,11,37,103
		,81,13,41,104
		,82,16,42,106
		,83,20,46,106
		,84,21,47,107
		,85,24,50,108
		,86,28,52,108
		,87,31,55,110
		,88,33,57,111
		,89,36,60,111
		,90,39,61,113
		,91,42,65,114
		,92,46,66,114
		,93,49,69,116
		,94,52,72,117
		,95,55,74,117
		,96,58,77,118
		,97,61,80,120
		,98,65,82,120
		,99,69,85,121
		,100,72,88,123
		,101,75,89,123
		,102,79,92,124
		,103,83,95,125
		,104,86,98,125
		,105,89,100,127
		,106,92,103,128
		,107,97,106,128
		,108,100,108,129
		,109,104,110,131
		,110,107,113,131
		,111,111,116,132
		,112,114,118,133
		,113,118,121,133
		,114,121,123,135
		,115,125,125,136
		,116,128,128,136
		,117,132,131,137
		,118,135,133,139
		,119,139,136,139
		,120,142,137,140
		,121,145,140,141
		,122,149,142,141
		,123,152,145,142
		,124,156,148,144
		,125,159,150,144
		,126,162,152,145
		,127,166,154,146
		,128,169,156,146
		,129,172,159,148
		,130,175,161,149
		,131,178,163,149
		,132,181,166,150
		,133,184,168,151
		,134,188,169,151
		,135,191,171,152
		,136,194,174,154
		,137,197,176,154
		,138,199,178,155
		,139,202,180,156
		,140,205,181,156
		,141,208,183,157
		,142,211,186,159
		,143,214,188,159
		,144,217,190,160
		,145,219,191,161
		,146,222,193,161
		,147,225,195,162
		,148,228,197,163
		,149,232,199,163
		,150,234,200,164
		,151,237,202,166
		,152,240,204,166
		,153,242,206,167
		,154,245,207,168
		,155,248,209,168
		,156,251,211,169
		,157,253,212,170
		,158,255,214,170
		,159,255,216,171
		,160,255,217,172
		,161,255,218,172
		,162,255,219,174
		,163,255,221,175
		,164,255,223,175
		,165,255,224,176
		,166,255,226,177
		,167,255,227,177
		,168,255,229,178
		,169,255,230,179
		,170,255,232,179
		,171,255,232,180
		,172,255,234,181
		,173,255,235,181
		,174,255,237,182
		,175,255,238,183
		,176,255,239,183
		,177,255,241,184
		,178,255,242,186
		,179,255,242,186
		,180,255,244,187
		,181,255,245,188
		,182,255,246,188
		,183,255,247,189
		,184,255,248,190
		,185,255,250,190
		,186,255,251,191
		,187,255,251,192
		,188,255,252,192
		,189,255,253,193
		,190,255,254,194
		,191,255,255,194
		,192,255,255,195
		,193,255,255,196
		,194,255,255,196
		,195,255,255,197
		,196,255,255,198
		,197,255,255,198
		,198,255,255,199
		,199,255,255,200
		,200,255,255,200
		,201,255,255,201
		,202,255,255,202
		,203,255,255,202
		,204,255,255,203
		,205,255,255,204
		,206,255,255,204
		,207,255,255,205
		,208,255,255,206
		,209,255,255,206
		,210,255,255,207
		,211,255,255,208
		,212,255,255,208
		,213,255,255,209
		,214,255,255,210
		,215,255,255,210
		,216,255,255,211
		,217,255,255,212
		,218,255,255,212
		,219,255,255,213
		,220,255,255,214
		,221,255,255,214
		,222,255,255,215
		,223,255,255,216
		,224,255,255,216
		,225,255,255,217
		,226,255,255,218
		,227,255,255,218
		,228,255,255,218
		,229,255,255,219
		,230,255,255,219
		,231,255,255,220
		,232,255,255,221
		,233,255,255,221
		,234,255,255,222
		,235,255,255,223
		,236,255,255,223
		,237,255,255,224
		,238,255,255,225
		,239,255,255,225
		,240,255,255,226
		,241,255,255,227
		,242,255,255,227
		,243,255,255,228
		,244,255,255,229
		,245,255,255,229
		,246,255,255,230
		,247,255,255,231
		,248,255,255,231
		,249,255,255,232
		,250,255,255,232
		,251,255,255,232
		,252,255,255,233
		,253,255,255,234
		,254,255,255,234
		,255,255,255,235
		,
	};
	
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =d[4*red +1];
			green = d[4*green+2];
			blue = d[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+(UIImage *)history:(UIImage *)inImage {
//	NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"filterForText_history" ofType:@"txt"];
//	NSString *xmlContent2 = [NSString stringWithContentsOfFile:filePath2 
//													  encoding:NSUTF8StringEncoding
//														 error:nil];
//	NSArray *array = [xmlContent2 componentsSeparatedByString:@","];
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int b[]={
		0,54,31,0
		,1,54,31,1
		,2,54,31,2
		,3,54,31,4
		,4,54,31,5
		,5,54,32,6
		,6,54,32,7
		,7,54,32,8
		,8,54,32,9
		,9,54,32,11
		,10,54,32,12
		,11,54,32,13
		,12,54,32,14
		,13,54,33,15
		,14,54,33,16
		,15,54,33,18
		,16,54,33,19
		,17,55,33,20
		,18,55,33,21
		,19,55,33,23
		,20,55,34,24
		,21,55,34,26
		,22,55,34,27
		,23,55,34,28
		,24,55,34,29
		,25,55,35,30
		,26,56,35,31
		,27,56,35,32
		,28,56,35,33
		,29,56,35,35
		,30,56,36,36
		,31,57,36,37
		,32,57,36,38
		,33,57,36,40
		,34,57,36,41
		,35,59,37,42
		,36,59,37,43
		,37,59,37,44
		,38,59,38,46
		,39,60,38,47
		,40,60,38,48
		,41,61,38,49
		,42,61,40,51
		,43,61,40,52
		,44,62,40,53
		,45,62,41,54
		,46,63,41,55
		,47,63,41,56
		,48,64,42,57
		,49,64,42,59
		,50,65,43,60
		,51,65,43,61
		,52,67,43,62
		,53,68,44,63
		,54,68,44,64
		,55,69,45,65
		,56,70,45,67
		,57,70,46,68
		,58,71,46,69
		,59,72,47,70
		,60,74,47,71
		,61,74,48,72
		,62,75,48,74
		,63,76,49,75
		,64,77,51,76
		,65,78,51,77
		,66,80,52,78
		,67,81,52,78
		,68,82,53,80
		,69,83,54,81
		,70,84,54,82
		,71,85,55,83
		,72,87,56,84
		,73,88,57,85
		,74,89,57,85
		,75,90,59,87
		,76,91,60,88
		,77,93,61,89
		,78,95,61,90
		,79,96,62,90
		,80,97,63,91
		,81,98,64,93
		,82,100,65,94
		,83,102,67,94
		,84,103,68,95
		,85,104,69,96
		,86,106,70,97
		,87,108,71,97
		,88,109,72,98
		,89,110,74,100
		,90,112,75,100
		,91,114,76,101
		,92,115,77,102
		,93,117,78,102
		,94,118,80,103
		,95,119,81,104
		,96,122,82,104
		,97,123,84,106
		,98,125,85,107
		,99,126,87,107
		,100,128,88,108
		,101,130,90,108
		,102,131,91,109
		,103,133,93,110
		,104,134,95,110
		,105,136,96,111
		,106,137,97,111
		,107,139,100,112
		,108,140,101,114
		,109,141,102,114
		,110,144,104,115
		,111,145,106,115
		,112,147,108,116
		,113,148,109,116
		,114,150,110,117
		,115,151,112,117
		,116,153,114,118
		,117,154,116,119
		,118,156,117,119
		,119,157,119,121
		,120,159,121,121
		,121,160,123,122
		,122,161,124,122
		,123,163,126,123
		,124,164,127,123
		,125,166,130,124
		,126,167,131,124
		,127,169,133,125
		,128,170,135,126
		,129,171,136,126
		,130,172,138,127
		,131,173,139,127
		,132,175,141,128
		,133,176,142,128
		,134,177,145,130
		,135,179,146,130
		,136,180,148,131
		,137,181,149,132
		,138,183,151,132
		,139,184,152,133
		,140,185,154,133
		,141,186,156,134
		,142,187,157,134
		,143,188,159,135
		,144,189,160,136
		,145,191,162,136
		,146,192,163,137
		,147,193,165,137
		,148,194,166,138
		,149,194,167,139
		,150,195,169,139
		,151,197,170,140
		,152,198,171,141
		,153,199,172,141
		,154,200,174,142
		,155,201,175,144
		,156,202,176,144
		,157,202,178,145
		,158,203,179,146
		,159,204,180,146
		,160,205,182,147
		,161,206,183,148
		,162,207,184,149
		,163,208,185,149
		,164,209,186,150
		,165,210,187,151
		,166,210,188,152
		,167,210,190,152
		,168,211,191,153
		,169,212,192,154
		,170,213,193,155
		,171,214,194,156
		,172,214,194,156
		,173,215,195,157
		,174,216,196,158
		,175,216,197,159
		,176,216,198,160
		,177,217,199,161
		,178,218,200,162
		,179,218,201,163
		,180,219,202,164
		,181,219,202,165
		,182,220,203,166
		,183,221,204,167
		,184,221,205,168
		,185,222,206,169
		,186,222,206,170
		,187,223,207,171
		,188,223,208,171
		,189,223,209,172
		,190,223,210,173
		,191,224,210,174
		,192,224,210,175
		,193,225,211,176
		,194,225,211,177
		,195,226,212,179
		,196,226,213,180
		,197,227,213,181
		,198,227,214,182
		,199,227,215,184
		,200,228,215,185
		,201,228,216,185
		,202,229,216,186
		,203,229,216,188
		,204,229,217,189
		,205,229,217,190
		,206,229,218,192
		,207,229,218,193
		,208,230,219,194
		,209,230,219,195
		,210,230,220,196
		,211,230,220,197
		,212,231,221,199
		,213,231,221,200
		,214,231,221,202
		,215,231,222,202
		,216,232,222,204
		,217,232,223,205
		,218,232,223,207
		,219,232,223,208
		,220,233,223,210
		,221,233,223,210
		,222,233,223,212
		,223,233,224,213
		,224,233,224,215
		,225,234,224,216
		,226,234,225,217
		,227,234,225,218
		,228,234,225,220
		,229,234,226,221
		,230,234,226,223
		,231,234,226,224
		,232,235,227,225
		,233,235,227,227
		,234,235,227,228
		,235,235,227,229
		,236,235,228,231
		,237,235,228,232
		,238,235,228,234
		,239,235,228,235
		,240,235,229,236
		,241,235,229,238
		,242,235,229,239
		,243,235,229,241
		,244,235,229,242
		,245,235,229,243
		,246,235,229,245
		,247,235,229,246
		,248,235,229,247
		,249,235,230,249
		,250,236,230,251
		,251,236,230,252
		,252,236,230,253
		,253,236,231,255
		,254,236,231,255
		,255,236,231,255
		,
	};
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =b[4*red +1];
			green = b[4*green+2];
			blue = b[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}
+(UIImage *)lomo:(UIImage *)inImage {
	
	int c[]={
		0,68,30,72
		,1,68,30,72
		,2,66,31,73
		,3,66,31,73
		,4,65,31,73
		,5,65,33,74
		,6,64,33,74
		,7,64,33,74
		,8,62,34,76
		,9,62,34,76
		,10,61,34,76
		,11,61,35,77
		,12,60,35,77
		,13,60,35,77
		,14,60,37,78
		,15,58,37,78
		,16,58,38,78
		,17,57,38,80
		,18,57,38,80
		,19,57,40,80
		,20,56,40,81
		,21,56,40,81
		,22,56,41,81
		,23,54,41,82
		,24,54,42,82
		,25,54,42,82
		,26,53,44,84
		,27,53,44,84
		,28,53,44,84
		,29,53,45,85
		,30,53,45,85
		,31,52,46,85
		,32,52,46,86
		,33,52,48,86
		,34,52,48,88
		,35,52,49,88
		,36,52,49,88
		,37,52,50,89
		,38,52,50,89
		,39,52,52,89
		,40,52,52,90
		,41,52,53,90
		,42,52,54,92
		,43,52,54,92
		,44,52,56,92
		,45,52,56,93
		,46,53,57,93
		,47,53,58,94
		,48,53,58,94
		,49,53,60,95
		,50,54,61,95
		,51,54,61,95
		,52,54,62,97
		,53,56,64,97
		,54,56,65,98
		,55,57,65,98
		,56,57,66,99
		,57,58,68,99
		,58,60,69,101
		,59,60,70,101
		,60,61,70,102
		,61,62,72,102
		,62,62,73,103
		,63,64,74,103
		,64,65,76,104
		,65,66,77,104
		,66,68,78,106
		,67,69,80,106
		,68,70,81,107
		,69,72,82,107
		,70,73,84,108
		,71,74,85,108
		,72,76,86,110
		,73,78,88,110
		,74,80,89,111
		,75,81,90,111
		,76,84,92,112
		,77,85,93,113
		,78,88,94,113
		,79,89,97,115
		,80,92,98,115
		,81,93,99,116
		,82,95,101,117
		,83,98,102,117
		,84,99,103,118
		,85,102,106,120
		,86,104,107,120
		,87,107,108,121
		,88,108,110,122
		,89,111,111,122
		,90,113,113,123
		,91,116,115,125
		,92,118,116,125
		,93,121,117,126
		,94,123,120,127
		,95,126,121,127
		,96,128,122,128
		,97,131,123,130
		,98,133,126,131
		,99,136,127,131
		,100,138,128,132
		,101,141,130,133
		,102,143,132,135
		,103,145,133,136
		,104,148,135,136
		,105,149,137,137
		,106,151,138,138
		,107,154,139,139
		,108,156,141,141
		,109,158,143,142
		,110,161,144,143
		,111,163,145,143
		,112,165,147,144
		,113,168,149,145
		,114,170,150,147
		,115,171,151,148
		,116,173,153,149
		,117,175,154,150
		,118,178,156,151
		,119,179,157,153
		,120,181,158,154
		,121,183,160,155
		,122,184,162,156
		,123,187,163,157
		,124,189,164,158
		,125,190,165,160
		,126,192,166,161
		,127,193,169,162
		,128,194,170,163
		,129,196,171,164
		,130,197,172,165
		,131,200,173,166
		,132,201,175,168
		,133,202,177,170
		,134,204,178,171
		,135,205,179,172
		,136,206,180,173
		,137,207,181,174
		,138,209,182,175
		,139,210,184,178
		,140,211,185,179
		,141,212,187,180
		,142,213,188,181
		,143,215,189,182
		,144,217,190,183
		,145,218,191,185
		,146,219,192,187
		,147,220,193,188
		,148,221,194,189
		,149,222,195,190
		,150,223,196,192
		,151,224,197,193
		,152,225,199,194
		,153,226,200,195
		,154,226,201,196
		,155,227,202,199
		,156,228,203,200
		,157,229,204,201
		,158,230,205,202
		,159,231,206,203
		,160,232,207,204
		,161,232,208,205
		,162,233,209,207
		,163,234,210,208
		,164,235,211,209
		,165,235,212,210
		,166,236,213,211
		,167,237,213,212
		,168,239,215,213
		,169,239,216,215
		,170,240,217,216
		,171,241,218,217
		,172,241,219,218
		,173,242,219,219
		,174,243,220,220
		,175,243,221,221
		,176,244,222,222
		,177,244,222,223
		,178,245,223,224
		,179,246,224,225
		,180,246,224,226
		,181,247,225,227
		,182,247,226,228
		,183,248,226,229
		,184,248,227,230
		,185,249,228,230
		,186,250,228,231
		,187,250,229,232
		,188,251,229,233
		,189,251,230,233
		,190,252,230,234
		,191,252,231,235
		,192,253,232,235
		,193,253,232,236
		,194,254,232,236
		,195,254,233,237
		,196,255,233,239
		,197,255,234,239
		,198,255,234,240
		,199,255,235,240
		,200,255,235,241
		,201,255,235,241
		,202,255,236,241
		,203,255,236,242
		,204,255,236,242
		,205,255,237,243
		,206,255,237,243
		,207,255,237,243
		,208,255,239,243
		,209,255,239,244
		,210,255,239,244
		,211,255,239,244
		,212,255,240,245
		,213,255,240,245
		,214,255,240,245
		,215,255,240,245
		,216,255,241,245
		,217,255,241,245
		,218,255,241,246
		,219,255,241,246
		,220,255,241,246
		,221,255,241,246
		,222,255,241,246
		,223,255,242,246
		,224,255,242,246
		,225,255,242,246
		,226,255,242,246
		,227,255,242,246
		,228,255,242,246
		,229,255,242,246
		,230,255,242,246
		,231,255,242,246
		,232,255,242,246
		,233,255,243,246
		,234,255,243,246
		,235,255,243,246
		,236,255,243,246
		,237,255,243,246
		,238,255,243,246
		,239,255,243,246
		,240,255,243,246
		,241,255,243,246
		,242,255,243,246
		,243,255,243,245
		,244,255,243,245
		,245,255,243,245
		,246,255,243,245
		,247,255,243,245
		,248,255,243,245
		,249,255,243,245
		,250,255,243,245
		,251,255,243,245
		,252,255,243,244
		,253,255,243,244
		,254,255,243,244
		,255,255,243,244
		,
	};	
	
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =c[4*red +1];
			green = c[4*green+2];
			blue = c[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+(UIImage *)contrast:(UIImage *)inImage {
	int a[]={
		0,255,255,255
		,1,255,255,255
		,2,255,255,255
		,3,255,255,255
		,4,255,255,255
		,5,255,255,255
		,6,255,255,255
		,7,255,255,255
		,8,255,255,255
		,9,255,255,255
		,10,255,255,255
		,11,255,255,255
		,12,255,255,255
		,13,255,255,255
		,14,255,255,255
		,15,255,255,255
		,16,255,255,255
		,17,255,255,255
		,18,255,255,255
		,19,255,255,255
		,20,255,255,255
		,21,255,255,255
		,22,255,255,255
		,23,255,255,255
		,24,255,255,255
		,25,255,255,255
		,26,255,255,251
		,27,255,255,247
		,28,255,255,243
		,29,255,252,240
		,30,255,250,236
		,31,255,247,232
		,32,255,244,228
		,33,255,242,224
		,34,254,239,220
		,35,252,236,216
		,36,251,234,213
		,37,250,231,209
		,38,248,228,205
		,39,247,226,201
		,40,245,223,198
		,41,244,220,194
		,42,243,218,190
		,43,241,215,186
		,44,240,212,183
		,45,239,210,179
		,46,237,207,175
		,47,236,204,172
		,48,234,202,168
		,49,233,199,165
		,50,232,196,161
		,51,230,194,157
		,52,229,191,154
		,53,228,188,150
		,54,226,186,147
		,55,225,183,144
		,56,223,181,140
		,57,222,178,137
		,58,221,175,134
		,59,219,173,130
		,60,218,170,127
		,61,216,168,124
		,62,215,165,121
		,63,214,162,117
		,64,212,160,114
		,65,211,157,111
		,66,209,155,108
		,67,208,152,105
		,68,207,150,102
		,69,205,147,99
		,70,204,144,96
		,71,202,142,94
		,72,201,139,91
		,73,199,137,88
		,74,198,134,85
		,75,196,132,82
		,76,195,129,79
		,77,194,127,77
		,78,192,125,74
		,79,191,122,71
		,80,189,120,69
		,81,188,117,66
		,82,186,115,63
		,83,185,112,61
		,84,183,110,58
		,85,182,108,56
		,86,180,105,53
		,87,179,103,51
		,88,177,100,48
		,89,176,98,46
		,90,174,96,43
		,91,173,93,41
		,92,171,91,38
		,93,169,89,36
		,94,168,86,33
		,95,166,84,31
		,96,165,81,28
		,97,163,79,26
		,98,162,77,24
		,99,160,75,21
		,100,159,72,19
		,101,157,70,17
		,102,155,68,14
		,103,154,65,12
		,104,152,63,9
		,105,150,61,7
		,106,149,58,5
		,107,147,56,2
		,108,146,54,0
		,109,144,52,0
		,110,142,49,0
		,111,141,47,0
		,112,139,45,0
		,113,137,43,0
		,114,136,40,0
		,115,134,38,0
		,116,132,36,0
		,117,130,34,0
		,118,129,31,0
		,119,127,29,0
		,120,125,27,0
		,121,124,25,0
		,122,122,22,0
		,123,120,20,0
		,124,118,18,0
		,125,116,16,0
		,126,115,13,0
		,127,113,11,0
		,128,111,9,0
		,129,109,7,0
		,130,107,4,0
		,131,106,2,0
		,132,104,0,0
		,133,102,0,0
		,134,100,0,0
		,135,98,0,0
		,136,96,0,0
		,137,95,0,0
		,138,93,0,0
		,139,91,0,0
		,140,89,0,0
		,141,87,0,0
		,142,85,0,0
		,143,83,0,0
		,144,81,0,0
		,145,79,0,0
		,146,77,0,0
		,147,76,0,0
		,148,74,0,0
		,149,72,0,0
		,150,70,0,0
		,151,68,0,0
		,152,66,0,0
		,153,64,0,0
		,154,62,0,0
		,155,60,0,0
		,156,58,0,0
		,157,56,0,0
		,158,54,0,0
		,159,52,0,0
		,160,50,0,0
		,161,48,0,0
		,162,46,0,0
		,163,44,0,0
		,164,42,0,0
		,165,40,0,0
		,166,38,0,0
		,167,36,0,0
		,168,34,0,0
		,169,32,0,0
		,170,30,0,0
		,171,28,0,0
		,172,26,0,0
		,173,24,0,0
		,174,22,0,0
		,175,20,0,0
		,176,18,0,0
		,177,16,0,0
		,178,14,0,0
		,179,12,0,0
		,180,10,0,0
		,181,8,0,0
		,182,6,0,0
		,183,4,0,0
		,184,2,0,0
		,185,0,0,0
		,186,0,0,0
		,187,0,0,0
		,188,0,0,0
		,189,0,0,0
		,190,0,0,0
		,191,0,0,0
		,192,0,0,0
		,193,0,0,0
		,194,0,0,0
		,195,0,0,0
		,196,0,0,0
		,197,0,0,0
		,198,0,0,0
		,199,0,0,0
		,200,0,0,0
		,201,0,0,0
		,202,0,0,0
		,203,0,0,0
		,204,0,0,0
		,205,0,0,0
		,206,0,0,0
		,207,0,0,0
		,208,0,0,0
		,209,0,0,0
		,210,0,0,0
		,211,0,0,0
		,212,0,0,0
		,213,0,0,0
		,214,0,0,0
		,215,0,0,0
		,216,0,0,0
		,217,0,0,0
		,218,0,0,0
		,219,0,0,0
		,220,0,0,0
		,221,0,0,0
		,222,0,0,0
		,223,0,0,0
		,224,0,0,0
		,225,0,0,0
		,226,0,0,0
		,227,0,0,0
		,228,0,0,0
		,229,0,0,0
		,230,0,0,0
		,231,0,0,0
		,232,0,0,0
		,233,0,0,0
		,234,0,0,0
		,235,0,0,0
		,236,0,0,0
		,237,0,0,0
		,238,0,0,0
		,239,0,0,0
		,240,0,0,0
		,241,0,0,0
		,242,0,0,0
		,243,0,0,0
		,244,0,0,0
		,245,0,0,0
		,246,0,0,0
		,247,0,0,0
		,248,0,0,0
		,249,0,0,0
		,250,0,0,0
		,251,0,0,0
		,252,0,0,0
		,253,0,0,0
		,254,0,0,0
		,255,0,0,0
		,
	};
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =a[4*red +1];
			green = a[4*green+2];
			blue = a[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}

+(UIImage *)reversal:(UIImage *)inImage//对比
{
	int a[] = {0,0,0,0
		,1,0,0,0
		,2,0,0,0
		,3,0,0,0
		,4,0,0,0
		,5,0,0,0
		,6,0,0,0
		,7,0,0,0
		,8,0,0,0
		,9,0,0,0
		,10,0,0,0
		,11,0,0,0
		,12,0,0,0
		,13,0,0,0
		,14,0,0,0
		,15,0,0,0
		,16,0,0,0
		,17,0,0,0
		,18,0,0,0
		,19,0,0,0
		,20,0,0,0
		,21,0,0,0
		,22,0,0,0
		,23,0,0,0
		,24,0,0,0
		,25,0,0,0
		,26,0,0,0
		,27,0,0,0
		,28,0,0,0
		,29,0,0,0
		,30,0,0,0
		,31,0,0,0
		,32,0,0,0
		,33,0,0,0
		,34,0,0,0
		,35,0,0,0
		,36,0,0,0
		,37,0,0,0
		,38,0,0,0
		,39,0,0,0
		,40,0,0,0
		,41,0,0,0
		,42,0,0,0
		,43,0,0,0
		,44,0,0,0
		,45,0,0,0
		,46,0,0,0
		,47,0,0,0
		,48,0,0,0
		,49,0,0,0
		,50,0,0,0
		,51,0,0,0
		,52,0,0,0
		,53,0,0,0
		,54,0,0,0
		,55,0,0,0
		,56,0,0,0
		,57,0,0,0
		,58,0,0,0
		,59,0,0,0
		,60,0,0,0
		,61,0,0,0
		,62,0,0,0
		,63,0,0,0
		,64,0,0,0
		,65,0,0,0
		,66,3,3,3
		,67,6,6,6
		,68,9,9,9
		,69,13,13,13
		,70,16,16,16
		,71,19,19,19
		,72,22,22,22
		,73,25,25,25
		,74,28,28,28
		,75,31,31,31
		,76,35,35,35
		,77,38,38,38
		,78,41,41,41
		,79,44,44,44
		,80,47,47,47
		,81,50,50,50
		,82,53,53,53
		,83,56,56,56
		,84,59,59,59
		,85,62,62,62
		,86,65,65,65
		,87,68,68,68
		,88,71,71,71
		,89,74,74,74
		,90,77,77,77
		,91,80,80,80
		,92,83,83,83
		,93,86,86,86
		,94,89,89,89
		,95,91,91,91
		,96,94,94,94
		,97,97,97,97
		,98,100,100,100
		,99,103,103,103
		,100,105,105,105
		,101,108,108,108
		,102,111,111,111
		,103,113,113,113
		,104,116,116,116
		,105,119,119,119
		,106,121,121,121
		,107,124,124,124
		,108,126,126,126
		,109,129,129,129
		,110,131,131,131
		,111,134,134,134
		,112,136,136,136
		,113,139,139,139
		,114,141,141,141
		,115,143,143,143
		,116,146,146,146
		,117,148,148,148
		,118,150,150,150
		,119,152,152,152
		,120,154,154,154
		,121,157,157,157
		,122,159,159,159
		,123,161,161,161
		,124,163,163,163
		,125,165,165,165
		,126,167,167,167
		,127,169,169,169
		,128,171,171,171
		,129,172,172,172
		,130,174,174,174
		,131,176,176,176
		,132,178,178,178
		,133,180,180,180
		,134,182,182,182
		,135,183,183,183
		,136,185,185,185
		,137,187,187,187
		,138,188,188,188
		,139,190,190,190
		,140,192,192,192
		,141,193,193,193
		,142,195,195,195
		,143,196,196,196
		,144,198,198,198
		,145,199,199,199
		,146,201,201,201
		,147,202,202,202
		,148,204,204,204
		,149,205,205,205
		,150,207,207,207
		,151,208,208,208
		,152,209,209,209
		,153,211,211,211
		,154,212,212,212
		,155,213,213,213
		,156,215,215,215
		,157,216,216,216
		,158,217,217,217
		,159,219,219,219
		,160,220,220,220
		,161,221,221,221
		,162,222,222,222
		,163,223,223,223
		,164,225,225,225
		,165,226,226,226
		,166,227,227,227
		,167,228,228,228
		,168,229,229,229
		,169,231,231,231
		,170,232,232,232
		,171,233,233,233
		,172,234,234,234
		,173,235,235,235
		,174,236,236,236
		,175,237,237,237
		,176,238,238,238
		,177,239,239,239
		,178,240,240,240
		,179,241,241,241
		,180,243,243,243
		,181,244,244,244
		,182,245,245,245
		,183,246,246,246
		,184,247,247,247
		,185,248,248,248
		,186,249,249,249
		,187,250,250,250
		,188,251,251,251
		,189,252,252,252
		,190,253,253,253
		,191,254,254,254
		,192,255,255,255
		,193,255,255,255
		,194,255,255,255
		,195,255,255,255
		,196,255,255,255
		,197,255,255,255
		,198,255,255,255
		,199,255,255,255
		,200,255,255,255
		,201,255,255,255
		,202,255,255,255
		,203,255,255,255
		,204,255,255,255
		,205,255,255,255
		,206,255,255,255
		,207,255,255,255
		,208,255,255,255
		,209,255,255,255
		,210,255,255,255
		,211,255,255,255
		,212,255,255,255
		,213,255,255,255
		,214,255,255,255
		,215,255,255,255
		,216,255,255,255
		,217,255,255,255
		,218,255,255,255
		,219,255,255,255
		,220,255,255,255
		,221,255,255,255
		,222,255,255,255
		,223,255,255,255
		,224,255,255,255
		,225,255,255,255
		,226,255,255,255
		,227,255,255,255
		,228,255,255,255
		,229,255,255,255
		,230,255,255,255
		,231,255,255,255
		,232,255,255,255
		,233,255,255,255
		,234,255,255,255
		,235,255,255,255
		,236,255,255,255
		,237,255,255,255
		,238,255,255,255
		,239,255,255,255
		,240,255,255,255
		,241,255,255,255
		,242,255,255,255
		,243,255,255,255
		,244,255,255,255
		,245,255,255,255
		,246,255,255,255
		,247,255,255,255
		,248,255,255,255
		,249,255,255,255
		,250,255,255,255
		,251,255,255,255
		,252,255,255,255
		,253,255,255,255
		,254,255,255,255
		,255,255,255,255
		,
	};
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =a[4*red +1];
			green = a[4*green+2];
			blue = a[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}
+(UIImage *)impression:(UIImage *)inImage//印象
{
	int a[]={
		0,0,0,0
		,1,0,1,4
		,2,1,1,7
		,3,1,2,11
		,4,1,4,15
		,5,1,4,18
		,6,1,5,22
		,7,2,6,25
		,8,2,7,29
		,9,2,7,32
		,10,3,9,35
		,11,3,10,38
		,12,3,10,41
		,13,4,11,44
		,14,4,12,47
		,15,4,13,49
		,16,4,14,52
		,17,5,15,54
		,18,5,15,56
		,19,6,16,58
		,20,6,17,60
		,21,7,18,62
		,22,7,19,64
		,23,7,20,65
		,24,7,20,67
		,25,8,22,69
		,26,8,22,70
		,27,9,23,72
		,28,10,25,74
		,29,10,25,76
		,30,10,26,78
		,31,11,27,80
		,32,11,28,82
		,33,12,29,84
		,34,12,29,85
		,35,13,31,88
		,36,13,31,90
		,37,14,32,92
		,38,15,33,93
		,39,15,34,95
		,40,16,35,97
		,41,17,36,98
		,42,17,37,100
		,43,18,38,101
		,44,19,39,103
		,45,20,40,104
		,46,20,41,106
		,47,21,41,107
		,48,22,42,109
		,49,23,43,110
		,50,24,44,111
		,51,25,45,113
		,52,26,46,114
		,53,27,47,115
		,54,27,48,116
		,55,29,49,116
		,56,29,50,117
		,57,31,51,119
		,58,32,52,120
		,59,33,52,121
		,60,34,53,122
		,61,35,55,122
		,62,36,55,124
		,63,37,56,125
		,64,39,57,126
		,65,40,58,128
		,66,41,59,129
		,67,42,60,129
		,68,44,61,130
		,69,45,61,132
		,70,46,62,133
		,71,47,63,133
		,72,48,64,134
		,73,50,65,136
		,74,51,65,137
		,75,52,66,137
		,76,54,67,138
		,77,55,68,140
		,78,57,69,141
		,79,58,70,141
		,80,59,72,143
		,81,61,73,144
		,82,62,74,144
		,83,63,75,145
		,84,65,77,147
		,85,66,78,148
		,86,67,80,148
		,87,69,81,150
		,88,70,83,151
		,89,72,85,151
		,90,74,86,153
		,91,76,88,154
		,92,78,89,154
		,93,81,91,156
		,94,83,93,156
		,95,86,95,157
		,96,89,97,159
		,97,92,98,159
		,98,95,100,160
		,99,98,102,162
		,100,101,103,162
		,101,104,106,163
		,102,108,108,163
		,103,111,109,165
		,104,115,111,166
		,105,119,113,166
		,106,122,115,168
		,107,125,117,168
		,108,129,119,169
		,109,133,121,171
		,110,136,122,171
		,111,140,125,172
		,112,144,126,172
		,113,147,128,174
		,114,151,130,174
		,115,154,132,176
		,116,157,134,176
		,117,162,136,177
		,118,165,137,179
		,119,168,140,179
		,120,171,141,180
		,121,176,143,180
		,122,179,145,182
		,123,182,147,182
		,124,185,148,183
		,125,188,150,183
		,126,191,153,185
		,127,195,154,185
		,128,198,156,187
		,129,201,157,187
		,130,203,159,188
		,131,206,160,188
		,132,209,162,190
		,133,213,165,190
		,134,214,166,190
		,135,218,168,191
		,136,221,169,191
		,137,223,171,193
		,138,226,172,193
		,139,228,174,195
		,140,231,176,195
		,141,233,177,196
		,142,236,179,196
		,143,238,180,198
		,144,240,182,198
		,145,243,182,198
		,146,245,183,200
		,147,246,185,200
		,148,248,187,201
		,149,250,188,201
		,150,253,190,203
		,151,255,191,203
		,152,255,193,203
		,153,255,193,205
		,154,255,195,205
		,155,255,196,206
		,156,255,198,206
		,157,255,198,206
		,158,255,200,208
		,159,255,201,208
		,160,255,203,208
		,161,255,203,209
		,162,255,205,209
		,163,255,206,211
		,164,255,206,211
		,165,255,208,211
		,166,255,209,213
		,167,255,209,213
		,168,255,211,213
		,169,255,213,214
		,170,255,213,214
		,171,255,214,216
		,172,255,214,216
		,173,255,216,216
		,174,255,216,218
		,175,255,218,218
		,176,255,219,218
		,177,255,219,219
		,178,255,221,219
		,179,255,221,219
		,180,255,223,221
		,181,255,223,221
		,182,255,225,221
		,183,255,225,223
		,184,255,226,223
		,185,255,226,223
		,186,255,226,225
		,187,255,228,225
		,188,255,228,225
		,189,255,230,225
		,190,255,230,226
		,191,255,231,226
		,192,255,231,226
		,193,255,231,228
		,194,255,233,228
		,195,255,233,228
		,196,255,233,230
		,197,255,235,230
		,198,255,235,230
		,199,255,236,230
		,200,255,236,231
		,201,255,236,231
		,202,255,238,231
		,203,255,238,233
		,204,255,238,233
		,205,255,238,233
		,206,255,240,233
		,207,255,240,235
		,208,255,240,235
		,209,255,241,235
		,210,255,241,236
		,211,255,241,236
		,212,255,241,236
		,213,255,243,236
		,214,255,243,238
		,215,255,243,238
		,216,255,243,238
		,217,255,245,238
		,218,255,245,240
		,219,255,245,240
		,220,255,245,240
		,221,255,245,241
		,222,255,246,241
		,223,255,246,241
		,224,255,246,241
		,225,255,246,243
		,226,255,246,243
		,227,255,248,243
		,228,255,248,243
		,229,255,248,245
		,230,255,248,245
		,231,255,248,245
		,232,255,250,245
		,233,255,250,246
		,234,255,250,246
		,235,255,250,246
		,236,255,250,246
		,237,255,250,248
		,238,255,252,248
		,239,255,252,248
		,240,255,252,248
		,241,255,252,250
		,242,255,252,250
		,243,255,252,250
		,244,255,252,250
		,245,255,253,252
		,246,255,253,252
		,247,255,253,252
		,248,255,253,252
		,249,255,253,253
		,250,255,253,253
		,251,255,253,253
		,252,255,255,253
		,253,255,255,255
		,254,255,255,255
		,255,255,255,255
		,
	};
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =a[4*red +1];
			green = a[4*green+2];
			blue = a[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
}
+(UIImage *)studio:(UIImage *)inImage// 影楼
{
	int a[]={
		0,0,0,0
		,1,0,0,2
		,2,0,0,5
		,3,0,0,7
		,4,0,0,10
		,5,0,0,11
		,6,0,0,13
		,7,0,0,16
		,8,0,0,18
		,9,0,0,21
		,10,0,0,23
		,11,0,0,26
		,12,0,0,28
		,13,0,0,29
		,14,0,0,33
		,15,0,0,34
		,16,0,0,37
		,17,0,0,39
		,18,0,0,41
		,19,0,0,44
		,20,0,0,45
		,21,0,0,47
		,22,0,0,50
		,23,0,0,52
		,24,0,0,55
		,25,0,0,56
		,26,0,0,58
		,27,0,0,61
		,28,0,0,62
		,29,0,0,64
		,30,0,0,67
		,31,0,0,69
		,32,0,0,70
		,33,0,0,71
		,34,0,0,74
		,35,0,0,76
		,36,0,0,77
		,37,0,0,80
		,38,0,0,82
		,39,2,0,83
		,40,2,0,84
		,41,2,0,87
		,42,3,0,89
		,43,3,0,90
		,44,3,0,91
		,45,5,0,94
		,46,5,0,95
		,47,7,2,97
		,48,7,2,98
		,49,8,3,99
		,50,8,5,102
		,51,10,7,103
		,52,10,8,104
		,53,11,8,106
		,54,13,10,107
		,55,13,11,108
		,56,15,15,109
		,57,16,16,110
		,58,18,18,112
		,59,18,20,114
		,60,20,21,115
		,61,21,25,116
		,62,23,26,117
		,63,25,28,119
		,64,26,31,120
		,65,28,33,121
		,66,29,36,122
		,67,31,39,123
		,68,33,42,124
		,69,34,44,124
		,70,36,47,125
		,71,39,50,126
		,72,41,53,127
		,73,42,56,128
		,74,44,59,129
		,75,47,62,130
		,76,49,67,131
		,77,52,70,131
		,78,53,73,132
		,79,56,77,133
		,80,58,80,134
		,81,61,84,134
		,82,64,89,135
		,83,66,91,136
		,84,69,95,137
		,85,71,99,137
		,86,74,103,138
		,87,76,107,138
		,88,79,110,138
		,89,82,114,139
		,90,84,117,139
		,91,87,122,140
		,92,91,125,141
		,93,94,128,141
		,94,97,131,142
		,95,99,134,142
		,96,103,137,143
		,97,106,139,143
		,98,108,142,144
		,99,112,145,144
		,100,114,147,145
		,101,117,149,145
		,102,121,152,145
		,103,123,153,145
		,104,126,156,146
		,105,129,158,146
		,106,132,160,147
		,107,135,162,147
		,108,137,164,148
		,109,139,165,148
		,110,142,167,149
		,111,145,169,149
		,112,147,171,149
		,113,149,172,149
		,114,151,174,149
		,115,153,176,150
		,116,156,177,150
		,117,157,179,151
		,118,159,181,151
		,119,161,182,152
		,120,163,183,152
		,121,165,185,153
		,122,167,187,153
		,123,168,188,153
		,124,170,190,154
		,125,172,191,154
		,126,173,193,155
		,127,175,194,155
		,128,176,196,156
		,129,178,197,156
		,130,179,198,156
		,131,181,199,157
		,132,183,201,158
		,133,184,202,158
		,134,186,204,159
		,135,187,205,159
		,136,188,206,159
		,137,190,208,160
		,138,191,208,161
		,139,193,210,161
		,140,193,211,162
		,141,195,212,162
		,142,196,213,163
		,143,198,214,163
		,144,199,215,164
		,145,200,217,165
		,146,202,217,165
		,147,203,219,165
		,148,204,220,166
		,149,205,221,167
		,150,206,222,167
		,151,208,223,168
		,152,208,224,168
		,153,210,224,169
		,154,211,226,169
		,155,212,227,170
		,156,213,228,171
		,157,214,228,172
		,158,215,229,172
		,159,216,230,173
		,160,217,231,173
		,161,218,231,174
		,162,219,232,174
		,163,220,233,175
		,164,221,234,176
		,165,222,235,176
		,166,223,235,177
		,167,224,236,178
		,168,224,237,179
		,169,225,238,179
		,170,226,238,180
		,171,227,239,181
		,172,228,239,181
		,173,229,240,182
		,174,230,241,183
		,175,230,242,183
		,176,231,242,184
		,177,231,242,185
		,178,232,243,186
		,179,233,244,186
		,180,234,244,187
		,181,235,245,188
		,182,235,245,188
		,183,235,246,189
		,184,236,246,190
		,185,237,246,191
		,186,238,247,191
		,187,238,247,192
		,188,238,248,193
		,189,239,248,193
		,190,240,249,195
		,191,240,249,196
		,192,241,249,196
		,193,241,249,197
		,194,242,249,198
		,195,242,250,199
		,196,242,250,199
		,197,243,251,200
		,198,243,251,201
		,199,244,251,202
		,200,244,252,203
		,201,245,252,204
		,202,245,252,205
		,203,246,253,205
		,204,246,253,206
		,205,246,253,207
		,206,246,253,208
		,207,247,253,209
		,208,247,253,210
		,209,247,253,211
		,210,248,253,211
		,211,248,253,213
		,212,249,254,214
		,213,249,254,214
		,214,249,254,215
		,215,249,254,216
		,216,249,254,217
		,217,249,254,218
		,218,250,255,219
		,219,250,255,220
		,220,250,255,221
		,221,250,255,222
		,222,251,255,223
		,223,251,255,224
		,224,251,255,224
		,225,251,255,225
		,226,252,255,227
		,227,252,255,228
		,228,252,255,228
		,229,252,255,229
		,230,252,255,231
		,231,253,255,231
		,232,253,255,232
		,233,253,255,233
		,234,253,255,235
		,235,253,255,235
		,236,253,255,236
		,237,253,255,237
		,238,253,255,238
		,239,253,255,239
		,240,253,255,240
		,241,253,255,241
		,242,253,255,242
		,243,254,255,243
		,244,254,255,244
		,245,254,255,245
		,246,254,255,246
		,247,254,255,247
		,248,254,255,248
		,249,254,255,249
		,250,254,255,250
		,251,255,255,251
		,252,255,255,252
		,253,255,255,253
		,254,255,255,254
		,255,255,255,255
		,
	};
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			red =a[4*red +1];
			green = a[4*green+2];
			blue = a[4*blue+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
	
}

+ (UIImage*)blackWhiteAndcontrast:(UIImage*)inImage {
	int a[]={
		0,255,255,255
		,1,255,255,255
		,2,255,255,255
		,3,255,255,255
		,4,255,255,255
		,5,255,255,255
		,6,255,255,255
		,7,255,255,255
		,8,255,255,255
		,9,255,255,255
		,10,255,255,255
		,11,255,255,255
		,12,255,255,255
		,13,255,255,255
		,14,255,255,255
		,15,255,255,255
		,16,255,255,255
		,17,255,255,255
		,18,255,255,255
		,19,255,255,255
		,20,255,255,255
		,21,255,255,255
		,22,255,255,255
		,23,255,255,255
		,24,255,255,255
		,25,255,255,255
		,26,255,255,251
		,27,255,255,247
		,28,255,255,243
		,29,255,252,240
		,30,255,250,236
		,31,255,247,232
		,32,255,244,228
		,33,255,242,224
		,34,254,239,220
		,35,252,236,216
		,36,251,234,213
		,37,250,231,209
		,38,248,228,205
		,39,247,226,201
		,40,245,223,198
		,41,244,220,194
		,42,243,218,190
		,43,241,215,186
		,44,240,212,183
		,45,239,210,179
		,46,237,207,175
		,47,236,204,172
		,48,234,202,168
		,49,233,199,165
		,50,232,196,161
		,51,230,194,157
		,52,229,191,154
		,53,228,188,150
		,54,226,186,147
		,55,225,183,144
		,56,223,181,140
		,57,222,178,137
		,58,221,175,134
		,59,219,173,130
		,60,218,170,127
		,61,216,168,124
		,62,215,165,121
		,63,214,162,117
		,64,212,160,114
		,65,211,157,111
		,66,209,155,108
		,67,208,152,105
		,68,207,150,102
		,69,205,147,99
		,70,204,144,96
		,71,202,142,94
		,72,201,139,91
		,73,199,137,88
		,74,198,134,85
		,75,196,132,82
		,76,195,129,79
		,77,194,127,77
		,78,192,125,74
		,79,191,122,71
		,80,189,120,69
		,81,188,117,66
		,82,186,115,63
		,83,185,112,61
		,84,183,110,58
		,85,182,108,56
		,86,180,105,53
		,87,179,103,51
		,88,177,100,48
		,89,176,98,46
		,90,174,96,43
		,91,173,93,41
		,92,171,91,38
		,93,169,89,36
		,94,168,86,33
		,95,166,84,31
		,96,165,81,28
		,97,163,79,26
		,98,162,77,24
		,99,160,75,21
		,100,159,72,19
		,101,157,70,17
		,102,155,68,14
		,103,154,65,12
		,104,152,63,9
		,105,150,61,7
		,106,149,58,5
		,107,147,56,2
		,108,146,54,0
		,109,144,52,0
		,110,142,49,0
		,111,141,47,0
		,112,139,45,0
		,113,137,43,0
		,114,136,40,0
		,115,134,38,0
		,116,132,36,0
		,117,130,34,0
		,118,129,31,0
		,119,127,29,0
		,120,125,27,0
		,121,124,25,0
		,122,122,22,0
		,123,120,20,0
		,124,118,18,0
		,125,116,16,0
		,126,115,13,0
		,127,113,11,0
		,128,111,9,0
		,129,109,7,0
		,130,107,4,0
		,131,106,2,0
		,132,104,0,0
		,133,102,0,0
		,134,100,0,0
		,135,98,0,0
		,136,96,0,0
		,137,95,0,0
		,138,93,0,0
		,139,91,0,0
		,140,89,0,0
		,141,87,0,0
		,142,85,0,0
		,143,83,0,0
		,144,81,0,0
		,145,79,0,0
		,146,77,0,0
		,147,76,0,0
		,148,74,0,0
		,149,72,0,0
		,150,70,0,0
		,151,68,0,0
		,152,66,0,0
		,153,64,0,0
		,154,62,0,0
		,155,60,0,0
		,156,58,0,0
		,157,56,0,0
		,158,54,0,0
		,159,52,0,0
		,160,50,0,0
		,161,48,0,0
		,162,46,0,0
		,163,44,0,0
		,164,42,0,0
		,165,40,0,0
		,166,38,0,0
		,167,36,0,0
		,168,34,0,0
		,169,32,0,0
		,170,30,0,0
		,171,28,0,0
		,172,26,0,0
		,173,24,0,0
		,174,22,0,0
		,175,20,0,0
		,176,18,0,0
		,177,16,0,0
		,178,14,0,0
		,179,12,0,0
		,180,10,0,0
		,181,8,0,0
		,182,6,0,0
		,183,4,0,0
		,184,2,0,0
		,185,0,0,0
		,186,0,0,0
		,187,0,0,0
		,188,0,0,0
		,189,0,0,0
		,190,0,0,0
		,191,0,0,0
		,192,0,0,0
		,193,0,0,0
		,194,0,0,0
		,195,0,0,0
		,196,0,0,0
		,197,0,0,0
		,198,0,0,0
		,199,0,0,0
		,200,0,0,0
		,201,0,0,0
		,202,0,0,0
		,203,0,0,0
		,204,0,0,0
		,205,0,0,0
		,206,0,0,0
		,207,0,0,0
		,208,0,0,0
		,209,0,0,0
		,210,0,0,0
		,211,0,0,0
		,212,0,0,0
		,213,0,0,0
		,214,0,0,0
		,215,0,0,0
		,216,0,0,0
		,217,0,0,0
		,218,0,0,0
		,219,0,0,0
		,220,0,0,0
		,221,0,0,0
		,222,0,0,0
		,223,0,0,0
		,224,0,0,0
		,225,0,0,0
		,226,0,0,0
		,227,0,0,0
		,228,0,0,0
		,229,0,0,0
		,230,0,0,0
		,231,0,0,0
		,232,0,0,0
		,233,0,0,0
		,234,0,0,0
		,235,0,0,0
		,236,0,0,0
		,237,0,0,0
		,238,0,0,0
		,239,0,0,0
		,240,0,0,0
		,241,0,0,0
		,242,0,0,0
		,243,0,0,0
		,244,0,0,0
		,245,0,0,0
		,246,0,0,0
		,247,0,0,0
		,248,0,0,0
		,249,0,0,0
		,250,0,0,0
		,251,0,0,0
		,252,0,0,0
		,253,0,0,0
		,254,0,0,0
		,255,0,0,0
		,
	};
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			int bw = (int)((red+green+blue)/3.0);
			red =a[4*bw +1];
			green = a[4*bw+2];
			blue = a[4*bw+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
	//return [self contrast:[self blackWhite:inImage]];
}

+ (UIImage*)blackWhiteAndreversal:(UIImage*)inImage {
	int a[] = {0,0,0,0
		,1,0,0,0
		,2,0,0,0
		,3,0,0,0
		,4,0,0,0
		,5,0,0,0
		,6,0,0,0
		,7,0,0,0
		,8,0,0,0
		,9,0,0,0
		,10,0,0,0
		,11,0,0,0
		,12,0,0,0
		,13,0,0,0
		,14,0,0,0
		,15,0,0,0
		,16,0,0,0
		,17,0,0,0
		,18,0,0,0
		,19,0,0,0
		,20,0,0,0
		,21,0,0,0
		,22,0,0,0
		,23,0,0,0
		,24,0,0,0
		,25,0,0,0
		,26,0,0,0
		,27,0,0,0
		,28,0,0,0
		,29,0,0,0
		,30,0,0,0
		,31,0,0,0
		,32,0,0,0
		,33,0,0,0
		,34,0,0,0
		,35,0,0,0
		,36,0,0,0
		,37,0,0,0
		,38,0,0,0
		,39,0,0,0
		,40,0,0,0
		,41,0,0,0
		,42,0,0,0
		,43,0,0,0
		,44,0,0,0
		,45,0,0,0
		,46,0,0,0
		,47,0,0,0
		,48,0,0,0
		,49,0,0,0
		,50,0,0,0
		,51,0,0,0
		,52,0,0,0
		,53,0,0,0
		,54,0,0,0
		,55,0,0,0
		,56,0,0,0
		,57,0,0,0
		,58,0,0,0
		,59,0,0,0
		,60,0,0,0
		,61,0,0,0
		,62,0,0,0
		,63,0,0,0
		,64,0,0,0
		,65,0,0,0
		,66,3,3,3
		,67,6,6,6
		,68,9,9,9
		,69,13,13,13
		,70,16,16,16
		,71,19,19,19
		,72,22,22,22
		,73,25,25,25
		,74,28,28,28
		,75,31,31,31
		,76,35,35,35
		,77,38,38,38
		,78,41,41,41
		,79,44,44,44
		,80,47,47,47
		,81,50,50,50
		,82,53,53,53
		,83,56,56,56
		,84,59,59,59
		,85,62,62,62
		,86,65,65,65
		,87,68,68,68
		,88,71,71,71
		,89,74,74,74
		,90,77,77,77
		,91,80,80,80
		,92,83,83,83
		,93,86,86,86
		,94,89,89,89
		,95,91,91,91
		,96,94,94,94
		,97,97,97,97
		,98,100,100,100
		,99,103,103,103
		,100,105,105,105
		,101,108,108,108
		,102,111,111,111
		,103,113,113,113
		,104,116,116,116
		,105,119,119,119
		,106,121,121,121
		,107,124,124,124
		,108,126,126,126
		,109,129,129,129
		,110,131,131,131
		,111,134,134,134
		,112,136,136,136
		,113,139,139,139
		,114,141,141,141
		,115,143,143,143
		,116,146,146,146
		,117,148,148,148
		,118,150,150,150
		,119,152,152,152
		,120,154,154,154
		,121,157,157,157
		,122,159,159,159
		,123,161,161,161
		,124,163,163,163
		,125,165,165,165
		,126,167,167,167
		,127,169,169,169
		,128,171,171,171
		,129,172,172,172
		,130,174,174,174
		,131,176,176,176
		,132,178,178,178
		,133,180,180,180
		,134,182,182,182
		,135,183,183,183
		,136,185,185,185
		,137,187,187,187
		,138,188,188,188
		,139,190,190,190
		,140,192,192,192
		,141,193,193,193
		,142,195,195,195
		,143,196,196,196
		,144,198,198,198
		,145,199,199,199
		,146,201,201,201
		,147,202,202,202
		,148,204,204,204
		,149,205,205,205
		,150,207,207,207
		,151,208,208,208
		,152,209,209,209
		,153,211,211,211
		,154,212,212,212
		,155,213,213,213
		,156,215,215,215
		,157,216,216,216
		,158,217,217,217
		,159,219,219,219
		,160,220,220,220
		,161,221,221,221
		,162,222,222,222
		,163,223,223,223
		,164,225,225,225
		,165,226,226,226
		,166,227,227,227
		,167,228,228,228
		,168,229,229,229
		,169,231,231,231
		,170,232,232,232
		,171,233,233,233
		,172,234,234,234
		,173,235,235,235
		,174,236,236,236
		,175,237,237,237
		,176,238,238,238
		,177,239,239,239
		,178,240,240,240
		,179,241,241,241
		,180,243,243,243
		,181,244,244,244
		,182,245,245,245
		,183,246,246,246
		,184,247,247,247
		,185,248,248,248
		,186,249,249,249
		,187,250,250,250
		,188,251,251,251
		,189,252,252,252
		,190,253,253,253
		,191,254,254,254
		,192,255,255,255
		,193,255,255,255
		,194,255,255,255
		,195,255,255,255
		,196,255,255,255
		,197,255,255,255
		,198,255,255,255
		,199,255,255,255
		,200,255,255,255
		,201,255,255,255
		,202,255,255,255
		,203,255,255,255
		,204,255,255,255
		,205,255,255,255
		,206,255,255,255
		,207,255,255,255
		,208,255,255,255
		,209,255,255,255
		,210,255,255,255
		,211,255,255,255
		,212,255,255,255
		,213,255,255,255
		,214,255,255,255
		,215,255,255,255
		,216,255,255,255
		,217,255,255,255
		,218,255,255,255
		,219,255,255,255
		,220,255,255,255
		,221,255,255,255
		,222,255,255,255
		,223,255,255,255
		,224,255,255,255
		,225,255,255,255
		,226,255,255,255
		,227,255,255,255
		,228,255,255,255
		,229,255,255,255
		,230,255,255,255
		,231,255,255,255
		,232,255,255,255
		,233,255,255,255
		,234,255,255,255
		,235,255,255,255
		,236,255,255,255
		,237,255,255,255
		,238,255,255,255
		,239,255,255,255
		,240,255,255,255
		,241,255,255,255
		,242,255,255,255
		,243,255,255,255
		,244,255,255,255
		,245,255,255,255
		,246,255,255,255
		,247,255,255,255
		,248,255,255,255
		,249,255,255,255
		,250,255,255,255
		,251,255,255,255
		,252,255,255,255
		,253,255,255,255
		,254,255,255,255
		,255,255,255,255
		,
	};
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			int bw = (int)((red+green+blue)/3.0);
			red =a[4*bw +1];
			green = a[4*bw+2];
			blue = a[4*bw+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
	
	//return [self reversal:[self blackWhite:inImage]];
}
+ (UIImage*)blackWhiteAndhistory:(UIImage*)inImage {
	unsigned char *imgPixel = RequestImagePixelData(inImage);
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int a[]={
		0,54,31,0
		,1,54,31,1
		,2,54,31,2
		,3,54,31,4
		,4,54,31,5
		,5,54,32,6
		,6,54,32,7
		,7,54,32,8
		,8,54,32,9
		,9,54,32,11
		,10,54,32,12
		,11,54,32,13
		,12,54,32,14
		,13,54,33,15
		,14,54,33,16
		,15,54,33,18
		,16,54,33,19
		,17,55,33,20
		,18,55,33,21
		,19,55,33,23
		,20,55,34,24
		,21,55,34,26
		,22,55,34,27
		,23,55,34,28
		,24,55,34,29
		,25,55,35,30
		,26,56,35,31
		,27,56,35,32
		,28,56,35,33
		,29,56,35,35
		,30,56,36,36
		,31,57,36,37
		,32,57,36,38
		,33,57,36,40
		,34,57,36,41
		,35,59,37,42
		,36,59,37,43
		,37,59,37,44
		,38,59,38,46
		,39,60,38,47
		,40,60,38,48
		,41,61,38,49
		,42,61,40,51
		,43,61,40,52
		,44,62,40,53
		,45,62,41,54
		,46,63,41,55
		,47,63,41,56
		,48,64,42,57
		,49,64,42,59
		,50,65,43,60
		,51,65,43,61
		,52,67,43,62
		,53,68,44,63
		,54,68,44,64
		,55,69,45,65
		,56,70,45,67
		,57,70,46,68
		,58,71,46,69
		,59,72,47,70
		,60,74,47,71
		,61,74,48,72
		,62,75,48,74
		,63,76,49,75
		,64,77,51,76
		,65,78,51,77
		,66,80,52,78
		,67,81,52,78
		,68,82,53,80
		,69,83,54,81
		,70,84,54,82
		,71,85,55,83
		,72,87,56,84
		,73,88,57,85
		,74,89,57,85
		,75,90,59,87
		,76,91,60,88
		,77,93,61,89
		,78,95,61,90
		,79,96,62,90
		,80,97,63,91
		,81,98,64,93
		,82,100,65,94
		,83,102,67,94
		,84,103,68,95
		,85,104,69,96
		,86,106,70,97
		,87,108,71,97
		,88,109,72,98
		,89,110,74,100
		,90,112,75,100
		,91,114,76,101
		,92,115,77,102
		,93,117,78,102
		,94,118,80,103
		,95,119,81,104
		,96,122,82,104
		,97,123,84,106
		,98,125,85,107
		,99,126,87,107
		,100,128,88,108
		,101,130,90,108
		,102,131,91,109
		,103,133,93,110
		,104,134,95,110
		,105,136,96,111
		,106,137,97,111
		,107,139,100,112
		,108,140,101,114
		,109,141,102,114
		,110,144,104,115
		,111,145,106,115
		,112,147,108,116
		,113,148,109,116
		,114,150,110,117
		,115,151,112,117
		,116,153,114,118
		,117,154,116,119
		,118,156,117,119
		,119,157,119,121
		,120,159,121,121
		,121,160,123,122
		,122,161,124,122
		,123,163,126,123
		,124,164,127,123
		,125,166,130,124
		,126,167,131,124
		,127,169,133,125
		,128,170,135,126
		,129,171,136,126
		,130,172,138,127
		,131,173,139,127
		,132,175,141,128
		,133,176,142,128
		,134,177,145,130
		,135,179,146,130
		,136,180,148,131
		,137,181,149,132
		,138,183,151,132
		,139,184,152,133
		,140,185,154,133
		,141,186,156,134
		,142,187,157,134
		,143,188,159,135
		,144,189,160,136
		,145,191,162,136
		,146,192,163,137
		,147,193,165,137
		,148,194,166,138
		,149,194,167,139
		,150,195,169,139
		,151,197,170,140
		,152,198,171,141
		,153,199,172,141
		,154,200,174,142
		,155,201,175,144
		,156,202,176,144
		,157,202,178,145
		,158,203,179,146
		,159,204,180,146
		,160,205,182,147
		,161,206,183,148
		,162,207,184,149
		,163,208,185,149
		,164,209,186,150
		,165,210,187,151
		,166,210,188,152
		,167,210,190,152
		,168,211,191,153
		,169,212,192,154
		,170,213,193,155
		,171,214,194,156
		,172,214,194,156
		,173,215,195,157
		,174,216,196,158
		,175,216,197,159
		,176,216,198,160
		,177,217,199,161
		,178,218,200,162
		,179,218,201,163
		,180,219,202,164
		,181,219,202,165
		,182,220,203,166
		,183,221,204,167
		,184,221,205,168
		,185,222,206,169
		,186,222,206,170
		,187,223,207,171
		,188,223,208,171
		,189,223,209,172
		,190,223,210,173
		,191,224,210,174
		,192,224,210,175
		,193,225,211,176
		,194,225,211,177
		,195,226,212,179
		,196,226,213,180
		,197,227,213,181
		,198,227,214,182
		,199,227,215,184
		,200,228,215,185
		,201,228,216,185
		,202,229,216,186
		,203,229,216,188
		,204,229,217,189
		,205,229,217,190
		,206,229,218,192
		,207,229,218,193
		,208,230,219,194
		,209,230,219,195
		,210,230,220,196
		,211,230,220,197
		,212,231,221,199
		,213,231,221,200
		,214,231,221,202
		,215,231,222,202
		,216,232,222,204
		,217,232,223,205
		,218,232,223,207
		,219,232,223,208
		,220,233,223,210
		,221,233,223,210
		,222,233,223,212
		,223,233,224,213
		,224,233,224,215
		,225,234,224,216
		,226,234,225,217
		,227,234,225,218
		,228,234,225,220
		,229,234,226,221
		,230,234,226,223
		,231,234,226,224
		,232,235,227,225
		,233,235,227,227
		,234,235,227,228
		,235,235,227,229
		,236,235,228,231
		,237,235,228,232
		,238,235,228,234
		,239,235,228,235
		,240,235,229,236
		,241,235,229,238
		,242,235,229,239
		,243,235,229,241
		,244,235,229,242
		,245,235,229,243
		,246,235,229,245
		,247,235,229,246
		,248,235,229,247
		,249,235,230,249
		,250,236,230,251
		,251,236,230,252
		,252,236,230,253
		,253,236,231,255
		,254,236,231,255
		,255,236,231,255
		,
	};
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			//int alpha = (unsigned char)imgPixel[pixOff];
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			int bw = (int)((red+green+blue)/3.0);
			red =a[4*bw +1];
			green = a[4*bw+2];
			blue = a[4*bw+3];
			imgPixel[pixOff] = red;
			imgPixel[pixOff+1] = green;
			imgPixel[pixOff+2] = blue;
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, NULL, NO, renderingIntent);
	
	UIImage *my_Image = [[UIImage imageWithCGImage:imageRef] retain];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return [my_Image autorelease];
	//return [self history:[self blackWhite:inImage]];
}

@end
