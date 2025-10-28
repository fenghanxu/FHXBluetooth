//
//  CellsysBLEMsgBody.h
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CellsysMember.h"
#import "CellsysMarker.h"
#import "CellsysBLEClient.h"
#import "CellsysGeometry.h"
#import "LocationTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface CellsysBLEMsgBody : CSArchiveBaseModel<NSMutableCopying,NSCopying>


/**发送一条报文完整内容数据*/
@property (nonatomic, strong) NSData *sendMessageData;

//接受到的一包完整数据，D011(97字节，97字节是F00C/F005数据),002F(不定字节)
@property (nonatomic, strong) NSData *receiveData;

//发送的一包完整数据，97字节
@property (nonatomic, strong) NSData *sendData;

//监控量类型,2字节  （DO11、002F、F00E）
@property (nonatomic, copy) NSString *dataType;

//监控量数据长度，2字节
@property (nonatomic, assign) NSInteger dataLength;

//采集时刻/动作时限，4字节
@property (nonatomic, assign) int32_t timeData;

//时间类型，1字节
//时间类型    备注    时间格式
//0    同步到云平台的时间    10位时间戳
//1    北斗时间    10位时间戳
//2    GPS时间    10位时间戳
//3    GPS、北斗双模时间    10位时间戳
//4    开机运行累计时间    秒，注：不能直接转时间戳
//5    手机APP时间    10位时间戳
@property (nonatomic, assign) NSInteger timeType;

//设置/读取，1字节
//    正常数据的收发，设置/读取标志位都是 0x25。(37)  接收数据
//    即，发送数据的时候，该标志位传0x25。而当接收到的数据标志位是0x25的时候，表示你收到的是正常数据。
//    而回执数据的设置/读取 标志位时0x27。(39)       回执
//    即当你收到数据，且标志位位0x27的时候，该数据代表的是你的之前发送过的数据已成功发送了。
//    而通知数据的设置/读取 标志位时0x28。(40)       通知
//    即当你收到数据，且标志位位0x88的时候，该数据代表的是通知数据。
@property (nonatomic, assign) NSInteger state;

//告警状态，1字节
@property (nonatomic, assign) NSInteger errorState;

//紧急程度，1字节
@property (nonatomic, assign) NSInteger adjective;

//二级监控量类型,2字节
@property (nonatomic, copy) NSString *monitorType;

//二级监控量数据长度，2字节
@property (nonatomic, assign) NSInteger monitorDataLength;

/**数据内容,51字节*/
/**当前帧数（1~255），1字节*/
@property (nonatomic, assign) NSInteger currentFrame;

//总帧数，1字节
@property (nonatomic, assign) NSInteger countFrame;

//数据类型，1字节,软件内部规定的内容类型，包含文本、4语音、位置、指挥机相关内容
@property (nonatomic, assign) NSInteger contentType;

//数据内容ID，4字节，10位的时间戳（精确到秒）
@property (nonatomic, copy) NSString *contentId;

/**数据内容，44字节*/
@property (nonatomic, strong) NSData *contentData;

/**发起者BleMacID，6字节  (BleMacID = WiFiMacID【末位】 + 2) */
@property (nonatomic, copy) NSString *sendMAC;

/**接受者BleMacID，6字节  (BleMacID = WiFiMacID【末位】 + 2) */
@property (nonatomic, copy) NSString *acceptMAC;

//发出的端口，1字节
@property (nonatomic, assign) NSInteger sendPort;

//硬件设备数据类型，1字节  0：语音；1:视频；2：视频流；3：文本
@property (nonatomic, assign) NSInteger equDataType;

/**消息目的群组编号，2字节*/
@property (nonatomic, strong) NSData *groupData;

//数据最终端口，1字节
@property (nonatomic, assign) NSInteger receivePort;


//操作序号，3字节
@property (nonatomic, strong) NSData *operateData;


//CRC8，1字节
@property (nonatomic, strong) NSData *crc8Data;

#pragma mark -- 002F相关
//周边设备数量，2字节
@property (nonatomic, assign) NSInteger equNum;


/**设备MAC，6字节*/
@property (nonatomic, copy) NSString *equMAC;

