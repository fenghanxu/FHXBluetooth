//
//  CellsysUserNotifications.h
//  cellsys
//
//  Created by 刘磊 on 2020/6/23.
//  Copyright © 2020 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellsysUserNotifications : NSObject

+ (instancetype)sharedInstance;

/** 添加本地推送通知*/
+ (void)addLocalNotificationWithTitle:(NSString *)title subTitle:(NSString *)subTitle body:(NSString *)body timeInterval:(long)timeInterval identifier:(NSString *)identifier userInfo:(NSDictionary * _Nullable)userInfo repeats:(int)repeats sound:(BOOL)isSound;

/** 移除某一个指定的通知*/
+ (void)removeNotificationWithIdentifierID:(NSString *)noticeId;

/** 移除所有通知*/
+ (void)removeAllNotification;

- (void)speechAudioMessage:(NSString *)str;


@end

NS_ASSUME_NONNULL_END
