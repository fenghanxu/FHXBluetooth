//
//  MessageBodyListModel.m
//  Frame
//
//  Created by 冯汉栩 on 2025/9/23.
//

#import "MessageBodyListModel.h"

@implementation MessageBodyListModel

Single_implementation(MessageBodyListModel)

- (NSMutableArray<CellsysMessageBody *> *)list {
    if (_list == nil) {
        _list = [NSMutableArray<CellsysMessageBody *> new];
    }
    return _list;
}

// 归档方法
- (BOOL)archiveToFile {
    NSString *filePath = [[self class] archiveFilePath];
    return [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

// 解档方法
+ (nullable MessageBodyListModel *)unarchiveFromFile {
    NSString *filePath = [self archiveFilePath];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

// 获取归档文件路径
+ (NSString *)archiveFilePath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MessageBodyListModel.archive"];
}






#pragma mark - 消息管理方法

// 添加消息（自动去重）
+ (BOOL)addMessage:(CellsysMessageBody *)messageBody {
    if (!messageBody || !messageBody.msgID) {
        NSLog(@"消息体或msgID为空");
        return NO;
    }
    
    MessageBodyListModel *model = [self unarchiveFromFile];
    if (!model) {
        model = [MessageBodyListModel sharedInstance];
    }
    
    // 检查是否已存在
    if ([self containsMessageWithID:messageBody.msgID inModel:model]) {
        NSLog(@"消息已存在，msgID: %@", messageBody.msgID);
        return NO;
    }
    
    // 添加消息
    [model.list addObject:messageBody];
    BOOL success = [model archiveToFile];
    
    if (success) {
        NSLog(@"消息添加成功，msgID: %@", messageBody.msgID);
    } else {
        NSLog(@"消息添加失败，msgID: %@", messageBody.msgID);
    }
    
    return success;
}

// 删除指定msgID的消息
+ (BOOL)removeMessageWithID:(NSString *)msgID {
    if (!msgID) {
        NSLog(@"msgID为空");
        return NO;
    }
    
    MessageBodyListModel *model = [self unarchiveFromFile];
    if (!model || model.list.count == 0) {
        NSLog(@"消息列表为空，无需删除");
        return YES;
    }
    
    BOOL removed = NO;
    CellsysMessageBody *messageToRemove = nil;
    
    // 查找要删除的消息
    for (CellsysMessageBody *message in model.list) {
        if ([message.msgID isEqualToString:msgID]) {
            messageToRemove = message;
            break;
        }
    }
    
    // 删除消息
    if (messageToRemove) {
        [model.list removeObject:messageToRemove];
        removed = [model archiveToFile];
        
        if (removed) {
            NSLog(@"消息删除成功，msgID: %@", msgID);
        } else {
            NSLog(@"消息删除失败，msgID: %@", msgID);
        }
    } else {
        NSLog(@"未找到要删除的消息，msgID: %@", msgID);
    }
    
    return removed;
}

// 获取所有消息列表
+ (NSArray<CellsysMessageBody *> *)getAllMessages {
    MessageBodyListModel *model = [self unarchiveFromFile];
    if (!model) {
        return @[];
    }
    return [model.list copy]; // 返回不可变副本
}

// 根据msgID查找消息
+ (CellsysMessageBody *)getMessageWithID:(NSString *)msgID {
    if (!msgID) {
        return nil;
    }
    
    MessageBodyListModel *model = [self unarchiveFromFile];
    if (!model || model.list.count == 0) {
        return nil;
    }
    
    for (CellsysMessageBody *message in model.list) {
        if ([message.msgID isEqualToString:msgID]) {
            return message;
        }
    }
    
    return nil;
}

// 清空所有消息
+ (BOOL)clearAllMessages {
    MessageBodyListModel *model = [self sharedInstance];
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
+ (NSInteger)getMessageCount {
    MessageBodyListModel *model = [self unarchiveFromFile];
    if (!model) {
        return 0;
    }
    return model.list.count;
}

// 检查消息是否存在
+ (BOOL)containsMessageWithID:(NSString *)msgID {
    if (!msgID) {
        return NO;
    }
    
    MessageBodyListModel *model = [self unarchiveFromFile];
    return [self containsMessageWithID:msgID inModel:model];
}

#pragma mark - Private Methods

// 内部使用的检查方法
+ (BOOL)containsMessageWithID:(NSString *)msgID inModel:(MessageBodyListModel *)model {
    if (!model || !msgID || model.list.count == 0) {
        return NO;
    }
    
    for (CellsysMessageBody *message in model.list) {
        if ([message.msgID isEqualToString:msgID]) {
            return YES;
        }
    }
    
    return NO;
}
@end
