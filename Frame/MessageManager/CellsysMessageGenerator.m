//
//  CellsysMessageGenerator.m
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import "CellsysMessageGenerator.h"
#import "CellsysMsgServer.h"
#import "CellsysBLEMsgBody.h"

@interface CellsysMessageGenerator ()<CellsysMsgServerDelegate>

//所有的代理
@property (nonatomic, strong) NSMutableArray         *delegates;

@property (nonatomic, strong) CellsysMsgServer       *msgServer;

@property (nonatomic, strong) CellsysBLEMsgBody      *bleMsgBody;

@property (nonatomic, strong) CellsysMsgStatus       *msgStatus;

@property (nonatomic, strong) CellsysMsgStatus       *msgOperationType;

@end



@implementation CellsysMessageGenerator

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[CellsysMsgServer sharedManager] addDelegate:self];
    }
    return self;
}


#pragma mark - 添加代理
- (void)addDelegate:(id<CellsysMessageGeneratorDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}



#pragma mark - 移除代理
- (void)removeDelegate:(id<CellsysMessageGeneratorDelegate>)delegate
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


- (CellsysBLEMsgBody *)bleMsgBody{
    if (_bleMsgBody == nil) {
        _bleMsgBody = [[CellsysBLEMsgBody alloc] init];
    }
    return _bleMsgBody;
}

- (CellsysMsgStatus *)msgStatus{
    if (_msgStatus == nil) {
        _msgStatus = [[CellsysMsgStatus alloc] init];
    }
    return _msgStatus;
}

- (CellsysMsgStatus *)msgOperationType{
    if (_msgOperationType == nil) {
        _msgOperationType = [[CellsysMsgStatus alloc] init];
    }
    return _msgOperationType;
}

#pragma mark - CellsysMsgServerDelegate（接收CellsysMsgServer传过来的数据）
- (void)handleMessageToCellsysMessageGenerator:(id)message withMsgProtocolType:(MsgProtocolType)msgProtocolType{
    
    switch (msgProtocolType) {
        case MsgProtocolType_BLE:
        {
            CellsysBLEMsgBody *model = (CellsysBLEMsgBody *)message;
            [self generateMessageBodyWithBLEMsgBody:model];
        }
            break;
        case MsgProtocolType_MQTT:
            break;
        case MsgProtocolType_TCP:
            break;
        case MsgProtocolType_UDP:
            break;
        case MsgProtocolType_Unknow:
            break;
        default:
            break;
    }
    
}


#pragma mark - 生成消息体，MQTT数据
//- (void)generateMessageBodyWithMQTTEMsgBody:(CellsysPush *)mqttBody{
//    
//    NSLog(@"%@收到一条消息,CellsysPush：%@",[self class],mqttBody.mj_keyValues);
//    
//    CellsysMessageBody *model = [[CellsysMessageBody alloc] init];
//    
//    model.msgID = [NSDate getCurrentTimestamp13];
//    model.msgData = mqttBody.msgData;
//    model.msgProtocolType = MsgProtocolType_MQTT;
//    
//    //消息状态初始化
//    model.msgStatus = self.msgStatus.mj_keyValues;
//    
//    NSString *msgSender = @"iphone1";
//    model.msgSender = msgSender;
//    
//    NSString *msgRecipient = @"iphone2";
//    model.msgRecipient = msgRecipient;
//    
//    model.msgCreateTime = [NSDate getCurrentTimestamp13];
//    
//    model.msgType = MsgType_ChatText;
//    
//    //结合消息应用类型和消息传输协议类型，可以知道该条消息的消息操作类型对象
//    CellsysMsgStatus *operationTypeObj = [CellsysMsgStatus getMsgOperationTypeObjWithMsgType:model.msgType msgProtocolType:model.msgProtocolType];
//    
//    self.msgOperationType = operationTypeObj;
//    
//    
//    model.msgOperationType = self.msgOperationType.mj_keyValues;
//    
//    [self callDelegateWithCellsysMessageBody:model];
//    
//    
//    
//}

