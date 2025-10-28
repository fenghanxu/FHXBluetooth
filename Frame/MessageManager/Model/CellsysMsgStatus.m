//
//  CellsysMsgStatus.m
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import "CellsysMsgStatus.h"

@implementation CellsysMsgStatus

//typedef NS_ENUM(NSInteger){
//
//    MsgType_Unknow                      = 0<<0, //未知消息类型
//    MsgType_ChatText                    = 1<<0, //文本聊天消息
//    MsgType_ChatAudio                   = 2<<0, //语音聊天消息
//    MsgType_Portal                      = 3<<0, //系统后台消息
//    MsgType_Location                    = 4<<0, //位置推送消息
//    MsgType_EquipmentInfo               = 5<<0, //设备信息消息
//    MsgType_SOS                         = 6<<0, //SOS求救消息
//    MsgType_PublicText                  = 7<<0, //文本消息
//    MsgType_Sensing                     = 8<<0, //传感设备消息
//    MsgType_Logistics                   = 9<<0, //物流运输
//    MsgType_Fence                       = 10<<0, //围栏警报消息
//    MsgType_Transfer                    = 11<<0, //指挥机中转消息
//    MsgType_Ereceipt                    = 12<<0, //回执消息
//
//
//}MsgType;//消息类型

+ (CellsysMsgStatus *)getMsgOperationTypeObjWithMsgType:(NSInteger)msgType msgProtocolType:(NSInteger)msgProtocolType{
    
    CellsysMsgStatus *model = [[CellsysMsgStatus alloc] init];
    
    switch (msgType) {
        case MsgType_Unknow:{
            
            model.isTransmit = YES;
            
        }
            break;
        case MsgType_ChatText:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                    
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
            
        }
            break;
        case MsgType_ChatAudio:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
            
        }
            break;
        case MsgType_Portal:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
            
        }
            break;
        case MsgType_Location:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
        }
            break;
        case MsgType_EquipmentInfo:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
            
        }
            break;
        case MsgType_SOS:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                    model.isUploadMQTT = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
            
        }
            break;
        case MsgType_PublicText:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
        }
            break;
        case MsgType_Sensing:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
        }
            break;
        case MsgType_Logistics:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
        }
            break;
        case MsgType_Fence:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                    model.isWarehousing = YES;
                    model.isUploadMQTT = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
        }
            break;
        case MsgType_Transfer:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                    model.isWarehousing = YES;
                    model.isUploadMQTT = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
        }
            break;
        case MsgType_Ereceipt:{
            
            switch (msgProtocolType) {
                case MsgProtocolType_BLE:
                {
                    model.isTransmit = YES;
                    model.isCacheProcessingPool = YES;
                }
                    break;
                case MsgProtocolType_MQTT:
                {
                    
                }
                    break;
                case MsgProtocolType_TCP:
                {
                    
                }
                    break;
                case MsgProtocolType_UDP:
                {
                    
                }
                    break;
                case MsgProtocolType_Unknow:
                {
                    
                }
                    break;
                    
                default:{
                    
                }
                    break;
            }
            
        }
            break;
            
            
        default:
            break;
    }

    return model;
}

@end
