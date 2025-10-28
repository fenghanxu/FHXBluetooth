//
//  CellsysBLEMsgBodyList.m
//  Frame
//
//  Created by 冯汉栩 on 2025/10/10.
//

#import "CellsysBLEMsgBodyList.h"

@implementation CellsysBLEMsgBodyList

Single_implementation(CellsysBLEMsgBodyList)

- (NSMutableArray<CellsysBLEMsgBody *> *)list {
    if (_list == nil) {
        _list = [NSMutableArray<CellsysBLEMsgBody *> new];
    }
    return _list;
}

// 归档方法
- (BOOL)archiveToFile {
    NSString *filePath = [[self class] archiveFilePath];
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

// 解档方法
+ (nullable CellsysBLEMsgBodyList *)unarchiveFromFile {
    NSString *filePath = [self archiveFilePath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

// 获取归档文件路径
+ (NSString *)archiveFilePath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/CellsysBLEMsgBodyList.archive"];
}



#pragma mark - 消息管理方法
// 添加消息（自动去重）
+ (BOOL)addBLEMsgBody:(CellsysBLEMsgBody *)messageBody {
    if (!messageBody || !messageBody.contentId) {
        NSLog(@"消息体或msgID为空");
        return NO;
    }
    
    CellsysBLEMsgBodyList *model = [self unarchiveFromFile];
    if (!model) {
        model = [CellsysBLEMsgBodyList sharedInstance];
    }
    
    // 检查是否已存在
    if ([self containsBLEMsgBodyWithID:messageBody.contentId inModel:model]) {
        NSLog(@"消息已存在，msgID: %@", messageBody.contentId);
        return NO;
    }
    
    // 添加消息
    [model.list addObject:messageBody];
    BOOL success = [model archiveToFile];
    
    if (success) {
        NSLog(@"消息添加成功，msgID: %@", messageBody.contentId);
    } else {
        NSLog(@"消息添加失败，msgID: %@", messageBody.contentId);
    }
    
    return success;
}

// 删除指定msgID的消息
+ (BOOL)removeBLEMsgBodyWithID:(NSString *)contentId {
    if (!contentId) {
        NSLog(@"msgID为空");
        return NO;
    }
    
    CellsysBLEMsgBodyList *model = [self unarchiveFromFile];
    if (!model || model.list.count == 0) {
        NSLog(@"消息列表为空，无需删除");
        return YES;
    }
    
    BOOL removed = NO;
    CellsysBLEMsgBody *messageToRemove = nil;
    
    // 查找要删除的消息
    for (CellsysBLEMsgBody *message in model.list) {
        if ([message.contentId isEqualToString:contentId]) {
            messageToRemove = message;
            break;
        }
    }
    
    // 删除消息
    if (messageToRemove) {
        [model.list removeObject:messageToRemove];
        removed = [model archiveToFile];
        
        if (removed) {
            NSLog(@"内容删除成功，contentId: %@", contentId);
        } else {
            NSLog(@"内容删除失败，contentId: %@", contentId);
        }
    } else {
        NSLog(@"未找到要删除的内容，contentId: %@", contentId);
    }
    
    return removed;
}

// 获取所有消息列表
+ (NSArray<CellsysBLEMsgBody *> *)getAllBLEMsgBody {
    CellsysBLEMsgBodyList *model = [self unarchiveFromFile];
    if (!model) {
        return @[];
    }
    return [model.list copy]; // 返回不可变副本
}

// 根据contentId查找消息
+ (CellsysBLEMsgBody *)getBLEMsgBodyWithID:(NSString *)contentId {
    if (!contentId) {
        return nil;
    }
    
    CellsysBLEMsgBodyList *model = [self unarchiveFromFile];
    if (!model || model.list.count == 0) {
        return nil;
    }
    
    for (CellsysBLEMsgBody *message in model.list) {
        if ([message.contentId isEqualToString:contentId]) {
            return message;
        }
    }
    
    return nil;
}

// 清空所有消息
+ (BOOL)clearAllBLEMsgBody {
    CellsysBLEMsgBodyList *model = [self sharedInstance];
    [model.list removeAllObjects];
    
    BOOL success = [model archiveToFile];
    if (success) {
        NSLog(@"所有消息已清空");
    } else {
        NSLog(@"清空消息失败");
    }
    
    return success;
}

// 获取消息数量
+ (NSInteger)getBLEMsgBodyCount {
    CellsysBLEMsgBodyList *model = [self unarchiveFromFile];
    if (!model) {
        return 0;
    }
    return model.list.count;
}

// 检查消息是否存在
+ (BOOL)containsBLEMsgBodyWithID:(NSString *)contentId {
    if (!contentId) {
        return NO;
    }
    
    CellsysBLEMsgBodyList *model = [self unarchiveFromFile];
    return [self containsBLEMsgBodyWithID:contentId inModel:model];
}

#pragma mark - Private Methods

// 内部使用的检查方法
+ (BOOL)containsBLEMsgBodyWithID:(NSString *)contentId inModel:(CellsysBLEMsgBodyList *)model {
    if (!model || !contentId || model.list.count == 0) {
        return NO;
    }
    
    for (CellsysBLEMsgBody *message in model.list) {
        if ([message.contentId isEqualToString:contentId]) {
            return YES;
        }
    }
    
    return NO;
}

@end
