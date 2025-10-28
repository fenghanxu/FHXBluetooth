//
//  CellsysBLEMsgBodyList.h
//  Frame
//
//  Created by 冯汉栩 on 2025/10/10.
//

#import <Foundation/Foundation.h>
#import "CellsysBLEMsgBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface CellsysBLEMsgBodyList : CSArchiveBaseModel

Single_interface(CellsysBLEMsgBodyList)

@property (nonatomic, strong) NSMutableArray<CellsysBLEMsgBody *> *list;

// 归档方法
- (BOOL)archiveToFile;

// 解档方法
+ (nullable CellsysBLEMsgBodyList *)unarchiveFromFile;

// 获取归档文件路径
+ (NSString *)archiveFilePath;




// 添加消息（自动去重）
+ (BOOL)addBLEMsgBody:(CellsysBLEMsgBody *)messageBody;

// 删除指定msgID的消息
+ (BOOL)removeBLEMsgBodyWithID:(NSString *)contentId;

// 获取所有消息列表
+ (NSArray<CellsysBLEMsgBody *> *)getAllBLEMsgBody;

// 根据msgID查找消息
+ (CellsysBLEMsgBody *)getBLEMsgBodyWithID:(NSString *)contentId;

// 清空所有消息
+ (BOOL)clearAllBLEMsgBody;

// 获取消息数量
+ (NSInteger)getBLEMsgBodyCount;

// 检查消息是否存在
+ (BOOL)containsBLEMsgBodyWithID:(NSString *)contentId;

@end

NS_ASSUME_NONNULL_END
