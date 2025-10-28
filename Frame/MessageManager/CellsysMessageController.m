//
//  CellsysMessageController.m
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import "CellsysMessageController.h"

@interface CellsysMessageController ()<CellsysMessageGeneratorDelegate>

//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;

@property (nonatomic,strong) CellsysMsgStatus *msgStatus;

@end

@implementation CellsysMessageController

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [[CellsysMessageGenerator sharedManager] addDelegate:self];
    }
    return self;
}


#pragma mark - 添加代理
- (void)addDelegate:(id<CellsysMessageControllerDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}



#pragma mark - 移除代理
- (void)removeDelegate:(id<CellsysMessageControllerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

- (NSMutableArray *)delegates
{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}



#pragma mark - CellsysMessageGeneratorDelegate
- (void)handleCellsysMessageBodyFromCellsysMessageGenerator:(CellsysMessageBody *)messageBody{
    NSString *message = [NSString stringWithFormat:@"%@",messageBody.mj_keyValues];
    NSLog(@"消息控制器接收到消息生成器生成的消息体:%@",message);
    
    [self contrastMsgStatusAndMsgOperationType:messageBody];
    
}


//对比当前消息状态对象和消息操作类型对象,做对应的操作
- (void)contrastMsgStatusAndMsgOperationType:(CellsysMessageBody *)msgBody{
    
    CellsysMsgStatus *msgStatus = [CellsysMsgStatus mj_objectWithKeyValues:msgBody.msgStatus];
    
    CellsysMsgStatus *msgOperationType = [CellsysMsgStatus mj_objectWithKeyValues:msgBody.msgOperationType];
    
    
    //isCacheProcessingPool （塞入消息缓存处理池）
    if (msgOperationType.isCacheProcessingPool && !msgStatus.isCacheProcessingPool) {
    
        msgStatus.isCacheProcessingPool = YES;
        
        msgBody.msgStatus = msgStatus.mj_keyValues;
        
        // 添加消息
        [MessageBodyListModel addMessage:msgBody];
    }
    
    //isTransmit 转发、传输
    if (msgOperationType.isTransmit && !msgStatus.isTransmit) {
        for (id<CellsysMessageControllerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(transmitMessageBody:)] ) {
                [delegate transmitMessageBody:msgBody];
            }
        }
    }
    
    //isReply 回复
    if (msgOperationType.isReply && !msgStatus.isReply) {
        for (id<CellsysMessageControllerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(transmitMessageBody:)] ) {
                [delegate transmitMessageBody:msgBody];
            }
        }
    }

    //isExpired 过期
    if (msgOperationType.isExpired && !msgStatus.isExpired) {
        msgStatus.isExpired = YES;
        msgBody.msgStatus = msgStatus.mj_keyValues;        
        // 删除消息
        [MessageBodyListModel removeMessageWithID:msgBody.msgID];
    }

    //isWarehousing入库（上云服务器）
    if (msgOperationType.isWarehousing && !msgStatus.isWarehousing) {
        for (id<CellsysMessageControllerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(warehousingMessageBody:)] ) {
                [delegate warehousingMessageBody:msgBody];
            }
        }
    }

    //isUploadMQTT上传MQTT
    if (msgOperationType.isUploadMQTT && !msgStatus.isUploadMQTT) {
        for (id<CellsysMessageControllerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(uploadMQTTMessageBody:)] ) {
                [delegate uploadMQTTMessageBody:msgBody];
            }
        }
    }

    //isRetransmissio重传
    if (msgOperationType.isRetransmissio && !msgStatus.isRetransmissio) {
        for (id<CellsysMessageControllerDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(retransmissioMessageBody:)] ) {
                [delegate retransmissioMessageBody:msgBody];
            }
        }
    }

    //isDestruction销毁
    if (msgOperationType.isDestruction && !msgStatus.isDestruction) {
        // 删除消息
        [MessageBodyListModel removeMessageWithID:msgBody.msgID];
    }
   
}

@end
