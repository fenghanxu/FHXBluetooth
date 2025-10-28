//
//  CellsysUserNotifications.m
//  cellsys
//
//  Created by 刘磊 on 2020/6/23.
//  Copyright © 2020 LarryLiu. All rights reserved.
//

#import "CellsysUserNotifications.h"
#import <UserNotifications/UserNotifications.h>

@interface CellsysUserNotifications () <AVSpeechSynthesizerDelegate>

/** 播报的内容 */
@property (nonatomic, readwrite , strong) AVSpeechSynthesizer *synth;
/** 负责播放 */
@property (nonatomic, readwrite , strong) AVSpeechUtterance *utterance;


@end

@implementation CellsysUserNotifications

// 静态单例对象
static CellsysUserNotifications *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[super allocWithZone:NULL] init];
    });
    return _sharedInstance;
}

/**
添加本地推送通知
 @param title 标题
 @param subTitle  子标题
 @param body 推送的内容
 @param timeInterval 发出推送的日期，多少秒后发送,1秒以上
 @param identifier 添加通知的标识符，可以用于移除，更新等操作
 @param userInfo  通知参数
 @param repeats 循环方式
 */
+ (void)addLocalNotificationWithTitle:(NSString *)title subTitle:(NSString *)subTitle body:(NSString *)body timeInterval:(long)timeInterval identifier:(NSString *)identifier userInfo:(NSDictionary * _Nullable )userInfo repeats:(int)repeats sound:(BOOL)isSound
{
//    if (title.length == 0 || body.length == 0 || identifier.length == 0) {
//        return;
//    }
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        // 标题
        if (title.length) {
            content.title = title;
        }
        if (subTitle.length) {
            content.subtitle = subTitle;
        }
        // 内容
        if (body.length) {
            content.body = body;
        }
        if (userInfo != nil) {
            content.userInfo = userInfo;
        }
        // 声音
        // 默认声音
        if (isSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        // 添加自定义声音
        //content.sound = [UNNotificationSound soundNamed:@"Alert_ActivityGoalAttained_Salient_Haptic.caf"];
        // 角标 （我这里测试的角标无效，暂时没找到原因）
        //content.badge = @1;
        // 多少秒后发送,可以将固定的日期转化为时间
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:timeInterval] timeIntervalSinceNow];
        UNNotificationTrigger *trigger = nil;
        // repeats，是否重复，如果重复的话时间必须大于60s，要不会报错
        if (repeats > 0 && repeats < 7) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
            // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
            unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitWeekday | NSCalendarUnitMinute | NSCalendarUnitSecond;
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            // 获取不同时间字段的信息
            NSDateComponents* comp = [gregorian components:unitFlags fromDate:date];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.second = comp.second;
            if (repeats == 6) {
                //每分钟循环
            } else if (repeats == 5) {
                //每小时循环
                components.minute = comp.minute;
            } else if (repeats == 4) {
                //每天循环
                components.minute = comp.minute;
                components.hour = comp.hour;
            } else if (repeats == 3) {
                //每周循环
                components.minute = comp.minute;
                components.hour = comp.hour;
                components.weekday = comp.weekday;
            } else if (repeats == 2) {
                //每月循环
                components.minute = comp.minute;
                components.hour = comp.hour;
                components.day = comp.day;
                components.month = comp.month;
            } else if (repeats == 1) {
                //每年循环
                components.minute = comp.minute;
                components.hour = comp.hour;
                components.day = comp.day;
                components.month = comp.month;
                components.year = comp.year;
            }
            trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
        } else {
            //不循环
            trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        }
        // 添加通知的标识符，可以用于移除，更新等操作 identifier
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"Cellsys-PushSDK log:添加本地推送成功");
        }];
    } else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        // 发出推送的日期
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
        if (title.length > 0) {
            notif.alertTitle = title;
        }
        // 推送的内容
        if (body.length > 0) {
            notif.alertBody = body;
        }
        if (userInfo != nil) {
            NSMutableDictionary *mdict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            [mdict setObject:identifier forKey:@"identifier"];
            notif.userInfo = mdict;
        } else {
            // 可以添加特定信息
            notif.userInfo = @{@"identifier":identifier};
        }
        // 角标
        notif.applicationIconBadgeNumber = 0;
        // 提示音
        if (isSound) {
            notif.soundName = UILocalNotificationDefaultSoundName;
        }
        
        // 循环提醒
        if (repeats == 6) {
            //每分钟循环
            notif.repeatInterval = NSCalendarUnitMinute;
        } else if (repeats == 5) {
            //每小时循环
            notif.repeatInterval = NSCalendarUnitHour;
        } else if (repeats == 4) {
            //每天循环
            notif.repeatInterval = NSCalendarUnitDay;
        } else if (repeats == 3) {
            //每周循环
            notif.repeatInterval = NSCalendarUnitWeekday;
        } else if (repeats == 2) {
            //每月循环
            notif.repeatInterval = NSCalendarUnitMonth;
        } else if (repeats == 1) {
            //每年循环
            notif.repeatInterval = NSCalendarUnitYear;
        } else {
            //不循环
        }
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
    
    
}



