//
//  CellsysMsgStatus.h
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import "CellsysMessageBody.h"

NS_ASSUME_NONNULL_BEGIN

@class CellsysMessageBody;

@interface CellsysMsgStatus : NSObject

//isReply 回复
@property (nonatomic, assign) NSInteger isReply;

//isExpired 过期
@property (nonatomic, assign) NSInteger isExpired;

//isWarehousing入库（上云服务器）
@property (nonatomic, assign) NSInteger isWarehousing;

//isTransmit 转发、传输
@property (nonatomic, assign) NSInteger isTransmit;

//isUploadMQTT上传MQTT
@property (nonatomic, assign) NSInteger isUploadMQTT;

//isRetransmissio重传
@property (nonatomic, assign) NSInteger isRetransmissio;

//isCacheProcessingPool （塞入消息缓存处理池）
@property (nonatomic, assign) NSInteger isCacheProcessingPool;

//isDestruction销毁
@property (nonatomic, assign) NSInteger isDestruction;


+ (CellsysMsgStatus *)getMsgOperationTypeObjWithMsgType:(NSInteger)msgType msgProtocolType:(NSInteger)msgProtocolType;

@end

NS_ASSUME_NONNULL_END
