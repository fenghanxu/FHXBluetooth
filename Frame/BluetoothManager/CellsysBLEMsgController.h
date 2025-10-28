//
//  CellsysBLEMsgController.h
//  Chat
//
//  Created by 刘磊 on 2021/3/21.
//

#import <Foundation/Foundation.h>
#import "CellsysBLEMsgBody.h"
#import "CellsysMessageController.h"
#import "BLEMsgBodyListModel.h"

NS_ASSUME_NONNULL_BEGIN

//代理协议
@protocol CellsysBLEMsgControllerDelegate <NSObject>
@optional

//根据不同的监控量类型分发消息给对应消费者

//代理传值,002F监控量，路由表数据
- (void)handleCellsysBLEMsgBodyAnd002FData:(CellsysBLEMsgBody *)bleMsgBody;

//代理传值,F00E监控量，设备固件信息数据
- (void)handleCellsysBLEMsgBodyAndF00EData:(CellsysBLEMsgBody *)bleMsgBody;

//代理传值,D011监控量，设备间通讯数据
- (void)handleCellsysBLEMsgBodyAndD011Data:(CellsysBLEMsgBody *)bleMsgBody;


@end


@interface CellsysBLEMsgController : NSObject

+ (CellsysBLEMsgController *)sharedManager;

//添加代理
- (void)addDelegate:(id<CellsysBLEMsgControllerDelegate>)delegate;
//移除代理
- (void)removeDelegate:(id<CellsysBLEMsgControllerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