/** 移除某一个指定的通知*/
+ (void)removeNotificationWithIdentifierID:(NSString *)noticeId
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
            for (UNNotificationRequest *req in requests){
                NSLog(@"Cellsys-PushSDK log: 当前存在的本地通知identifier: %@\n", req.identifier);
            }
        }];
        [center removePendingNotificationRequestsWithIdentifiers:@[noticeId]];
    } else {
        NSArray *array = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *localNotification in array){
            NSDictionary *userInfo = localNotification.userInfo;
            NSString *obj = [userInfo objectForKey:@"identifier"];
            if ([obj isEqualToString:noticeId]) {
                [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            }
        }
    }
}

/** 移除所有通知*/
+ (void)removeAllNotification
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }else {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

#pragma mark - AVSpeechSynthesizer
- (AVSpeechSynthesizer *)synth{
    if (_synth == nil) {
        _synth = [[AVSpeechSynthesizer alloc] init];
        _synth.delegate = self;
    }
    return _synth;
}

- (AVSpeechUtterance *)utterance{
    if (_utterance == nil) {
        
        //NSString *str = @"支付宝 到账 100万 元";
        //self.utterance = [AVSpeechUtterance speechUtteranceWithString:str];//成功集成语音播报
        
        _utterance = [[AVSpeechUtterance alloc] init];
        //pitchMultiplier: 音高
        //
        //postUtteranceDelay: 读完一段后的停顿时间
        //
        //preUtteranceDelay: 读一段话之前的停顿
        //rate: 读地速度, 系统提供了三个速度: AVSpeechUtteranceMinimumSpeechRate, AVSpeechUtteranceMaximumSpeechRate, AVSpeechUtteranceDefaultSpeechRate
        _utterance.rate = AVSpeechUtteranceDefaultSpeechRate;// 播报的语速

        //    中式发音
        AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
        //英式发音
        //    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-GB"];
        _utterance.voice = voice;
    }
    return _utterance;
}

- (void)speechAudioMessage:(NSString *)str{
    
    
    
    if (self.synth.speaking == YES) {
        //NSLog(@"speaking111---speechString:%@,str:%@",self.utterance.speechString,str);
        [self.synth stopSpeakingAtBoundary:nil];
        
        //增加每句语音间隔
        str = [NSString stringWithFormat:@"   %@",str];
        
        str = [self.utterance.speechString stringByAppendingString:str];
        
        self.utterance = [AVSpeechUtterance speechUtteranceWithString:str];//成功集成语音播报
        
        [self.synth speakUtterance:self.utterance];
        
        //NSLog(@"speaking222---speechString:%@,str:%@",self.utterance.speechString,str);
        
    }else{
        //NSLog(@"NO speaking---speechString:%@,str:%@",self.utterance.speechString,str);
        
        self.utterance = [AVSpeechUtterance speechUtteranceWithString:str];//成功集成语音播报
        [self.synth speakUtterance:self.utterance];
        
    }
    
    
    
}


#pragma mark - AVSpeechSynthesizerDelegate

//已经开始
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //NSLog(@"speaking已经开始%@%@",synthesizer,utterance);
}
//已经说完
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //NSLog(@"speaking已经说完%@%@",synthesizer,utterance);
}
//已经暂停
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //NSLog(@"speaking已经暂停%@%@",synthesizer,utterance);
}
//已经继续说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //NSLog(@"speaking已经继续说话%@%@",synthesizer,utterance);
}
//已经取消说话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //NSLog(@"speaking已经取消说话%@%@",synthesizer,utterance);
}
//将要说某段话
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance API_AVAILABLE(ios(7.0), watchos(1.0), tvos(7.0), macos(10.14)) {
    //NSLog(@"speaking将要说某段话%@,%lu,%lu,%@",synthesizer,(unsigned long)characterRange.length,(unsigned long)characterRange.location,utterance);
}


@end
