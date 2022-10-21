//
//  HelloWorld.m
//  
//
//  Created by Jinwoo Kim on 10/22/22.
//

#import "HelloWorld.h"

@implementation HelloWorld

@end

@interface NSObject (LoadTest)

@end

@implementation NSObject (LoadTest)

+ (void)load {
    NSLog(@"Load!!!");
}

@end
