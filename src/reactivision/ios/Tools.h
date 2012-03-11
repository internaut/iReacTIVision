//
//  Tools.h
//  LibraryAgent
//
//  Created by Markus Konrad on 01.11.11.
//  Copyright (c) 2012 Markus Konrad <post@mkonrad.net>. Licensed under GPL.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tools : NSObject

// create an autoreleased UIImage from an interleaved byte-buffer
+(UIImage *)imageFromBuffer:(void *)buffer width:(int)w height:(int)h channels:(int)channels;

// create an interleaved byte-buffer from an UIImage, save the dimensions into the provided int-pointers
+(void *)bufferFromImage:(UIImage *)image width:(int *)w height:(int *)h channels:(int *)channels;

// save an UIImage into the document storage
+ (void)saveImage:(UIImage *)img maxCount:(int)maxCount;

// save an interleaved buffer into the document storage
+ (void)saveBuffer:(void *)buffer width:(int)w height:(int)h channels:(int)c maxCount:(int)maxCount;

// get the path to the application storage (document-store)
+ (NSString *)applicationStorage;

// get the path to the bundle storage of the app
+ (NSString *)bundleStorage;

// get the path to the file inside the bundle storage of the app
+ (NSString *)bundleStorageFile:(NSString *)file;


@end
