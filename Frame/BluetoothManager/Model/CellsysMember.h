//
//  CellsysMember.h
//  cellsys
//
//  Created by LarryLiu on 2019/10/24.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CellsysGeometry.h"

NS_ASSUME_NONNULL_BEGIN

//宏定义 block 
typedef void(^CallBack)(id  _Nullable success, NSError * _Nullable  fail);

typedef NS_ENUM(NSInteger, locusType) {
    NewLocus = 1,
    HistoryLocus = 2,
};

@class CellsysStyle;
@class CellsysGeometry;

@interface CellsysMember : CSArchiveBaseModel

/**成员ID*/
@property (nonatomic, copy) NSString *user_id;

///***/
//@property (nonatomic, copy) NSString *member_id;

/**创建时间*/
@property (nonatomic, copy) NSString *create_time;

/**更新时间*/
@property (nonatomic, copy) NSString *update_time;


/**备注*/
@property (nonatomic, copy) NSString *remark;

/**标签*/
@property (nonatomic, copy) NSString *mark;


/**设备macid*/
@property (nonatomic, copy) NSString *macid;

/**成员状态，在线，离线*/
@property (nonatomic, copy) NSString *memberStatus;

/**手机号码*/
@property (nonatomic, copy) NSString *mobile;

/**真实姓名*/
@property (nonatomic, copy) NSString *realname;

/**成员位置信息*/
@property (nonatomic, copy) NSDictionary *geometry;

/**微信头像链接*/
@property (nonatomic, copy) NSString *avatar;


#pragma mark --- chat暂未用到的字段
//
///***/
//@property (nonatomic, copy) NSString *group_status;
//
///***/
//@property (nonatomic, copy) NSString *group_description;
//
///**用来区别，实时轨迹newLocal、历史轨迹historyLocal*/
//@property (nonatomic, copy) NSNumber *locusType;


//
///***/
//@property (nonatomic, strong) NSDictionary *style;
//
///***/
//@property (nonatomic, copy) NSString *org_id;
//

//
///***/
//@property (nonatomic, copy) NSString *group_id;
//
///***/
//@property (nonatomic, copy) NSString *is_leader;
//
///***/
//@property (nonatomic, copy) NSString *type_name;
//
///***/
//@property (nonatomic, copy) NSString *group_name;
//
///***/
//@property (nonatomic, copy) NSString *member_type;
//
//
///**本地字段，用来在APP界面展示*/
//@property (nonatomic, copy) NSString *showTime;

//
//- (CellsysStyle *)toCellsysStyle;

- (CellsysGeometry *)toCellsysGeometry;

///**
//* 查询用户位置基础列表
//*/
//- (void)queryUserLocalBasicWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户位置列表
//*/
//- (void)queryUserLocalWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户定位时间轴列表
//*/
//- (void)queryUserLocalTimeWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
//
//
///**
//* 查询用户5分钟内的定位列表
//*/
//- (void)queryUserEventFiveMinuteWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户15分钟内的定位列表
//*/
//- (void)queryUserEventFifteenMinuteWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户30分钟内的定位列表
//*/
//- (void)queryUserEventThirtyMinuteWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户1小时内的定位列表
//*/
//- (void)queryUserEventOneHourWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户2小时内的定位列表
//*/
//- (void)queryUserEventTwoHourWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户4小时内的定位列表
//*/
//- (void)queryUserEventFourHourWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户今天的定位列表
//*/
//- (void)queryUserEventTodayWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户昨天的定位列表
//*/
//- (void)queryUserEventYesterdayWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;
//
///**
//* 查询用户前天的定位列表
//*/
//- (void)queryUserEventAnteayerWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack;


+ (CellsysMember *)initWithCellMember;

@end

NS_ASSUME_NONNULL_END
