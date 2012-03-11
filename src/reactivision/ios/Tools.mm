//
//  Tools.m
//  LibraryAgent
//
//  Created by Markus Konrad on 01.11.11.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import "Tools.h"

@implementation Tools

static int imageSaveCount = 0;

+(UIImage *)imageFromBuffer:(void *)buffer width:(int)w height:(int)h channels:(int)channels {
    NSAssert(channels > 0 && channels < 5, @"Invalid number of channels");

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL,buffer,w * h * channels,NULL);
     
    int bitsPerComponent = 8;
    int bitsPerPixel = channels * bitsPerComponent;
    int bytesPerRow = channels * w;
    
    CGColorSpaceRef colorSpaceRef;
    
    if (channels == 1) {
        colorSpaceRef = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;

    CGImageRef imageRef = CGImageCreate(w,h,bitsPerComponent,bitsPerPixel,bytesPerRow,colorSpaceRef,bitmapInfo,provider,NULL,NO,renderingIntent);

    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    return newImage;
}

+(void *)bufferFromImage:(UIImage *)image width:(int *)w height:(int *)h channels:(int *)channels {
    CGImageRef imageRef = [image CGImage];
    *w = CGImageGetWidth(imageRef);
    *h = CGImageGetHeight(imageRef);
    *channels = CGImageGetBytesPerRow(imageRef) / *w;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)malloc((*w) * (*h) * 4);
    NSUInteger bytesPerPixel = *channels;
    NSUInteger bytesPerRow = bytesPerPixel * (*w);
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, *w, *h,
                    bitsPerComponent, bytesPerRow, colorSpace,
                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, *w, *h), imageRef);
    CGContextRelease(context);
    
    return rawData;
}

+ (void)saveBuffer:(void *)buffer width:(int)w height:(int)h channels:(int)c maxCount:(int)maxCount {
    [Tools saveImage:[Tools imageFromBuffer:buffer width:w height:h channels:c] maxCount:maxCount];
}

+ (void)saveImage:(UIImage *)img maxCount:(int)maxCount {
    if (maxCount > 0 && imageSaveCount >= maxCount) return;

    NSString *imgFile = [NSString stringWithFormat:@"%@/frame-%d.png", [Tools applicationStorage], imageSaveCount];

    NSData *imgData = UIImagePNGRepresentation(img);
    
    if (imgData) {
        NSLog(@"writing frame %d to file %@ with size %f x %f", imageSaveCount, imgFile, img.size.width, img.size.height);
    } else {
        NSLog(@"Invalid image data for frame %d", imageSaveCount);
    }
    
    if (![imgData writeToFile:imgFile atomically:YES]) {
        NSLog(@"Could not write frame %d to file %@", imageSaveCount, imgFile);
    }
    
    imageSaveCount++;
}

+ (NSString *)applicationStorage {
	NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *path = [docPaths objectAtIndex: 0];
	
	return path;
}

+ (NSString *)bundleStorage {
    return [[NSBundle mainBundle] resourcePath];    
}

+ (NSString *)bundleStorageFile:(NSString *)file {
    return [[Tools bundleStorage] stringByAppendingPathComponent:file];
}

@end
