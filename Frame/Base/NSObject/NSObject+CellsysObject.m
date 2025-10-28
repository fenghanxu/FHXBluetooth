//
//  NSObject+CellsysObject.m
//  Frame
//
//  Created by 冯汉栩 on 2025/9/22.
//

#import "NSObject+CellsysObject.h"

@implementation NSObject (CellsysObject)

+ (BOOL)isEmpty:(id)object{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        return [object isEqualToString:@""];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [object isEqualToNumber:@(0)];
    }
    return NO;
}


@end
