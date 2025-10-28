//
//  CellsysMember.m
//  cellsys
//
//  Created by LarryLiu on 2019/10/24.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import "CellsysMember.h"

@implementation CellsysMember

+ (CellsysMember *)initWithCellMember{
    CellsysMember *member = [[CellsysMember alloc] init];
    member.user_id = [NSDate getCurrentTimestamp13] ;
    member.create_time = [NSDate getCurrentTimestamp13];
    member.update_time = [NSDate getCurrentTimestamp13];    
    return member;
}

- (NSString *)remark{
    if ([NSObject isEmpty:_remark]) {
        return self.realname;
    }
    return _remark;
}

- (NSString *)mark{
    if (![NSObject isEmpty:_mark]) {
        return _mark;
    }
    if (![NSObject isEmpty:_realname]) {
        return _realname;
    }
    if (![NSObject isEmpty:_macid]) {
        return _macid;
    }

    return nil;
    
}

- (NSString *)realname{
    if ([NSObject isEmpty:_realname]) {
        return _macid;
    }
    return _realname;
}


//- (NSDictionary *)style{
//    return _style.mj_JSONObject;
//}

- (NSDictionary *)geometry{
    return _geometry.mj_JSONObject;
}


//- (CellsysStyle *)toCellsysStyle{
//    CellsysStyle *style = [CellsysStyle mj_objectWithKeyValues:self.style];
//    return style;
//}


- (CellsysGeometry *)toCellsysGeometry{
    CellsysGeometry *geometry = [CellsysGeometry mj_objectWithKeyValues:self.geometry];
    return geometry;
}

///**
//* 查询用户位置基础列表
//*/
//- (void)queryUserLocalBasicWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserLocalBasic];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户位置列表
//*/
//- (void)queryUserLocalWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//    [query.filter addObject:[Query addFilter:@"group_id" operato:[Operator sharedOperator].Equals qValue:self.group_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserLocal];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
//
///**
//* 查询用户定位时间轴列表
//*/
//- (void)queryUserLocalTimeWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserLocalTime];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
//
///**
//* 查询用户5分钟内的定位列表
//*/
//- (void)queryUserEventFiveMinuteWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventFiveMinute];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户15分钟内的定位列表
//*/
//- (void)queryUserEventFifteenMinuteWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventFifteenMinute];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户30分钟内的定位列表
//*/
//- (void)queryUserEventThirtyMinuteWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventThirtyMinute];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户1小时内的定位列表
//*/
//- (void)queryUserEventOneHourWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventOneHour];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户2小时内的定位列表
//*/
//- (void)queryUserEventTwoHourWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventTwoHour];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户4小时内的定位列表
//*/
//- (void)queryUserEventFourHourWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventFourHour];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户今天的定位列表
//*/
//- (void)queryUserEventTodayWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventToday];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户昨天的定位列表
//*/
//- (void)queryUserEventYesterdayWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventYesterday];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//
///**
//* 查询用户前天的定位列表
//*/
//- (void)queryUserEventAnteayerWithQuery:(Query *_Nullable)queryObj CallBack:(CallBack)callBack{
//    Query *query = [[Query alloc] init];
//    if (queryObj) {
//        query = queryObj;
//    }
//    [query.filter addObject:[Query addFilter:@"user_id" operato:[Operator sharedOperator].Equals qValue:self.user_id]];
//
//    NSString *url = [NSString stringWithFormat:@"%@%@", API_URL,[QueryType sharedQueryType].UserEventAnteayer];
//
//    Param *param = [[Param alloc] init];
//    param.body = query.mj_keyValues;
//
//
//    [[QueryTask sharedQueryTask] queryTask:url parameters:param.mj_keyValues CallBack:^(id  _Nullable success, NSError * _Nullable fail) {
//        callBack(success,fail);
//    }];
//}
//






@end
