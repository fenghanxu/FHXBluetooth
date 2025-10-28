//
//  CellsysMessageBody.h
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import "CellsysMsgStatus.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger){
    
    MsgType_Unknow                      = 0<<0, //未知消息类型
    MsgType_ChatText                    = 1<<0, //文本聊天消息
    MsgType_ChatAudio                   = 2<<0, //语音聊天消息
    MsgType_Portal                      = 3<<0, //系统后台消息（下行）
    MsgType_Location                    = 4<<0, //位置推送消息
    MsgType_EquipmentInfo               = 5<<0, //设备信息消息
    MsgType_SOS                         = 6<<0, //SOS求救消息
    MsgType_PublicText                  = 7<<0, //文本消息
    MsgType_Sensing                     = 8<<0, //传感设备消息
    MsgType_Logistics                   = 9<<0, //物流运输
    MsgType_Fence                       = 10<<0, //围栏警报消息
    MsgType_Transfer                    = 11<<0, //指挥机中转消息
    MsgType_Ereceipt                    = 12<<0, //回执消息
    
    
}MsgType;//消息类型

typedef NS_ENUM(NSInteger){
    
    MsgProtocolType_Unknow           = 0<<0, //未知消息传输协议类型
    MsgProtocolType_TCP              = 1<<0, //
    MsgProtocolType_UDP              = 2<<0, //
    MsgProtocolType_MQTT             = 3<<0, //
    MsgProtocolType_BLE              = 4<<0, //
    
}MsgProtocolType;//消息传输协议类型


@interface CellsysMessageBody : CSArchiveBaseModel

//唯一标识（生成消息体的毫秒级时间戳）
@property (nonatomic, copy) NSString *msgID;

//msgData，消息内容（源消息数据，二进制数据流）
@property (nonatomic, strong) NSData *msgData;

//消息传输协议类型
@property (nonatomic, assign) MsgProtocolType msgProtocolType;

//msgType，消息类型（当前消息是条什么类型消息）
@property (nonatomic, assign) MsgType msgType;

//msgStatus，当前消息状态（json对象）
@property (nonatomic, strong) NSDictionary *msgStatus;

//msgOperationType，消息操作类型（这条消息需要做哪些操作，消息控制器去做对应操作）
@property (nonatomic, strong) NSDictionary *msgOperationType;

//msgCreateTime，消息生成时间
@property (nonatomic, copy) NSString *msgCreateTime;

//msgSender，发送者
@property (nonatomic, copy) NSString *msgSender;

//msgRecipient，接受者
@property (nonatomic, copy) NSString *msgRecipient;

//msgTransferNode，传输节点集合
@property (nonatomic, strong) NSArray *msgTransferNode;

@end

NS_ASSUME_NONNULL_END
