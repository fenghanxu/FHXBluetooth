//
//  NSDate+CellsysDate.h
//  Frame
//
//  Created by 冯汉栩 on 2025/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (CellsysDate)

// 获取当前时间戳 精确到秒(10位)
+ (NSString *)getCurrentTimestamp10;

// 获取当前时间戳 精确到毫秒(13位)
+ (NSString *)getCurrentTimestamp13;

//小数点前是秒为单位
+ (NSString *)stringDateYMDHMSFromNSTimeInterval:(NSTimeInterval)secs;

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;

+ (NSString *)stringDateFromTimestamp:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
