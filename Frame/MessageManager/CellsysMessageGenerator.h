//
//  CellsysMessageGenerator.h
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import "CellsysMessageBody.h"


NS_ASSUME_NONNULL_BEGIN

//代理协议
@protocol CellsysMessageGeneratorDelegate <NSObject>
@optional

//消息生成器生成的消息体，通过代理委托给消息控制器去处理
- (void)handleCellsysMessageBodyFromCellsysMessageGenerator:(CellsysMessageBody * _Nullable)messageBody;

@end

@interface CellsysMessageGenerator : NSObject

+ (CellsysMessageGenerator *)sharedManager;

//添加代理
- (void)addDelegate:(id<CellsysMessageGeneratorDelegate>)delegate;
//移除代理
- (void)removeDelegate:(id<CellsysMessageGeneratorDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
