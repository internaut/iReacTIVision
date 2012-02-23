//
//  Singleton.h
//  orbitio
//
//  Created by Markus Konrad on 09.04.11.
//  Copyright 2011 Hello IT GbR. All rights reserved.
//

#import <Foundation/Foundation.h>

// Declares a standard singleton interface
@protocol Singleton <NSObject>

// "shared" method. Each singleton gives access to its object with this method.
+ (id)shared;

// will destroy the Singleton object
- (void)destroy;

@end