#pragma mark - 生成消息体，BLE数据
- (void)generateMessageBodyWithBLEMsgBody:(CellsysBLEMsgBody *)bleMsgBody{
    
    NSLog(@"%@收到一条消息,CellsysBLEMsgBody：%@",[self class],bleMsgBody.mj_keyValues);
    
    CellsysMessageBody *model = [[CellsysMessageBody alloc] init];
    
//    model.msgID = [NSDate getCurrentTimestamp13];
    model.msgID = [self msgIDWithBLEMsgBody:bleMsgBody];
    model.msgData = bleMsgBody.receiveData;
    model.msgProtocolType = MsgProtocolType_BLE;
    
    //消息状态初始化
    model.msgStatus = self.msgStatus.mj_keyValues;
    
    
    NSString *msgSender = bleMsgBody.sendMAC;
    model.msgSender = msgSender;
     
    NSString *msgRecipient = bleMsgBody.acceptMAC;
    model.msgRecipient = msgRecipient;
    

    if ([bleMsgBody.dataType isEqualToString:@"002f"]) {
        
        if (bleMsgBody.equTimeType == 4) {
            model.msgCreateTime = [NSDate getCurrentTimestamp13];
        }else{
            model.msgCreateTime = [NSString stringWithFormat:@"%d000",bleMsgBody.equTime];
        }
        
        model.msgType = MsgType_Location;
        
    }
    else if([bleMsgBody.dataType isEqualToString:@"f00e"]) {
        
        if (bleMsgBody.equTimeType == 4) {
            model.msgCreateTime = [NSDate getCurrentTimestamp13];
        }else{
            model.msgCreateTime = [NSString stringWithFormat:@"%d000",bleMsgBody.equTime];
        }
        
        model.msgType = MsgType_EquipmentInfo;
        
        
    }
    else if([bleMsgBody.dataType isEqualToString:@"d011"]) {
        
        if (bleMsgBody.timeType == 4) {
            model.msgCreateTime = [NSDate getCurrentTimestamp13];
        }else{
            model.msgCreateTime = [NSString stringWithFormat:@"%d000",bleMsgBody.timeData];
        }
        
        
        switch (bleMsgBody.contentType) {
            
            case 1:{
                model.msgType = MsgType_ChatText;
            }break;
            case 2:{
                model.msgType = MsgType_Location;
            }break;
            case 3:{
                model.msgType = MsgType_Fence;
            }break;
                
            case 4:{
                model.msgType = MsgType_ChatAudio;
            }break;
            
            case 5:{
                model.msgType = MsgType_Location;
            }break;
                
            case 6:{
                
            }break;
                
            case 7:{
                model.msgType = MsgType_PublicText;
            }break;
                
            case 8:{
                
            }break;
                
            case 9:{
                
            }break;
                
            case 10:{
                model.msgType = MsgType_SOS;
            }break;
                
            case 11:{
                model.msgType = MsgType_Transfer;
            }break;
                
            case 12:{
                model.msgType = MsgType_Portal;
            }break;
                
            case 13:{
                model.msgType = MsgType_Transfer;
            }break;
                
                
            case 14:{
                model.msgType = MsgType_Sensing;
            }break;
                
            case 15:{
                model.msgType = MsgType_Transfer;
            }break;
                
            default:{
                model.msgType = MsgType_Unknow;
            }
                break;
        }
        
        switch (bleMsgBody.state) {
            case 37://正常消息
            {
                
            }
                break;
            case 39://回执消息
            {
                model.msgType = MsgType_Ereceipt;
            }
                break;
            case 136://通知消息
            {
    
            }
                break;
                
            default:{

            }
                break;
        }
        
        
        
    }else{
       
    }
    
    
    //结合消息应用类型和消息传输协议类型，可以知道该条消息的消息操作类型对象
    CellsysMsgStatus *operationTypeObj = [CellsysMsgStatus getMsgOperationTypeObjWithMsgType:model.msgType msgProtocolType:model.msgProtocolType];
    
    self.msgOperationType = operationTypeObj;
    
    
    model.msgOperationType = self.msgOperationType.mj_keyValues;
    
    [self callDelegateWithCellsysMessageBody:model];

    
}

//类型：String
//说明：唯一标识
//加密方式：MD5加密
//加密结构：序列号 + 目的MAC + 发出MAC + 类型 + 采集时刻 + 时间类型 + 总包数  + 当前包数
//加密长度：3*2   + 6*2    + 6*2    + 2*2  + 4*2    + 1*2     + 1*1   +  1*1     = 22*2 + 1 + 1 = 46
//补充说明：总长度不变，没有或不足则用“0”补充;转换后统一为大写
//加密参数：46位字符串
//加密后： 32位字符串
- (NSString *)msgIDWithBLEMsgBody:(CellsysBLEMsgBody *)bleMsgBody{
    
    //操作序号
    NSString *operateData = [NSString convertDataToHexStr:bleMsgBody.operateData];
    if ([NSObject isEmpty:operateData]) {
        operateData = @"000000";
    }
    
    //接受者BleMacID
    NSString *acceptMAC = bleMsgBody.acceptMAC;
    if ([NSObject isEmpty:acceptMAC]) {
        acceptMAC = @"000000000000";
    }
    acceptMAC = [acceptMAC stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    //发起者BleMacID
    NSString *sendMAC = bleMsgBody.sendMAC;
    if ([NSObject isEmpty:sendMAC]) {
        sendMAC = @"000000000000";
    }
    sendMAC = [sendMAC stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    //采集时刻
    if (bleMsgBody.timeType == 4) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
        NSTimeInterval time = [date timeIntervalSince1970];
        bleMsgBody.timeData = time;
    }
    NSMutableData *mutData = [[NSMutableData alloc] init];
    int32_t time = bleMsgBody.timeData;
    HTONL(time);
    [mutData appendBytes:&time length:4];
    NSString *timeStr = [NSString convertDataToHexStr:mutData];
    //时间类型
    NSString *timeType = [NSString stringWithFormat:@"%02ld",(long)bleMsgBody.timeType];

    NSString *countFrameString = [NSString stringWithFormat:@"%ld",bleMsgBody.countFrame];
    NSString *currentFrameString = [NSString stringWithFormat:@"%ld",bleMsgBody.currentFrame];
    
    //拼接
    NSString *input = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",operateData,acceptMAC,sendMAC,bleMsgBody.dataType,timeStr,timeType,countFrameString,currentFrameString];
    input = [input uppercaseString];

    //MD5加密
    NSString *msgID = [NSString stringToMD5:input];
    
    NSLog(@"%s,%lu,加密前%@,加密后%@,加密后长度%lu",__func__,(unsigned long)input.length,input,msgID,msgID.length);
    
    return msgID;
}


#pragma mark - 委托方调用代理，让代理方去处理
- (void)callDelegateWithCellsysMessageBody:(CellsysMessageBody *)msgBody{
    
    for (id<CellsysMessageGeneratorDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(handleCellsysMessageBodyFromCellsysMessageGenerator:)] ) {
            [delegate handleCellsysMessageBodyFromCellsysMessageGenerator:msgBody];
        }
    }
    
}

@end
