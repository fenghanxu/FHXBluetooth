//
//  CellsysMsgServer.h
//  Chat
//
//  Created by 刘磊 on 2021/3/23.
//

#import <Foundation/Foundation.h>
#import "CellsysBLEClient.h"
#import "CellsysMessageGenerator.h"

NS_ASSUME_NONNULL_BEGIN
//代理协议
@protocol CellsysMsgServerDelegate <NSObject>
@optional

//消息通过代理委托给消息生成器去处理
- (void)handleMessageToCellsysMessageGenerator:(id)message;

@end


@interface CellsysMsgServer : NSObject

+ (CellsysMsgServer *)sharedManager;

//添加代理
- (void)addDelegate:(id<CellsysMsgServerDelegate>)delegate;
//移除代理
- (void)removeDelegate:(id<CellsysMsgServerDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
