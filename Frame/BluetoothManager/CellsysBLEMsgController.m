//
//  CellsysBLEMsgController.m
//  Chat
//
//  Created by 刘磊 on 2021/3/21.
//

#import "CellsysBLEMsgController.h"
#import "CellsysBLEMsgBodyList.h"

@interface CellsysBLEMsgController ()<CellsysMessageControllerDelegate>

//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation CellsysBLEMsgController

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
        [[CellsysMessageController sharedManager] addDelegate:self];
    }
    return self;
}


#pragma mark - 添加代理
- (void)addDelegate:(id<CellsysBLEMsgControllerDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}



#pragma mark - 移除代理
- (void)removeDelegate:(id<CellsysBLEMsgControllerDelegate>)delegate
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


#pragma mark -  CellsysMessageControllerDelegate

//回复
- (void)replyMessageBody:(CellsysMessageBody *)messageBody{
    
    if (messageBody.msgProtocolType != MsgProtocolType_BLE) {
        return;
    }
    
    
}

//入库
- (void)warehousingMessageBody:(CellsysMessageBody *)messageBody{
    
    if (messageBody.msgProtocolType != MsgProtocolType_BLE) {
        return;
    }
    
    
}

//上传MQTT
- (void)uploadMQTTMessageBody:(CellsysMessageBody *)messageBody{
    
    if (messageBody.msgProtocolType != MsgProtocolType_BLE) {
        return;
    }
    
    
    
}

//重传
- (void)retransmissioMessageBody:(CellsysMessageBody *)messageBody{
    
    if (messageBody.msgProtocolType != MsgProtocolType_BLE) {
        return;
    }
    
    
}


// 转发、传输  CellsysBLEMsgController(应用层)
- (void)transmitMessageBody:(CellsysMessageBody *)messageBody{
    
    if (messageBody.msgProtocolType != MsgProtocolType_BLE) {
        return;
    }

    //消息体传输到应用层被消费后，改变消息缓存处理池中的消息状态
    CellsysMsgStatus *msgStatus = [CellsysMsgStatus mj_objectWithKeyValues:messageBody.msgStatus];
    msgStatus.isTransmit = YES;
    messageBody.msgStatus = msgStatus.mj_keyValues;

    // 添加消息
    [MessageBodyListModel addMessage:messageBody];
    
    NSLog(@"%@(应用层)接收到数据体：%@",[self class],messageBody.mj_keyValues);
    
    CellsysBLEMsgBody *bleMsgBody = [CellsysBLEMsgBody analyseDataToCellsysBLEMsgBody:messageBody.msgData];
    
    //NSLog(@"CellsysBLEMsgController,数据类型：%@,CellsysBLEMsgBody:%@",bleMsgBody.dataType,bleMsgBody.mj_keyValues);

    //002F
    ///<002f006b 000001a1 04888888 0004807d 3ae5c64c 08888888 88888888 88000088 88000300 000030ae a4f519c4 08888888 88888888 88000088 88000300 010030ae a4f529d8 08888888 88888888 88000088 88000300 0000807d 3ae5c638 0306bce6 b0015f34 04000088 88010300 0300ff>
    if ([bleMsgBody.dataType isEqualToString:@"002f"]) {
        
        [self handle002FData:bleMsgBody];
        
    }
    else if([bleMsgBody.dataType isEqualToString:@"f00e"]) {
        
        [self handleF00EData:bleMsgBody];
        
        
    }
    else if([bleMsgBody.dataType isEqualToString:@"d011"]) {
        
        [self handleD011Data:bleMsgBody];

        
    }else{
        NSString *header = [NSString stringWithFormat:@"未知的数据"];
        NSLog(@"%s,%@类型数据未处理",__func__,bleMsgBody.dataType);
    }
    
    
}




