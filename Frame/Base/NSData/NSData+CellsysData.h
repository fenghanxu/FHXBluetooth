//
//  NSData+CellsysData.h
//  Frame
//
//  Created by 冯汉栩 on 2025/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (CellsysData)

// 16进制字符串转换为data类型
+ (NSMutableData *)convertHexStrToData:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
