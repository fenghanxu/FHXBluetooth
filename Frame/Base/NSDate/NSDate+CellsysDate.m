//
//  NSDate+CellsysDate.m
//  Frame
//
//  Created by 冯汉栩 on 2025/9/22.
//

#import "NSDate+CellsysDate.h"

@implementation NSDate (CellsysDate)

// 获取当前时间戳 精确到秒(10位)
+ (NSString *)getCurrentTimestamp10{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970];// 精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%ld",(long)time];
    return timeString;
}

// 获取当前时间戳 精确到毫秒(13位)
+ (NSString *)getCurrentTimestamp13{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
    NSString *timeString = [NSString stringWithFormat:@"%ld",(long)time];
    return timeString;
}

//小数点前是秒为单位
+ (NSString *)stringDateYMDHMSFromNSTimeInterval:(NSTimeInterval)secs{
    
    
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:secs];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    
    return currentDateStr;
}

//将UTC日期字符串转为本地时间字符串
//输入的UTC日期格式2013-08-03T04:53:51+0000
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    if ([utcDate containsString:@"."]) {
        [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss.SSSSSS"];
    }else{
        [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss"];
    }
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    //输出格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

+ (NSString *)stringDateFromTimestamp:(NSString *)string{
    
    //NSLog(@"%@",dataStr);
    //NSString*str=@"1368082020";//时间戳
    NSTimeInterval time= [string longLongValue];
    if (string.length > 10) {
        time = string.longLongValue/1000;
    }
    NSDate *detaildate = [NSDate dateWithTimeIntervalSince1970:time];
    
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
    
    return currentDateStr;
}

@end
