//
//  CellsysMessageController.h
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import "CellsysMessageBody.h"
#import "CellsysMessageGenerator.h"
#import "MessageBodyListModel.h"

@class CellsysBLEMsgBody;

NS_ASSUME_NONNULL_BEGIN

//代理协议
@protocol CellsysMessageControllerDelegate <NSObject>

@optional

//isTransmit 转发、传输
- (void)transmitMessageBody:(CellsysMessageBody * _Nullable)messageBody;

//isReply 回复
- (void)replyMessageBody:(CellsysMessageBody * _Nullable)messageBody;

//isWarehousing入库（上云服务器）
- (void)warehousingMessageBody:(CellsysMessageBody * _Nullable)messageBody;

//isUploadMQTT上传MQTT
- (void)uploadMQTTMessageBody:(CellsysMessageBody * _Nullable)messageBody;

//isRetransmissio重传
- (void)retransmissioMessageBody:(CellsysMessageBody * _Nullable)messageBody;

@end

@interface CellsysMessageController : NSObject

+ (CellsysMessageController *)sharedManager;

//添加代理
- (void)addDelegate:(id<CellsysMessageControllerDelegate>)delegate;
//移除代理
- (void)removeDelegate:(id<CellsysMessageControllerDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