//路由表数组
@property (nonatomic, strong) NSArray *equDataArr;

//经纬度类型，1字节
@property (nonatomic, assign) NSInteger locationType;

//经度
@property (nonatomic, assign) int32_t longitude;

//纬度
@property (nonatomic, assign) int32_t latitude;

//高度
@property (nonatomic, assign) int32_t altitude;

//是否定位，0无效，1定位有效，1字节
@property (nonatomic, assign) NSInteger isLocation;

//能接受信息的类型，1字节
@property (nonatomic, assign) NSInteger acceptDataType;

//最近一次通讯距离现在的时间差，单位：分钟，2字节
@property (nonatomic, assign) NSInteger timeInterval;

#pragma mark -- D011，51字节内部相关

//温度
@property (nonatomic, assign) int32_t temperature;

//湿度
@property (nonatomic, assign) int32_t humidity;


#pragma mark -- F00E相关
@property (nonatomic, assign) int32_t equTime;

//时间类型，1字节
@property (nonatomic, assign) NSInteger equTimeType;

//端口状态，512字节
@property (nonatomic, strong) NSData *portState;

//ble-->是否支持蓝牙连接:292  0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
@property (nonatomic, assign) NSInteger isConnectBLE;
//sx1278-->文本通道:324   0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
@property (nonatomic, assign) NSInteger isText;
//sx1280-->语音通道:328   0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
@property (nonatomic, assign) NSInteger isAudio;
//
@property (nonatomic, assign) NSInteger isRD;
//
@property (nonatomic, assign) NSInteger isIOT;

//SDK版本信息
@property (nonatomic, copy) NSString *SDK_Version;

//电池电压,电池剩余容量
@property (nonatomic, assign) NSInteger batteryVoltage;

//输入电压
@property (nonatomic, assign) NSInteger inputVoltage;

//设备温度
@property (nonatomic, assign) NSInteger equTemperature;

//CPU温度
@property (nonatomic, assign) NSInteger cpuTemperature;

//是否能连接上云
@property (nonatomic, assign) NSInteger isConnectCloud;

//北斗RD端口
@property (nonatomic, assign) NSInteger rdPort;

//北斗RD电压,RD电池剩余容量
@property (nonatomic, assign) NSInteger rdVoltage;

//北斗RD温度
@property (nonatomic, assign) NSInteger rdTemperature;

//北斗RD发送最小周期
@property (nonatomic, assign) NSInteger rdPeriod;

//北斗RD RSSI值
@property (nonatomic, assign) NSInteger rdRSSI;

//北斗RD卡号
@property (nonatomic, assign) NSInteger rdID;

#pragma mark -- F005、7105相关
//    防拆开关
@property (nonatomic, assign) NSInteger tamperSwitch;
//    防拆告警    1    23    23
@property (nonatomic, assign) NSInteger tamperAlarm;
//    门磁开关    1    24    24    0：关，1：开
@property (nonatomic, assign) NSInteger doorSensorSwitch;
//    门磁告警    1    25    25
@property (nonatomic, assign) NSInteger doorSensorAlarm;
//    水浸开关    1    26    26    0：关，1：开
@property (nonatomic, assign) NSInteger waterInvasionSwitch;
//    水浸告警    1    27    27
@property (nonatomic, assign) NSInteger waterInvasionAlarm;
//    烟雾开关    1    28    28    0：关，1：开
@property (nonatomic, assign) NSInteger smokeSwitch;
//    烟雾告警    1    29    29
@property (nonatomic, assign) NSInteger smokeAlarm;
//    求救告警    1    39    39    见告警类型，注2。
@property (nonatomic, assign) NSInteger sosAlarm;
//    求救发生时间    4    40    43
@property (nonatomic, assign) int32_t sosTime;
//    求救发生时间类型    1    44    44    0：同步到云平台的时间；1：北斗时间；2:GPS时间；3：GPS、北斗双模时间；4：开机运行累计时间；5：手机APP时间；其他：无效
@property (nonatomic, assign) NSInteger sosTimeType;
//    支持的端口编号    16    45    60    以单数表示，0表示无效，0X88表示无效端口
@property (nonatomic, strong) NSData *portNumber;
//    设备类型    2    61    62    设备类型
@property (nonatomic, assign) NSInteger equType;