//002F监控量，路由表数据
- (void)handle002FData:(CellsysBLEMsgBody *)bleMsgBody{
    
    NSData *data = bleMsgBody.receiveData;
    NSString *dataStr = [NSString convertDataToHexStr:data];
    
    NSString *header = [NSString stringWithFormat:@"收到路由表%@数据：",bleMsgBody.dataType];
    NSString *info = [NSString stringWithFormat:@"解析后：%@",bleMsgBody.mj_keyValues];

    //接收的每包数据缓存本地数据库
    [CellsysBLEMsgBodyList addBLEMsgBody:bleMsgBody];
    
    //在线全改成离线状态
    [[CellsysDataManager sharedCellsysDataManager] update:CellsysMemberForm primaryKey:@"memberStatus" primaryValue:@"1" updateKey:@"memberStatus" updateValue:@"0"];
    
    

    
    NSArray <CellsysBLEMsgBody *> *equArr = [CellsysBLEMsgBody analyse002FDataToComDataArr:data];
    
    
    NSMutableArray <CellsysMember *> *memberArr = [NSMutableArray array];
    
    for (CellsysBLEMsgBody *model in equArr) {
        
//        NSString *header = [NSString stringWithFormat:@"路由表中设备%@数据：",model.equMAC];
//        NSString *info = [NSString stringWithFormat:@"解析后：%@",model.mj_keyValues];

        //CLLocationCoordinate2D(世界标准地理坐标 WGS-84) 转 CLLocation(中国国测局地理坐标 GCJ-02）
        CLLocation *location = [CellsysGeometry getCLLocationFromWGS84WithLongitude:model.longitude latitude:model.latitude];
        CellsysGeometry *geometry = [CellsysGeometry getGeometryFromCLLocationCoordinate2D:location.coordinate];
        
    
        NSString *equMACStr = model.equMAC;
        
        NSArray <CellsysMember *> *macidMembers = [[CellsysDataManager sharedCellsysDataManager] queryWithTableName:CellsysMemberForm Class:[CellsysMember class] key:@"macid" value:equMACStr];
        

        if (macidMembers.count == 0) {
            //注意！！！不写入数据库
            CellsysMember *newMember = [CellsysMember initWithCellMember];
            newMember.macid = equMACStr;
            newMember.geometry = geometry.mj_keyValues;
            [memberArr addObject:newMember];
            
            [self isEffectiveLocationInfo:model member:newMember];
            
        }else{
            
            for (CellsysMember *member in macidMembers) {
                
                
                //成员在线
                member.memberStatus = @"1";
                member.geometry = geometry.mj_keyValues;
                // 向数据库写入数据
                [[CellsysDataManager sharedCellsysDataManager] insertNorepeatedWithTableName:CellsysMemberForm Class:[CellsysMember class] model:member primaryKey:@"user_id" primaryValue:member.user_id];
                
                [memberArr addObject:member];
                
                [self isEffectiveLocationInfo:model member:member];
 
            }
   
        }
  
    }
    
    //发出通知，更新成员状态，在线，离线
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateMemberStatus object:memberArr];
  
}


- (BOOL)isEffectiveLocationInfo:(CellsysBLEMsgBody *)model member:(CellsysMember *)member{
    
    
    if (model.longitude == 0 || model.latitude == 0 || model.longitude == -2004318072 || model.latitude == -2004318072) {
        NSLog(@"周边设备收到无效设备信息,时间间隔:%ld分钟,macid:%@",(long)model.timeInterval,model.equMAC);
        
        return  NO;
        
    }else if (model.isLocation == 1) {
        
        NSLog(@"收到有效设备信息,时间间隔:%ld分钟,macid:%@",(long)model.timeInterval,model.equMAC);
        
        //时间间隔不为0的不做处理
        if (model.timeInterval != 0) {
            return  NO;
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0]; // 获取当前时间0秒后的时间
        NSTimeInterval time = [date timeIntervalSince1970]*1000;// *1000 是精确到毫秒(13位),不乘就是精确到秒(10位)
        NSString *timeString = [NSString stringWithFormat:@"%ld", (long)time];
        
        CellsysMarker *memberMarker = [CellsysMarker mj_objectWithKeyValues:member];
        memberMarker.localMarkerType = 4;
        memberMarker.datetime = timeString;
        memberMarker.update_time = timeString;
        
        
        // 向数据库写入数据
        [[CellsysDataManager sharedCellsysDataManager] insertNorepeatedWithTableName:CellsysMemberMarkerForm Class:[CellsysMarker class] model:memberMarker primaryKey:@"macid" primaryValue:model.equMAC];
        
        //发出通知，周边设备位置信息
        [[NSNotificationCenter defaultCenter] postNotificationName:PerEquLocation object:memberMarker userInfo:nil];
    
        
        return YES;;
        
    }else{
        
        NSLog(@"周边设备收到无效设备信息,时间间隔:%ld分钟,macid:%@",(long)model.timeInterval,model.equMAC);
        return NO;;
    }
    
}

