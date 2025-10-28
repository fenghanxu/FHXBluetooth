//
//  MessageBodyListModel.h
//  Frame
//
//  Created by 冯汉栩 on 2025/9/23.
//

#import <Foundation/Foundation.h>
#import "CellsysMessageBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageBodyListModel : CSArchiveBaseModel

Single_interface(MessageBodyListModel)

@property (nonatomic, strong) NSMutableArray<CellsysMessageBody *> *list;
// 归档方法
- (BOOL)archiveToFile;

// 解档方法
+ (nullable MessageBodyListModel *)unarchiveFromFile;

// 获取归档文件路径
+ (NSString *)archiveFilePath;




// 添加消息（自动去重）
+ (BOOL)addMessage:(CellsysMessageBody *)messageBody;

// 删除指定msgID的消息
+ (BOOL)removeMessageWithID:(NSString *)msgID;

// 获取所有消息列表
+ (NSArray<CellsysMessageBody *> *)getAllMessages;

// 根据msgID查找消息
+ (CellsysMessageBody *)getMessageWithID:(NSString *)msgID;

// 清空所有消息
+ (BOOL)clearAllMessages;

// 获取消息数量
+ (NSInteger)getMessageCount;

// 检查消息是否存在
+ (BOOL)containsMessageWithID:(NSString *)msgID;

@end

NS_ASSUME_NONNULL_END