#pragma mark --- 用于记录/查看的属性
//记录当前连接设备的macid,从CellsysBabyBluetoothManage对象取值
@property (nonatomic, copy) NSString *macid;

//采集时刻/动作时限 转换后的时间，方便时间的查看
@property (nonatomic, copy) NSString *timeDateFormatter;

//路由表设备时间   转换后的时间，方便时间的查看
@property (nonatomic, copy) NSString *equDateFormatter;


#pragma mark -- 云端设备MAC地址 转 WiFiMACData
+ (NSData *)convertHexStrToMACData:(NSString *)str;
#pragma mark -- WiFiMACData 转 云端设备MAC地址
+ (NSString *)stringMacIdWithMacIdData:(NSData *)wifiData;

//分包
- (NSArray *)convertDataToD010Array;

//组包，一帧数据
- (void)analyseData:(NSData *)data callBack:(CallBack)callBack;

#pragma mark -- 不区分监控量类型，数据解析
+ (CellsysBLEMsgBody *)analyseDataToCellsysBLEMsgBody:(NSData *)data;

#pragma mark -- F00E数据解析
+ (CellsysBLEMsgBody *)analyseF00EDataToComData:(NSData *)data;
#pragma mark -- 002F数据解析
#pragma mark -- 002F数据解析,返回CellsysBLEMsgBody
+ (CellsysBLEMsgBody *)analyse002FDataToComData:(NSData *)data;
+ (NSArray <CellsysBLEMsgBody *>*)analyse002FDataToComDataArr:(NSData *)data;
#pragma mark -- D011数据解析
+ (CellsysBLEMsgBody *)analyseD011DataToComData:(NSData *)data;
#pragma mark --D011数据解析,97字节，发送心跳包返回数据
+ (CellsysBLEMsgBody *)analyseD011BeatDataToComData:(NSData *)data;
+ (CellsysBLEMsgBody *)analyseD011F005DataToComData:(NSData *)data;

+ (NSData *)sendBeatData;

#pragma mark --- 设备间聊天发送位置消息封装
- (NSData *)getChatLocationData:(CLLocationCoordinate2D)coordinate userId:(NSString *)userId type:(NSInteger)type;

#pragma mark --- 向指挥机发送位置消息封装
- (NSData *)getCurLocationData:(CLLocationCoordinate2D)coordinate userId:(NSString *)userID type:(NSInteger)type;

#pragma mark --- 向指挥机发送标记位置消息封装
- (NSData *)getMarkerLocationData:(NSString *)type;

#pragma mark --- 向指挥机发送SOS消息封装
- (NSData *)getSOSData;

#pragma mark --- 向指挥机发送事件消息封装
- (NSData *)getEventLocationData:(NSString *)eventTypeId;

#pragma mark --- 发送个人名片
- (NSString *)getMemberCardData:(CellsysMember *)member;

#pragma mark --- 解析个人名片数据
- (CellsysMember *)getMemberObjWithContent:(NSString *)content;

#pragma mark -- 002F数据中的单个设备位置信息数据解析
- (CellsysBLEMsgBody *)analysEquDataToComData:(NSData *)data;

#pragma mark --- 向指挥机发送围栏警报消息封装
/**
字段名称    起始位置    长度（字节）    备注
orgId    0    4    组织Id
fenceId    4    4    围栏Id
userId    8    4    用户Id
latitude    12    4    纬度
longitude    16    4    经度
timeStamp    20    4    时间戳（秒）
ablitity    24    1    围栏Function
type    25    1    围栏类型
*/
+ (NSData *)getFenceEventDataWithRegion:(AMapGeoFenceRegion *)region type:(NSNumber *)type marker:(CellsysMarker *)marker;


#pragma mark --- ble、文本、语音通道
//sx1278-->文本通道:324   0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
+ (NSString *)isTextToInfo:(NSInteger)isText;

//sx1280-->语音通道:328   0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
+ (NSString *)isAudioToInfo:(NSInteger)isAudio;




@end

NS_ASSUME_NONNULL_END