//F00E监控量，设备固件信息数据
- (void)handleF00EData:(CellsysBLEMsgBody *)bleMsgBody{
    
    NSData *data = bleMsgBody.receiveData;
    
    CellsysBLEMsgBody *lastBLEMsgBody = [[[CellsysDataManager sharedCellsysDataManager] queryWithTableName:CellsysBLEMsgBodyForm Class:[CellsysBLEMsgBody class] key:@"dataType" value:@"f00e"] lastObject];
    
    
    //和本地最后一条数据对比
    //GPS定位
    if (bleMsgBody.isLocation != lastBLEMsgBody.isLocation) {
        NSString *str = [NSString stringWithFormat:@"改变前：%ld\n改变后：%ld",(long)lastBLEMsgBody.isLocation,(long)bleMsgBody.isLocation];
        if (bleMsgBody.isLocation == 0) {
            [[CellsysUserNotifications sharedInstance] speechAudioMessage:@"GPS定位获取中，请稍后"];
        }else{
            [[CellsysUserNotifications sharedInstance] speechAudioMessage:@"GPS定位成功"];
        }
        
    }
    
    //文本通道
    if (bleMsgBody.isText != lastBLEMsgBody.isText) {
        NSString *lastInfo = [CellsysBLEMsgBody isTextToInfo:lastBLEMsgBody.isText];
        NSString *info = [CellsysBLEMsgBody isTextToInfo:bleMsgBody.isText];
        NSString *str = [NSString stringWithFormat:@"改变前：%@\n改变后：%@",lastInfo,info];
        
        [[CellsysUserNotifications sharedInstance] speechAudioMessage:info];
        
        
    }
    
    //语音通道
    if (bleMsgBody.isAudio != lastBLEMsgBody.isAudio) {
        NSString *lastInfo = [CellsysBLEMsgBody isAudioToInfo:lastBLEMsgBody.isAudio];
        NSString *info = [CellsysBLEMsgBody isAudioToInfo:bleMsgBody.isAudio];
        NSString *str = [NSString stringWithFormat:@"改变前：%@\n改变后：%@",lastInfo,info];
        
        [[CellsysUserNotifications sharedInstance] speechAudioMessage:info];
        
    }
    
    NSString *header = [NSString stringWithFormat:@"收到%@设备%@数据：",bleMsgBody.macid,bleMsgBody.dataType];
    NSString *dataStr = [NSString convertDataToHexStr:data];
    NSString *info = [NSString stringWithFormat:@"解析后：%@",bleMsgBody.mj_keyValues];

    //接收的每包数据缓存本地数据库
    [CellsysBLEMsgBodyList addBLEMsgBody:bleMsgBody];

    //NSLog(@"%s,F00E数据解析：%@",__func__,bleMsgBody.mj_keyValues);

    //CLLocationCoordinate2D(世界标准地理坐标 WGS-84) 转 CLLocation(中国国测局地理坐标 GCJ-02）
    CLLocation *location = [CellsysGeometry getCLLocationFromWGS84WithLongitude:bleMsgBody.longitude latitude:bleMsgBody.latitude];
    CellsysGeometry *geometry = [CellsysGeometry getGeometryFromCLLocationCoordinate2D:location.coordinate];
    
    
    for (id<CellsysBLEMsgControllerDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(handleCellsysBLEMsgBodyAndF00EData:)]) {
            [delegate handleCellsysBLEMsgBodyAndF00EData:bleMsgBody];
        }
    }
    
    
    if (bleMsgBody.longitude == 0 || bleMsgBody.latitude == 0 || bleMsgBody.longitude == -2004318072 || bleMsgBody.latitude == -2004318072) {
        NSLog(@"F00E收到无效设备信息,F00E位置信息：%@",geometry.mj_JSONString);
        return;
    }
    
    
    [LocationTool sharedInstance].location = location;
    
}

