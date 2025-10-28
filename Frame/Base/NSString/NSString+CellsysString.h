//
//  NSString+CellsysString.h
//  Frame
//
//  Created by 冯汉栩 on 2025/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (CellsysString)

/// 是否为空或者是空格
+ (BOOL)isEmptyString:(NSString *)string;

// NSData转16进制 第一种
+ (NSString *)convertDataToHexStr:(NSData *)data;

+ (NSString *)stringToMD5:(NSString *)str;
@end

NS_ASSUME_NONNULL_END