//D011监控量，设备间通讯数据
- (void)handleD011Data:(CellsysBLEMsgBody *)bleMsgBody{
    
    NSData *data = bleMsgBody.receiveData;
    
    NSString *header = [NSString stringWithFormat:@"收到设备间通讯%@数据：",bleMsgBody.dataType];
    NSString *dataStr = [NSString convertDataToHexStr:data];
    NSString *info = [NSString stringWithFormat:@"解析后：%@",bleMsgBody.mj_keyValues];
    
    NSMutableDictionary *currentFrameDic = [NSMutableDictionary dictionary];
    [currentFrameDic setValue:bleMsgBody.contentId forKey:@"contentId"];
    [currentFrameDic setValue:bleMsgBody.dataType forKey:@"dataType"];
    [currentFrameDic setValue:[NSString stringWithFormat:@"%ld",(long)bleMsgBody.state] forKey:@"state"];
    
    NSString *currentFrame = [NSString stringWithFormat:@"%ld",(long)bleMsgBody.currentFrame];
    [currentFrameDic setValue:currentFrame forKey:@"currentFrame"];
    
    
//    NSArray <CellsysBLEMsgBody *> *currentFrameDataArr = [[CellsysDataManager sharedCellsysDataManager] queryWithTableName:CellsysBLEMsgBodyForm Class:[CellsysBLEMsgBody class] primaryDictionary:currentFrameDic];
    //筛选出符合字典要求的数据
    NSMutableArray<CellsysBLEMsgBody *> *currentFrameDataArr = [NSMutableArray<CellsysBLEMsgBody *> new];
    //总的数据
    NSArray<CellsysBLEMsgBody *> *list = [CellsysBLEMsgBodyList getAllBLEMsgBody];
    for (int i = 0; i < list.count; i++) {
        if ([list[i].contentId isEqualToString:currentFrameDic[@"contentId"]] &&
            [list[i].dataType isEqualToString:currentFrameDic[@"dataType"]] &&
            list[i].state == [currentFrameDic[@"state"] intValue] &&
            list[i].currentFrame == [currentFrameDic[@"currentFrame"] intValue]
            ) {
            [currentFrameDataArr addObject:list[i]];
        }
    }
      
    if (currentFrameDataArr.count == 0) {
        NSLog(@"收到新的包数据,%ld,%ld,%ld,%ld,%@,%@",(long)bleMsgBody.currentFrame,(long)bleMsgBody.countFrame,(long)bleMsgBody.contentType,bleMsgBody.state,bleMsgBody.contentId,bleMsgBody.contentData.mj_JSONString);
        //接收的每包数据缓存本地数据库
        [CellsysBLEMsgBodyList addBLEMsgBody:bleMsgBody];
    }else{
        NSLog(@"收到重复的包数据,%ld,%ld,%ld,%ld,%@,%@",(long)bleMsgBody.currentFrame,(long)bleMsgBody.countFrame,(long)bleMsgBody.contentType,bleMsgBody.state,bleMsgBody.contentId,bleMsgBody.contentData.mj_JSONString);
        return;
    }
    
    //不在此处对CellsysComData做数据缓存本地数据库
    
    NSLog(@"%s---%@",__func__,bleMsgBody.mj_keyValues);
    
    for (id<CellsysBLEMsgControllerDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(handleCellsysBLEMsgBodyAndD011Data:)]) {
            [delegate handleCellsysBLEMsgBodyAndD011Data:bleMsgBody];
        }
    }

}

@end
