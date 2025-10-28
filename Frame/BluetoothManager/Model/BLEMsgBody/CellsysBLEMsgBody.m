#import "CellsysBLEMsgBody.h"


#define sendByteLength  35

@interface CellsysBLEMsgBody ()


//发送的当前包真实数据，每包97字节，数据51字节，真实数据44字节
@property (nonatomic, strong) NSData *curData;

//接受到的数据,蓝牙接收的20字节一组
@property (nonatomic, strong) NSData *curReceiveData;

//解析拼接数据
@property (nonatomic, strong) NSMutableData *mutData;

//当前监控量数据长度,发送数据用到
@property (nonatomic, assign) NSInteger curLength;

///监控量类型数组，有DO11、002F、F00E
//@property (nonatomic,strong) NSArray *dataTypeArr;


@end

@implementation CellsysBLEMsgBody
//记录当前连接设备的macid,从CellsysBabyBluetoothManage对象取值
- (NSString *)macid{
    return [CellsysBLEClient sharedManager].currentPeripheralInfo.macid;
}

//采集时刻/动作时限 转换后的时间，方便时间的查看
- (NSString *)timeDateFormatter{
    switch (self.timeType) {
        case 4:{
            return [NSString stringWithFormat:@"%d s",self.timeData];
        }
            break;
            
        default:{
            return [NSDate stringDateYMDHMSFromNSTimeInterval:self.timeData];
        }
            break;
    }
}

//路由表设备时间   转换后的时间，方便时间的查看
- (NSString *)equDateFormatter{
    switch (self.equTimeType) {
        case 4:{
            return [NSString stringWithFormat:@"%d s",self.equTime];
        }
            break;
            
        default:{
            return [NSDate stringDateYMDHMSFromNSTimeInterval:self.equTime];
        }
            break;
    }
}

- (id)copyWithZone:(NSZone *)zone {

    id obj = [[[self class] allocWithZone:zone] init];
    Class class = [self class];
    while (class != [NSObject class]) {
        unsigned int count;
        Ivar *ivar = class_copyIvarList(class, &count);
        for (int i = 0; i < count; i++) {
            Ivar iv = ivar[i];
            const char *name = ivar_getName(iv);
            NSString *strName = [NSString stringWithUTF8String:name];
            //利用KVC取值
            id value = [[self valueForKey:strName] copy];//如果还套了模型也要copy呢
            [obj setValue:value forKey:strName];
        }
        free(ivar);

        class = class_getSuperclass(class);//记住还要遍历父类的属性呢
    }
    return obj;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    
   id obj = [[[self class] allocWithZone:zone] init];
   Class class = [self class];
   while (class != [NSObject class]) {
       unsigned int count;
       Ivar *ivar = class_copyIvarList(class, &count);
       for (int i = 0; i < count; i++) {
           Ivar iv = ivar[i];
           const char *name = ivar_getName(iv);
           NSString *strName = [NSString stringWithUTF8String:name];
           //利用KVC取值
           id value = [[self valueForKey:strName] mutableCopy];//如果还套了模型也要copy呢
           [obj setValue:value forKey:strName];
       }
       free(ivar);

       class = class_getSuperclass(class);//记住还要遍历父类的属性呢
   }
   return obj;
    
}

//解析拼接数据
- (NSMutableData *)mutData{
    if (_mutData == nil) {
        _mutData = [NSMutableData data];
        
    }
    return _mutData;
}

#pragma mark -- D010数据分发

//分包
- (NSMutableArray *)convertDataToD010Array{
    
    NSMutableArray *mutArr = [NSMutableArray array];
    //计算需要分多少个包
    //如果数据不能被 dataL 整除，最后一个包需要多加一个包，因此 + 1 确保最后一个包的处理
    _countFrame = _sendMessageData.length/sendByteLength+1;

    //把当前时间作为内容id
    if (_contentId == nil) {
        long long conId = [[NSDate getCurrentTimestamp13] longLongValue];
        HTONLL(conId);
        NSData *contentId = [NSData dataWithBytes:&conId length:sizeof(conId)];
        contentId = [contentId subdataWithRange:NSMakeRange(4, 4)];//提取当前时间的一部分数据
        _contentId = [NSString convertDataToHexStr:contentId];
    }

    for (int i = 0; i < _countFrame; i++) {
        _currentFrame = i+1;//为什么要+1开始呢？因为_currentFrame=1，就只有一个包，只需要循环1次，但是如果从0开始就需要循环两次有出问题了
        if (_currentFrame == _countFrame) {//最后一个包
            //主要是截取包的剩余长度
            _curData = [_sendMessageData subdataWithRange:NSMakeRange(i*sendByteLength, _sendMessageData.length-i*sendByteLength)];
        }else{
            //一节一节截取发送
            _curData = [_sendMessageData subdataWithRange:NSMakeRange(i*sendByteLength, sendByteLength)];
        }
        //满载：一共97个字节 53个字节固定   44个字节是最大内容
        //每一包的数据封装成特定的格式，蓝牙协议要求
        //NSLog(@"_curData: %@",_curData);

        _sendData = [self dealDataToD010:_curData];
        //comData里面包含了（_sendData+时间戳）
        CellsysBLEMsgBody *comData = [self copy];
        
        [mutArr addObject:comData];
        
    }
    return mutArr;
    
}


//每一包的数据封装成D010的格式，   蓝牙协议要求   一共97个字节  D010(发送)
- (NSData *)dealDataToD010:(NSData *)contentData{
    //手机向设备发送，0xD010
    NSMutableData *mutData = [[NSMutableData alloc] init];

    //监控量类型,2字节，0-1     D010(发送)
    Byte byte[] = {0xD0,0x10};
    NSData *dataType = [NSData dataWithBytes:byte length:sizeof(byte)];
    _dataType = [NSString convertDataToHexStr:dataType];
    [mutData appendData:dataType];

    //监控量数据长度，2字节，2-3
    /*
     dataLength是怎么算出来的？dataLength就是要求出从“采集时刻/动作时限”到“CRC8”数据的长度，就是从下面的位置开始到结束位置的总长度
     注意：97是一个包发送的总长度： 4(监控量类型D010(2字节)和监控量数据长度(2字节)) + 49（固定长度） + 44(内容)
     注意：97-4-sendByteLength：就是除了  内容(44字节) 和 固定4个字节(监控量类型,2字节 + 监控量数据长度，2字节)的剩余长度
     注意：49个字节里面：D010封装固定字节只有占29个字节，还有20个固定字节在7801封装里面
     
     总结：实际公式改为如下的算法更加好：49 + [contentData length];  这样有个好处，如果包改为不是97个字(即：内容不是44个字节)，算法不用改97也会自动跟随变化
     */
//    int16_t dataLength = [contentData length] + 97-4-sendByteLength;//旧 44个字节
    //int16_t dataLength = [contentData length] + 88-4-sendByteLength;//旧 35个字节
    int16_t dataLength = 49 + [contentData length];//新 万能字节
    //16位整数 主机字节序(iOS使用小端序)转网络字节序（大端序）
    _dataLength = dataLength;
    HTONS(dataLength);
    [mutData appendBytes:&dataLength length:2];
    
    //采集时刻/动作时限，4字节，4-7
    int curDate = [[NSDate getCurrentTimestamp10] intValue];
    int32_t timeData = curDate;
    _timeData = timeData;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    //时间类型，1字节，8-8
    _timeType = 5;//5 手机App时间
    [mutData appendBytes:&_timeType length:1];
    
    //设置/读取，1字节，9-9
    _state = 37;//收发数据 0x25 37
    [mutData appendBytes:&_state length:1];
    
    //告警状态，1字节，10-10
    _errorState = 136; //该参数与手机端App无关 0x88
    [mutData appendBytes:&_errorState length:1];
    
    //紧急程度，1字节，11-11
    _adjective = 8;//0x08
    [mutData appendBytes:&_adjective length:1];
    
    //7801,12-75 (内容：要求封装成7801监控量格式)
    NSData *data7801 = [self add7801DataToD010:contentData];
    [mutData appendData:data7801];
    
    //发起者MAC，6字节， 76-81
    NSData *sendWifiMacData = [CellsysBLEMsgBody convertHexStrToMACData:_sendMAC];
    [mutData appendData:sendWifiMacData];
    
    //接受者MAC，6字节，  82-87
    NSData *acceptWifiMacData = [CellsysBLEMsgBody convertHexStrToMACData:_acceptMAC];
    [mutData appendData:acceptWifiMacData];
    
    //最初发出的端口(来自)，1字节,129代表使用BLE    88-88
    _sendPort = 129;//手机端App默认填0x81
    [mutData appendBytes:&_sendPort length:1];
    
    //数据类型（以前是[是否使用空天方法]），1字节,0：语音；1:视频；2：视频流；3：文本   89-89
    if (_contentType == 4) {
        //语音
        _equDataType = 0;
    }else{
        //文本
        _equDataType = 3;
    }
    [mutData appendBytes:&_equDataType length:1];

    //消息目的群组编号，2字节   90-91
    [mutData appendBytes:&_groupData length:2];
    
    //数据最终端口号(去),1字节，130代表使用BLE  92-92
    _receivePort = 130;//默认填0x82
    [mutData appendBytes:&_receivePort length:1];
    
    //操作序号,3字节，   93-95
    Byte operate[] = {0x00,0x00,0x00};
    NSData *operateData = [NSData dataWithBytes:operate length:sizeof(operate)];
    _operateData = operateData;
    [mutData appendData:operateData];
    
    //CRC8，1字节，  96-96
    NSString *crc8 = [NSString convertDataToHexStr:mutData];
    NSString *resCRC8 = [[self class] crc8_maxin_byteCheckWithHexString:crc8];
    NSData *crc8Data = [NSData convertHexStrToData:resCRC8];
    _crc8Data = crc8Data;
    [mutData appendData:crc8Data];
    
    //NSLog(@"D010:%s - %@",__func__,mutData);
    
    return [mutData copy];
}

// 发送聊天: 把内容封装到7801里面
- (NSData *)add7801DataToD010:(NSData *)contentData{
    
    //新增7801,12-75
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    //监控量类型,2字节，0-1   0x7801
    Byte byte[] = {0x78,0x01};
    NSData *dataType = [NSData dataWithBytes:byte length:sizeof(byte)];
    [mutData appendData:dataType];
    _monitorType = [NSString convertDataToHexStr:dataType];
    
    //监控量数据长度，2字节，2-3
    /*
     dataLength是怎么算出来的？dataLength就是要求出从“采集时刻/动作时限”到“CRC8”数据的长度，就是从下面的位置开始到结束位置的总长度
     为什么7801包的长度是：64 = 97(包总长度) - 4(监控量类型D010(2字节)和监控量数据长度(2字节)) - 29(D010封装监控量固定长度)
     64是一个7801包发送的总长度： 4(监控量类型D010(2字节)和监控量数据长度(2字节)) + 16（7801封装监控量固定长度） + 44(内容)
     
     总结：实际公式改为如下的算法更加好：4 + 16 + [contentData length];  这样有个好处，如果包改为不是64个字(即：内容不是44个字节)，算法不用改64也会自动跟随变化
     */
    //int16_t dataLength = [contentData length] + 64-4-sendByteLength;//旧的 44个字节
    //int16_t dataLength = [contentData length] + 55-4-sendByteLength;//旧的 35个字节
    int16_t dataLength = 16 + [contentData length];//新的 万能字节
    //16位整数 主机字节序(iOS使用小端序)转网络字节序（大端序）
    HTONS(dataLength);
    [mutData appendBytes:&dataLength length:2];
    
    //采集时刻/动作时限，4字节，4-7
    int curDate = [[NSDate getCurrentTimestamp10] intValue];
    int32_t timeData = curDate;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    //时间类型，1字节，8-8
    [mutData appendBytes:&_timeType length:1];
    
    //设置/读取，1字节，9-9
    [mutData appendBytes:&_state length:1];

    //告警状态，1字节，10-10
    [mutData appendBytes:&_errorState length:1];
    
    //紧急程度，1字节，11-11
    [mutData appendBytes:&_adjective length:1];
    
    //currentFrame，1字节  12-12
    [mutData appendBytes:&_currentFrame length:1];
    
    //countFrame，1字节  13-13
    [mutData appendBytes:&_countFrame length:1];
    
    //conentType， 1字节 14-14
    [mutData appendBytes:&_contentType length:1];
    
    //conentId，4字节 15-18
    NSData *conentIdData = [NSData convertHexStrToData:_contentId];
    [mutData appendData:conentIdData];
    
    //数据，44字节，19-62
    _contentData = contentData;
    [mutData appendData:contentData];
    
    //7801-CRC8，1字节，63-63
    NSString *crc8 = [NSString convertDataToHexStr:mutData];
    NSString *resCRC8 = [[self class] crc8_maxin_byteCheckWithHexString:crc8];
    NSData *crc8Data = [NSData convertHexStrToData:resCRC8];
    [mutData appendData:crc8Data];
    
    return [mutData copy];
}


#pragma mark -- D011数据解析,97字节，心跳包返回数据
+ (CellsysBLEMsgBody *)analyseD011BeatDataToComData:(NSData *)data{
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    
    model.receiveData = data;

    //监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType];
    
    //监控量数据长度，2字节
    NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
    int16_t dataLength;
    [lengthData getBytes:&dataLength length:lengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(dataLength);
    model.dataLength = dataLength;

    //采集时刻/动作时限，4字节
    NSData *curtimeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int32_t timeData;
    [curtimeData getBytes:&timeData length:curtimeData.length];
    NTOHL(timeData);
    model.timeData = timeData;
    
    //时间类型，1字节
    NSData *timeTypeData = [data subdataWithRange:NSMakeRange(8, 1)];
    unsigned char timeType;
    [timeTypeData getBytes:&timeType length:1];
    model.timeType = timeType;

    //设置/读取，1字节
    NSData *stateData = [data subdataWithRange:NSMakeRange(9, 1)];
    unsigned char state;
    [stateData getBytes:&state length:1];
    model.state = state;

    //告警状态，1字节
    NSData *errorStateData = [data subdataWithRange:NSMakeRange(10, 1)];
    unsigned char errorState;
    [errorStateData getBytes:&errorState length:1];
    model.errorState = errorState;

    //紧急程度，1字节
    NSData *adjectiveData = [data subdataWithRange:NSMakeRange(11, 1)];
    unsigned char adj;
    [adjectiveData getBytes:&adj length:1];
    model.adjective = adj;

    //二级监控量类型,2字节
    NSData *monitorType = [data subdataWithRange:NSMakeRange(12, 2)];
    model.monitorType = [NSString convertDataToHexStr:monitorType];

    //数据内容，64字节
    NSData *beatData = [data subdataWithRange:NSMakeRange(12, 64)];
    
    //F00C，经度
    NSData *longitudedata = [beatData subdataWithRange:NSMakeRange(13, 4)];
    int32_t longitude;
    [longitudedata getBytes:&longitude length:longitudedata.length];
    NTOHL(longitude);
    model.longitude = longitude;

    //纬度
    NSData *latitudedata = [beatData subdataWithRange:NSMakeRange(17, 4)];
    int32_t latitude;
    [latitudedata getBytes:&latitude length:latitudedata.length];
    NTOHL(latitude);
    model.latitude = latitude;
    
    int N = 64;

    //发起者MAC，6字节，"80:7d:3a:da:c4:c4"
    NSData *sendWifiMac = [data subdataWithRange:NSMakeRange(N+12, 6)];
    model.sendMAC = [[self class] stringMacIdWithMacIdData:sendWifiMac];
    
    //接受者MAC，6字节，"80:7d:3a:da:c1:b4"
    NSData *acceptWifiMAC = [data subdataWithRange:NSMakeRange(N+18, 6)];
    model.acceptMAC = [[self class] stringMacIdWithMacIdData:acceptWifiMAC];
    
    //发出的端口，1字节
    NSData *sendPortData = [data subdataWithRange:NSMakeRange(N+24, 1)];
    unsigned char sendPort;
    [sendPortData getBytes:&sendPort length:1];
    model.sendPort = sendPort;
    
    //硬件设备数据类型，1字节  0：语音；1:视频；2：视频流；3：文本
    NSData *equDataTypeData = [data subdataWithRange:NSMakeRange(N+25, 1)];
    unsigned char equDataType;
    [equDataTypeData getBytes:&equDataType length:1];
    model.equDataType = equDataType;

    //消息目的群组编号，2字节
    NSData *groupData = [data subdataWithRange:NSMakeRange(N+26, 2)];
    model.groupData = groupData;
    
    //数据最 终端口号，1字节
    NSData *spareData = [data subdataWithRange:NSMakeRange(N+28, 1)];
    unsigned char receivePort;
    [spareData getBytes:&receivePort length:1];
    model.receivePort = receivePort;
    
    //操作序号,3字节
    NSData *operateData = [data subdataWithRange:NSMakeRange(N+29, 3)];
    model.operateData = operateData;

    //CRC8，1字节
    NSData *crc8Data = [data subdataWithRange:NSMakeRange(N+32, 1)];
    model.crc8Data = crc8Data;

    return model;
}

#pragma mark -- D011数据解析,97字节，F005、7105求救
+ (CellsysBLEMsgBody *)analyseD011F005DataToComData:(NSData *)data{
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    
    model.receiveData = data;
    
    // 监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType];

    // 数据内容，64字节
    NSData *insideData = [data subdataWithRange:NSMakeRange(12, 64)];

    // 二级监控量类型,2字节
    NSData *monitorType = [insideData subdataWithRange:NSMakeRange(0, 2)];
    model.monitorType = [NSString convertDataToHexStr:monitorType];

    // 监控量数据长度，2字节
    NSData *lengthData = [insideData subdataWithRange:NSMakeRange(2, 2)];
    int16_t dataLength;
    [lengthData getBytes:&dataLength length:lengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(dataLength);
    model.dataLength = dataLength;

    // 采集时刻/动作时限，4字节
    NSData *curtimeData = [insideData subdataWithRange:NSMakeRange(4, 4)];
    int32_t timeData;
    [curtimeData getBytes:&timeData length:curtimeData.length];
    NTOHL(timeData);
    model.timeData = timeData;
    
    // 时间类型，1字节
    NSData *timeTypeData = [insideData subdataWithRange:NSMakeRange(8, 1)];
    unsigned char timeType;
    [timeTypeData getBytes:&timeType length:1];
    model.timeType = timeType;

    // 设置/读取，1字节
    NSData *stateData = [insideData subdataWithRange:NSMakeRange(9, 1)];
    unsigned char state;
    [stateData getBytes:&state length:1];
    model.state = state;
 
    // 告警状态，1字节
    NSData *errorStateData = [insideData subdataWithRange:NSMakeRange(10, 1)];
    unsigned char errorState;
    [errorStateData getBytes:&errorState length:1];
    model.errorState = errorState;

    // 紧急程度，1字节
    NSData *adjectiveData = [insideData subdataWithRange:NSMakeRange(11, 1)];
    unsigned char adj;
    [adjectiveData getBytes:&adj length:1];
    model.adjective = adj;

    // CPU温度    2字节    12    13    2位小数
    NSData *cpuTemperatureData = [insideData subdataWithRange:NSMakeRange(12, 2)];
    int16_t cpuTemperature;
    [cpuTemperatureData getBytes:&cpuTemperature length:cpuTemperatureData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(cpuTemperature);
    model.cpuTemperature = cpuTemperature;
    
    // 电池剩余容量    2字节    14    15    2位小数
    NSData *batteryVoltageData = [insideData subdataWithRange:NSMakeRange(14, 2)];
    int16_t batteryVoltage;
    [batteryVoltageData getBytes:&batteryVoltage length:batteryVoltageData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(batteryVoltage);
    model.batteryVoltage = batteryVoltage;
    
    // 输入电压    2字节    16    17    2位小数
    NSData *inputVoltageeData = [insideData subdataWithRange:NSMakeRange(16, 2)];
    int16_t inputVoltage;
    [inputVoltageeData getBytes:&inputVoltage length:inputVoltageeData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(inputVoltage);
    model.inputVoltage = inputVoltage;
    
    // 周边环境温度    2字节    18    19    2位小数
    NSData *temperatureData = [insideData subdataWithRange:NSMakeRange(18, 2)];
    int temperature;
    [temperatureData getBytes:&temperature length:4];
    NTOHS(temperature);
    model.temperature = temperature;
    
    // 周边环境湿度    2字节    20    21    2位小数
    NSData *humidityData = [insideData subdataWithRange:NSMakeRange(20, 2)];
    int32_t humidity;
    [humidityData getBytes:&humidity length:4];
    NTOHS(humidity);
    model.humidity = humidity;
    
    // 防拆开关    1字节    22    22    0：关，1：开
    NSData *tamperSwitchData = [insideData subdataWithRange:NSMakeRange(22, 1)];
    unsigned char tamperSwitch;
    [tamperSwitchData getBytes:&tamperSwitch length:1];
    model.tamperSwitch = tamperSwitch;
    
    // 防拆告警    1字节    23    23
    NSData *tamperAlarmData = [insideData subdataWithRange:NSMakeRange(23, 1)];
    unsigned char tamperAlarm;
    [tamperAlarmData getBytes:&tamperAlarm length:1];
    model.tamperAlarm = tamperAlarm;
    
    // 门磁开关    1字节    24    24    0：关，1：开
    NSData *tamperData = [insideData subdataWithRange:NSMakeRange(24, 1)];
    unsigned char doorSensorSwitch;
    [tamperData getBytes:&doorSensorSwitch length:1];
    model.doorSensorSwitch = doorSensorSwitch;
    
    // 门磁告警    1字节    25    25
    NSData *doorSensorAlarmData = [insideData subdataWithRange:NSMakeRange(25, 1)];
    unsigned char doorSensorAlarm;
    [doorSensorAlarmData getBytes:&doorSensorAlarm length:1];
    model.doorSensorAlarm = doorSensorAlarm;
    
    // 水浸开关    1字节    26    26    0：关，1：开
    NSData *waterInvasionSwitchData = [insideData subdataWithRange:NSMakeRange(26, 1)];
    unsigned char waterInvasionSwitch;
    [waterInvasionSwitchData getBytes:&waterInvasionSwitch length:1];
    model.waterInvasionSwitch = waterInvasionSwitch;
    
    // 水浸告警    1字节    27    27
    NSData *waterInvasionAlarmData = [insideData subdataWithRange:NSMakeRange(27, 1)];
    unsigned char waterInvasionAlarm;
    [waterInvasionAlarmData getBytes:&waterInvasionAlarm length:1];
    model.waterInvasionAlarm = waterInvasionAlarm;
    
    // 烟雾开关    1字节    28    28    0：关，1：开
    NSData *smokeSwitchData = [insideData subdataWithRange:NSMakeRange(28, 1)];
    unsigned char smokeSwitch;
    [smokeSwitchData getBytes:&smokeSwitch length:1];
    model.smokeSwitch = smokeSwitch;
    
    // 烟雾告警    1字节    29    29
    NSData *smokeAlarmData = [insideData subdataWithRange:NSMakeRange(29, 1)];
    unsigned char smokeAlarm;
    [smokeAlarmData getBytes:&smokeAlarm length:1];
    model.smokeAlarm = smokeAlarm;
    
    // 经纬度类型    1字节    30    30    1：北斗；2:GPS；3：GPS、北斗双定位；4：固化的北斗；5:固化的GPS；6：固化的GPS、北斗双定位；7：基站定位；10：固化的基站定位其他：无效。固化的即安装时设置的意思
    NSData *locationTypeData = [insideData subdataWithRange:NSMakeRange(30, 1)];
    unsigned char locationType;
    [locationTypeData getBytes:&locationType length:1];
    model.locationType = locationType;
    
    // 经度    4字节    31    34    6位小数，东经为正数，西经则为负数.
    NSData *longitudeData = [insideData subdataWithRange:NSMakeRange(31, 4)];
    int32_t longitude;
    [longitudeData getBytes:&longitude length:longitudeData.length];
    NTOHL(longitude);
    model.longitude = longitude;
    
    // 纬度    4字节    35    38    6位小数，北纬为负数，南纬则为负数.
    NSData *latitudeData = [insideData subdataWithRange:NSMakeRange(35, 4)];
    int32_t latitude;
    [latitudeData getBytes:&latitude length:latitudeData.length];
    NTOHL(latitude);
    model.latitude = latitude;
    
    // 求救告警 sosAlarm    1字节    39    39    见告警类型，注2。
    NSData *sosAlarmData = [insideData subdataWithRange:NSMakeRange(39, 1)];
    unsigned char sosAlarm;
    [sosAlarmData getBytes:&sosAlarm length:1];
    model.sosAlarm = sosAlarm;
    
    // 求救发生时间 sosTime   4字节    40    43
    NSData *sosTimeData = [insideData subdataWithRange:NSMakeRange(40, 4)];
    int32_t sosTime;
    [sosTimeData getBytes:&sosTime length:sosTimeData.length];
    NTOHL(sosTime);
    model.sosTime = sosTime;
    
    // 求救发生时间类型  sosTimeType  1字节    44    44    0：同步到云平台的时间；1：北斗时间；2:GPS时间；3：GPS、北斗双模时间；4：开机运行累计时间；5：手机APP时间；其他：无效
    NSData *sosTimeTypeData = [insideData subdataWithRange:NSMakeRange(44, 1)];
    unsigned char sosTimeType;
    [sosTimeTypeData getBytes:&sosTimeType length:1];
    model.sosTimeType = sosTimeType;
    
    // 支持的端口编号 portNumber   16字节    45    60    以单数表示，0表示无效，0X88表示无效端口
    NSData *portNumber = [insideData subdataWithRange:NSMakeRange(45, 16)];
    model.portNumber = portNumber;
    
    // 设备类型  equType  2字节    61    62    设备类型
    NSData *equTypeData = [insideData subdataWithRange:NSMakeRange(61, 2)];
    int32_t equType;
    [equTypeData getBytes:&equType length:4];
    NTOHS(equType);
    model.equType = equType;
    
    // 发起者MAC，6字节，"80:7d:3a:da:c4:c4"
    NSData *sendWifiMac = [data subdataWithRange:NSMakeRange(63+13, 6)];
    model.sendMAC = [[self class] stringMacIdWithMacIdData:sendWifiMac];
    
    // 接受者MAC，6字节，"80:7d:3a:da:c1:b4"
    NSData *acceptWifiMAC = [data subdataWithRange:NSMakeRange(69+13, 6)];
    model.acceptMAC = [[self class] stringMacIdWithMacIdData:acceptWifiMAC];
    
    // 发出的端口，1字节
    NSData *sendPortData = [data subdataWithRange:NSMakeRange(75+13, 1)];
    unsigned char sendPort;
    [sendPortData getBytes:&sendPort length:1];
    model.sendPort = sendPort;
    
    // 硬件设备数据类型，1字节  0：语音；1:视频；2：视频流；3：文本
    NSData *equDataTypeData = [data subdataWithRange:NSMakeRange(76+13, 1)];
    unsigned char equDataType;
    [equDataTypeData getBytes:&equDataType length:1];
    model.equDataType = equDataType;

    // 消息目的群组编号，2字节
    NSData *groupData = [data subdataWithRange:NSMakeRange(77+13, 2)];
    model.groupData = groupData;
    
    // 数据最 终端口号，1字节
    NSData *spareData = [data subdataWithRange:NSMakeRange(79+13, 1)];
    unsigned char receivePort;
    [spareData getBytes:&receivePort length:1];
    model.receivePort = receivePort;
    
    // 操作序号,3字节
    NSData *operateData = [data subdataWithRange:NSMakeRange(80+13, 3)];
    model.operateData = operateData;

    //CRC8，1字节
    NSData *crc8Data = [data subdataWithRange:NSMakeRange(83+13, 1)];
    model.crc8Data = crc8Data;

    return model;
}



#pragma mark -- (用于接收蓝牙数据 二进制-->模型 )D011数据解析,普通D011数据(嵌套7801),至多97字节，内容至多44个字节
+ (CellsysBLEMsgBody *)analyseD011DataToComData:(NSData *)data{
    
    //NSLog(@"收到D011数据%s---%@",__func__,data);
    //NSLog(@"收到:%@",data);
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    
    model.receiveData = data;

    //监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType];
    //NSLog(@"dataType: %@",dataType);
    
    //监控量D011数据长度，2字节
    NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
    int16_t dataLength;
    [lengthData getBytes:&dataLength length:lengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(dataLength);
    model.dataLength = dataLength;
    //NSLog(@"lengthData: %@",lengthData);

    //设置/读取，1字节
    NSData *stateData = [data subdataWithRange:NSMakeRange(9, 1)];
    unsigned char state;
    [stateData getBytes:&state length:1];
    model.state = state;
    //NSLog(@"stateData: %@",stateData);
    
    //告警状态，1字节
    NSData *errorStateData = [data subdataWithRange:NSMakeRange(10, 1)];
    unsigned char errorState;
    [errorStateData getBytes:&errorState length:1];
    model.errorState = errorState;
    //NSLog(@"errorStateData: %@",errorStateData);
    
    //紧急程度，1字节
    NSData *adjectiveData = [data subdataWithRange:NSMakeRange(11, 1)];
    unsigned char adj;
    [adjectiveData getBytes:&adj length:1];
    model.adjective = adj;
    //NSLog(@"adjectiveData: %@",adjectiveData);
    
    //二级监控量类型,2字节
    NSData *monitorType = [data subdataWithRange:NSMakeRange(12, 2)];
    model.monitorType = [NSString convertDataToHexStr:monitorType];
    //NSLog(@"monitorType: %@",monitorType);
    
    //监控量7801数据长度，2字节
    NSData *monitorLengthData = [data subdataWithRange:NSMakeRange(14, 2)];
    int16_t monitorDataLength;
    [monitorLengthData getBytes:&monitorDataLength length:monitorLengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(monitorDataLength);
    model.monitorDataLength = monitorDataLength;
    //NSLog(@"monitorLengthData: %@",monitorLengthData);
    
    //采集时刻/动作时限，4字节
    NSData *curtimeData = [data subdataWithRange:NSMakeRange(16, 4)];
    int32_t timeData;
    [curtimeData getBytes:&timeData length:curtimeData.length];
    NTOHL(timeData);
    model.timeData = timeData;
    //NSLog(@"curtimeData: %@",curtimeData);
    
    //时间类型，1字节
    NSData *timeTypeData = [data subdataWithRange:NSMakeRange(20, 1)];
    unsigned char timeType;
    [timeTypeData getBytes:&timeType length:1];
    model.timeType = timeType;
    //NSLog(@"timeTypeData: %@",timeTypeData);
    
    //currentFrame,1字节
    NSData *currentFrameData = [data subdataWithRange:NSMakeRange(24, 1)];
    unsigned char currentFrame;
    [currentFrameData getBytes:&currentFrame length:currentFrameData.length];
    model.currentFrame = currentFrame;
    //NSLog(@"currentFrameData: %@",currentFrameData);
    //NSLog(@"%c",currentFrame);
    
    //countFrame，1字节
    NSData *countFrameData = [data subdataWithRange:NSMakeRange(25, 1)];
    unsigned char countFrame;
    [countFrameData getBytes:&countFrame length:1];
    model.countFrame = countFrame;
    //NSLog(@"countFrameData: %@",countFrameData);
    
    //conentType，1字节
    NSData *conentTypeData = [data subdataWithRange:NSMakeRange(26, 1)];
    unsigned char conentType;
    [conentTypeData getBytes:&conentType length:1];
    model.contentType = conentType;
    //NSLog(@"conentTypeData: %@",conentTypeData);
    
    //conentId，4字节
    NSData *conentIdData = [data subdataWithRange:NSMakeRange(27, 4)];
    model.contentId = [NSString convertDataToHexStr:conentIdData];
    //NSLog(@"conentIdData: %@",conentIdData);
    
    //旧
    //model.monitorDataLength[二级监控量数据长度(7801)] - (60[二级监控量数据长度总长度] - sendByteLength[最多内容44字节])
    //实际上 (60[二级监控量数据长度总长度] - sendByteLength[最多内容44字节]) 就是等于  16
    //NSInteger conentLength = model.monitorDataLength - (60-sendByteLength);
    
    //新(2024.12.31)  测试接收25个包(需要20分钟）
    //二级监控量数据长度(7801) - 16(固定信息字节)
    NSInteger conentLength_0 = model.monitorDataLength - 16;
    //NSLog(@"conentLength_0: %ld",(long)conentLength_0);
    
    //数据，44字节
    NSData *curdata = [data subdataWithRange:NSMakeRange(31, conentLength_0)];
    model.contentData = curdata;
    //NSLog(@"curdata: %@",curdata);


    NSInteger N = model.dataLength + 4 - (21 + 12);
    //发起者MAC，6字节
    NSData *sendWifiMac = [data subdataWithRange:NSMakeRange(12+N, 6)];
    model.sendMAC = [[self class] stringMacIdWithMacIdData:sendWifiMac];
    //NSLog(@"sendWifiMac: %@",sendWifiMac);
    
    //接受者MAC，6字节
    NSData *acceptWifiMAC = [data subdataWithRange:NSMakeRange(18+N, 6)];
    model.acceptMAC = [[self class] stringMacIdWithMacIdData:acceptWifiMAC];
    //NSLog(@"acceptWifiMAC: %@",acceptWifiMAC);
    
    //发出的端口，1字节
    NSData *portNumData = [data subdataWithRange:NSMakeRange(24+N, 1)];
    unsigned char sendPort;
    [portNumData getBytes:&sendPort length:1];
    model.sendPort = sendPort;
    //NSLog(@"portNumData: %@",portNumData);
    
    //硬件设备数据类型，1字节,0：语音；1:视频；2：视频流；3：文本
    NSData *equDataTypeData = [data subdataWithRange:NSMakeRange(25+N, 1)];
    unsigned char equDataType;
    [equDataTypeData getBytes:&equDataType length:1];
    model.equDataType = equDataType;
    //NSLog(@"equDataTypeData: %@",equDataTypeData);
    
    //消息目的群组编号，2字节
    NSData *groupData = [data subdataWithRange:NSMakeRange(26+N, 2)];
    model.groupData = groupData;
    //NSLog(@"groupData: %@",groupData);
    
    //数据最终端口号，1字节
    NSData *spareData = [data subdataWithRange:NSMakeRange(28+N, 1)];
    unsigned char receivePort;
    [spareData getBytes:&receivePort length:1];
    model.receivePort = receivePort;
    //NSLog(@"spareData: %@",spareData);
    
    //操作序号,3字节
    NSData *operateData = [data subdataWithRange:NSMakeRange(29+N, 3)];
    model.operateData = operateData;
    //NSLog(@"operateData: %@",operateData);
    
    //CRC8，1字节
    NSData *crc8Data = [data subdataWithRange:NSMakeRange(32+N, 1)];
    model.crc8Data = crc8Data;
    //NSLog(@"crc8Data: %@",crc8Data);
    
//    NSLog(@"当前包数: %d",currentFrame);
//    NSLog(@"包总数: %d",countFrame);
//    NSLog(@"curdata 中文: %@",curdata.mj_JSONString);
    return model;
}

#pragma mark -- F00E数据解析
+ (CellsysBLEMsgBody *)analyseF00EDataToComData:(NSData *)data{
    //NSLog(@"收到F00E数据%s---%@",__func__,data);
    
    //NSLog(@"收到F00E数据%s---%@",__func__,[NSString convertDataToHexStr:data]);
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    
    model.receiveData = data;
    
    //监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType] ;
    
    //监控量数据长度，2字节
    NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
    int16_t dataLength;
    [lengthData getBytes:&dataLength length:lengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(dataLength);
    model.dataLength = dataLength;

    //采集时刻/动作时限，4字节
    NSData *curtimeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int32_t timeData;
    [curtimeData getBytes:&timeData length:curtimeData.length];
    NTOHL(timeData);
    model.timeData = timeData;
    
    //时间类型，1字节
    NSData *timeTypeData = [data subdataWithRange:NSMakeRange(8, 1)];
    unsigned char timeType;
    [timeTypeData getBytes:&timeType length:1];
    model.timeType = timeType;
    
    //设置/读取，1字节
    NSData *stateData = [data subdataWithRange:NSMakeRange(9, 1)];
    unsigned char state;
    [stateData getBytes:&state length:1];
    model.state = state;

    //告警状态，1字节
    NSData *errorStateData = [data subdataWithRange:NSMakeRange(10, 1)];
    unsigned char errorState;
    [errorStateData getBytes:&errorState length:1];
    model.errorState = errorState;
 
    //紧急程度，1字节
    NSData *adjectiveData = [data subdataWithRange:NSMakeRange(11, 1)];
    unsigned char adj;
    [adjectiveData getBytes:&adj length:1];
    model.adjective = adj;

    //经纬度类型，1字节
    NSData *locationTypeData = [data subdataWithRange:NSMakeRange(12, 1)];
    unsigned char locationType;
    [locationTypeData getBytes:&locationType length:1];
    model.locationType = locationType;

    //经度，4字节
    NSData *longitudeData = [data subdataWithRange:NSMakeRange(13, 4)];
    int32_t longitude;
    [longitudeData getBytes:&longitude length:longitudeData.length];
    NTOHL(longitude);
    model.longitude = longitude;
 
    //纬度，4字节
    NSData *latitudeData = [data subdataWithRange:NSMakeRange(17, 4)];
    int32_t latitude;
    [latitudeData getBytes:&latitude length:latitudeData.length];
    NTOHL(latitude);
    model.latitude = latitude;

    //高度，4字节
    NSData *altitudeData = [data subdataWithRange:NSMakeRange(21, 4)];
    int32_t altitude;
    [altitudeData getBytes:&altitude length:altitudeData.length];
    NTOHL(altitude);
    model.altitude = altitude;

    //是否GPS定位，0无效，1定位有效,1字节
    NSData *isLocationData = [data subdataWithRange:NSMakeRange(25, 1)];
    unsigned char isLocation;
    [isLocationData getBytes:&isLocation length:1];
    model.isLocation = isLocation;
    
    //本设备的时间
    NSData *equTimeData = [data subdataWithRange:NSMakeRange(26, 4)];
    int32_t equTime;
    [equTimeData getBytes:&equTime length:equTimeData.length];
    NTOHL(equTime);
    model.equTime = equTime;
    
    //时间类型，1字节
    NSData *equTimeTypeData = [data subdataWithRange:NSMakeRange(30, 1)];
    unsigned char equTimeType;
    [equTimeTypeData getBytes:&equTimeType length:1];
    model.equTimeType = equTimeType;
    
    //端口状态，512字节
    NSData *portState = [data subdataWithRange:NSMakeRange(31, 512)];
    model.portState = portState;
    
    //ble-->是否支持蓝牙连接:(130*4/2)+1
    NSData *isConnectBLEData = [portState subdataWithRange:NSMakeRange((130*4/2)+1, 1)];
    unsigned char isConnectBLE;
    [isConnectBLEData getBytes:&isConnectBLE length:1];
    model.isConnectBLE = isConnectBLE;
    
    //sx1278-->文本通道:(146*4/2)+1
    NSData *isTextData = [portState subdataWithRange:NSMakeRange((146*4/2)+1, 1)];
    unsigned char isText;
    [isTextData getBytes:&isText length:1];
    model.isText = isText;
    
    //sx1280-->语音通道:(148*4/2)+1
    NSData *isAudioData = [portState subdataWithRange:NSMakeRange((148*4/2)+1, 1)];
    unsigned char isAudio;
    [isAudioData getBytes:&isAudio length:1];
    model.isAudio = isAudio;
    
    NSData *isRDData = [portState subdataWithRange:NSMakeRange((184*4/2)+1, 1)];
    unsigned char isRD;
    [isRDData getBytes:&isRD length:1];
    model.isRD = isRD;
    
    NSData *isIOTData = [portState subdataWithRange:NSMakeRange((194*4/2)+1, 1)];
    unsigned char isIOT;
    [isIOTData getBytes:&isIOT length:1];
    model.isIOT = isIOT;

    //SDK版本信息
    NSData *sdkVersion1Data = [data subdataWithRange:NSMakeRange(543, 2)];
    int16_t sdkVersion1;
    [sdkVersion1Data getBytes:&sdkVersion1 length:sdkVersion1Data.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(sdkVersion1);
    
    NSData *sdkVersion2Data = [data subdataWithRange:NSMakeRange(545, 2)];
    int16_t sdkVersion2;
    [sdkVersion2Data getBytes:&sdkVersion2 length:sdkVersion2Data.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(sdkVersion2);
    
    model.SDK_Version = [NSString stringWithFormat:@"%d.%05d",sdkVersion1,sdkVersion2];
    //NSLog(@"收到F00E数据%s--SDK版本信息-%@%@",__func__,sdkVersion1Data,sdkVersion2Data);
    
    //电池电压，2字节
    NSData *batteryVoltageData = [data subdataWithRange:NSMakeRange(640, 2)];
    int16_t batteryVoltage;
    [batteryVoltageData getBytes:&batteryVoltage length:batteryVoltageData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(batteryVoltage);
    model.batteryVoltage = batteryVoltage;
    
    //核心板温度，2字节
    NSData *equTemperatureData = [data subdataWithRange:NSMakeRange(642, 2)];
    int16_t equTemperature;
    [equTemperatureData getBytes:&equTemperature length:equTemperatureData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(equTemperature);
    model.equTemperature = equTemperature;
    
    //RD端口
    NSData *rdPortData = [data subdataWithRange:NSMakeRange(646, 1)];
    unsigned char rdPort;
    [rdPortData getBytes:&rdPort length:1];
    model.rdPort = rdPort;
   
    
    //RD电压,RD电池剩余容量
    NSData *rdVoltageData = [data subdataWithRange:NSMakeRange(647, 2)];
    int16_t rdVoltage;
    [rdVoltageData getBytes:&rdVoltage length:rdVoltageData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(rdVoltage);
    model.rdVoltage = rdVoltage;
    
    //RD温度
    NSData *rdTemperatureData = [data subdataWithRange:NSMakeRange(649, 2)];
    int16_t rdTemperature;
    [rdTemperatureData getBytes:&rdTemperature length:rdTemperatureData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(rdTemperature);
    model.rdTemperature = rdTemperature;
    
    //rdPeriod,RD发送最小周期
    NSData *rdPeriodData = [data subdataWithRange:NSMakeRange(651, 2)];
    int16_t rdPeriod;
    [rdPeriodData getBytes:&rdPeriod length:rdPeriodData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(rdPeriod);
    model.rdPeriod = rdPeriod;
    
    //RD RSSI值
    NSData *rdRSSIData = [data subdataWithRange:NSMakeRange(653, 2)];
    int16_t rdRSSI;
    [rdRSSIData getBytes:&rdRSSI length:rdRSSIData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(rdRSSI);
    model.rdRSSI = rdRSSI;
    
    //RD卡号
    NSData *rdIDData = [data subdataWithRange:NSMakeRange(655, 4)];
    int32_t rdID;
    [rdIDData getBytes:&rdID length:rdIDData.length];
    NTOHL(rdID);
    model.rdID = rdID;
    
    NSLog(@"RD端口:%ld,RD电压:%ld,RD温度:%ld,RD发送最小周期:%ld,RD RSSI值:%ld,RD卡号:%ld",(long)model.rdPort,model.rdVoltage,model.rdTemperature,model.rdPeriod,model.rdRSSI,model.rdID);
    
    //CPU核心温度，2字节
    NSData *cpuTemperatureData = [data subdataWithRange:NSMakeRange(644, 2)];
    int16_t cpuTemperature;
    [cpuTemperatureData getBytes:&cpuTemperature length:cpuTemperatureData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(cpuTemperature);
    model.cpuTemperature = cpuTemperature;
    
    //是否能连接上云，1字节
    NSData *isConnectCloudData = [data subdataWithRange:NSMakeRange(896, 1)];
    unsigned char isConnectCloud;
    [isConnectCloudData getBytes:&isConnectCloud length:1];
    model.isConnectCloud = isConnectCloud;
    
    //CRC8，1字节
    NSData *crc8Data = [data subdataWithRange:NSMakeRange(1023, 1)];
    model.crc8Data = crc8Data;
    
    return model;
    
}
    

#pragma mark -- 不区分监控量类型，数据解析
+ (CellsysBLEMsgBody *)analyseDataToCellsysBLEMsgBody:(NSData *)data{
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    //完整数据
    model.receiveData = data;

    //监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType];
    
    if ([model.dataType isEqualToString:@"002f"] ) {//路由信息:(wifiMac, 经纬度, 时间)
        CellsysBLEMsgBody *comData = [CellsysBLEMsgBody analyse002FDataToComData:data];
        return comData;
    }
    else if([model.dataType isEqualToString:@"f00e"]) {// 电池电压, 主板温度
        CellsysBLEMsgBody *comData = [CellsysBLEMsgBody analyseF00EDataToComData:data];
        return comData;
    }
    else if([model.dataType isEqualToString:@"d011"]) {
        
        // 从0开始数到12，第十三个字节开始截取两个字节，上面的数据中两个数字是一个字节，4个数字是两个字节
        // <d011005d 5e731775 00018800 f00c003c 00000110 04888888 88888888 88888888 88000001 10048888 88880606 c063cb01 60c03388 88888888 8801171b 27819188 88888888 88888888 880001d0 807d3ada c4c3aabb ccddeeff 82010002 00000000 5d>
        
        //F00C -- 聊天内容
        NSData *dataType = [data subdataWithRange:NSMakeRange(12, 2)];
        NSString *subDataType = [NSString convertDataToHexStr:dataType];
        model.monitorType = subDataType;
        if ([subDataType isEqualToString:@"f00c"]) {
            CellsysBLEMsgBody *comData = [CellsysBLEMsgBody analyseD011BeatDataToComData:data];
            comData.monitorType = subDataType;
            return comData;
        }
        //FOO5、7105 -- SOS求救
        else if ([subDataType isEqualToString:@"f005"] || [subDataType isEqualToString:@"7105"]) {
            CellsysBLEMsgBody *comData = [CellsysBLEMsgBody analyseD011F005DataToComData:data];
            comData.monitorType = subDataType;
            return comData;
        }
        //D011，移动端消息
        else if ([subDataType isEqualToString:@"7801"]) {
            CellsysBLEMsgBody *comData = [CellsysBLEMsgBody analyseD011DataToComData:data];
            return comData;
        }else{
            return model;
        }
    }else{
        return model;
    }
 
}

#pragma mark -- 002F数据(路由信息)解析,返回CellsysBLEMsgBody
+ (CellsysBLEMsgBody *)analyse002FDataToComData:(NSData *)data{
    
    //NSLog(@"收到002F数据%s---%@",__func__,data);
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    
    model.receiveData = data;
    
    //监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType] ;
    
    //监控量数据长度，2字节
    NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
    int16_t dataLength;
    [lengthData getBytes:&dataLength length:lengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(dataLength);
    model.dataLength = dataLength;

    //采集时刻/动作时限，4字节
    NSData *curtimeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int32_t timeData;
    [curtimeData getBytes:&timeData length:curtimeData.length];
    NTOHL(timeData);
    model.timeData = timeData;
    
    //时间类型，1字节
    NSData *timeTypeData = [data subdataWithRange:NSMakeRange(8, 1)];
    unsigned char timeType;
    [timeTypeData getBytes:&timeType length:1];
    model.timeType = timeType;
    
    //设置/读取，1字节
    NSData *stateData = [data subdataWithRange:NSMakeRange(9, 1)];
    unsigned char state;
    [stateData getBytes:&state length:1];
    model.state = state;
        
    //告警状态，1字节
    NSData *errorStateData = [data subdataWithRange:NSMakeRange(10, 1)];
    unsigned char errorState;
    [errorStateData getBytes:&errorState length:1];
    model.errorState = errorState;
        
    //紧急程度，1字节
    NSData *adjectiveData = [data subdataWithRange:NSMakeRange(11, 1)];
    unsigned char adj;
    [adjectiveData getBytes:&adj length:1];
    model.adjective = adj;
    
    //周边设备数量，2字节
    NSData *equNumData = [data subdataWithRange:NSMakeRange(12, 2)];
    int16_t equNum;
    [equNumData getBytes:&equNum length:equNumData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(equNum);
    model.equNum = equNum;
    
    //路由表内容数据
    NSData *curdata = [data subdataWithRange:NSMakeRange(14, 24*model.equNum)];
    model.contentData = curdata;
    
    NSMutableArray *mutArr = [NSMutableArray array];
    for (int i = 0; i < model.equNum; i++) {
        
        NSData *equData = [data subdataWithRange:NSMakeRange(14 + i*24, 24)];
        
        CellsysBLEMsgBody *comData = [model analysEquDataToComData:equData];
        
        //CLLocationCoordinate2D(世界标准地理坐标 WGS-84) 转 CLLocation(中国国测局地理坐标 GCJ-02）
        CLLocation *location = [CellsysGeometry getCLLocationFromWGS84WithLongitude:comData.longitude latitude:comData.latitude];
        NSString *str = [NSString stringWithFormat:@"WifiMAC:%@,isLocation:%ld,longitude:%f,latitude:%f,timeInterval:%ld,acceptDataType:%ld,equTime:%d,equDateFormatter:%@",comData.equMAC,(long)comData.isLocation,location.coordinate.longitude,location.coordinate.latitude,(long)comData.timeInterval,(long)model.acceptDataType,model.equTime,model.equDateFormatter];
        
        [mutArr addObject:str];
        
    }
    
    model.equDataArr = [mutArr copy];
    
    //NSLog(@"%s,%@",__func__,equLocationStr);
    //NSLog(@"周边设备:%@",mutArr.mj_JSONObject);
    

    return model;
    
    
}


#pragma mark -- 002F数据解析,返回路由表数组
+ (NSArray <CellsysBLEMsgBody *>*)analyse002FDataToComDataArr:(NSData *)data{
    
    //NSLog(@"收到002F数据%s---%@",__func__,data);
    
    CellsysBLEMsgBody *model = [[CellsysBLEMsgBody alloc] init];
    
    model.receiveData = data;
    
    //监控量类型,2字节
    NSData *dataType = [data subdataWithRange:NSMakeRange(0, 2)];
    model.dataType = [NSString convertDataToHexStr:dataType] ;
    
    //监控量数据长度，2字节
    NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
    int16_t dataLength;
    [lengthData getBytes:&dataLength length:lengthData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(dataLength);
    model.dataLength = dataLength;

    //采集时刻/动作时限，4字节
    NSData *curtimeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int32_t timeData;
    [curtimeData getBytes:&timeData length:curtimeData.length];
    NTOHL(timeData);
    model.timeData = timeData;
    
    //时间类型，1字节
    NSData *timeTypeData = [data subdataWithRange:NSMakeRange(8, 1)];
    unsigned char timeType;
    [timeTypeData getBytes:&timeType length:1];
    model.timeType = timeType;
    
    //设置/读取，1字节
    NSData *stateData = [data subdataWithRange:NSMakeRange(9, 1)];
    unsigned char state;
    [stateData getBytes:&state length:1];
    model.state = state;
    
    
    //告警状态，1字节
    NSData *errorStateData = [data subdataWithRange:NSMakeRange(10, 1)];
    unsigned char errorState;
    [errorStateData getBytes:&errorState length:1];
    model.errorState = errorState;
    
    
    //紧急程度，1字节
    NSData *adjectiveData = [data subdataWithRange:NSMakeRange(11, 1)];
    unsigned char adj;
    [adjectiveData getBytes:&adj length:1];
    model.adjective = adj;
    
    //周边设备数量，2字节
    NSData *equNumData = [data subdataWithRange:NSMakeRange(12, 2)];
    int16_t equNum;
    [equNumData getBytes:&equNum length:equNumData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(equNum);
    model.equNum = equNum;
    
    
    NSMutableArray *mutArr = [NSMutableArray array];
    
    for (int i = 0; i < model.equNum; i++) {
        
        //路由表单个设备内容数据
        NSData *equData = [data subdataWithRange:NSMakeRange(14 + i*24, 24)];
        model.contentData = equData;
        
        CellsysBLEMsgBody *comData = [model analysEquDataToComData:equData];
        
        //CLLocationCoordinate2D(世界标准地理坐标 WGS-84) 转 CLLocation(中国国测局地理坐标 GCJ-02）
        //CLLocation *location = [CellsysGeometry getCLLocationFromWGS84WithLongitude:comData.longitude latitude:comData.latitude];
        //NSString *str = [NSString stringWithFormat:@"WifiMAC:%@,isLocation:%ld,longitude:%f,latitude:%f,timeInterval:%ld",comData.equMAC,(long)comData.isLocation,location.coordinate.longitude,location.coordinate.latitude,(long)comData.timeInterval];
        
        CellsysBLEMsgBody *comDataCopy = [comData copy];
        
        [mutArr addObject:comDataCopy];

        
    }
    
    //NSLog(@"%s,%@",__func__,equLocationStr);
    //NSLog(@"周边设备:%@",mutArr.mj_JSONObject);
    

    return mutArr;
    
    
}


#pragma mark -- 002F数据中的单个设备位置信息数据解析
- (CellsysBLEMsgBody *)analysEquDataToComData:(NSData *)data{
    
    
    //设备MAC，6字节，
    NSData *equWifiMAC = [data subdataWithRange:NSMakeRange(0, 6)];
    self.equMAC = [CellsysBLEMsgBody stringMacIdWithMacIdData:equWifiMAC];
    
    //经纬度类型，1字节
    NSData *locationTypeData = [data subdataWithRange:NSMakeRange(6, 1)];
    unsigned char locationType;
    [locationTypeData getBytes:&locationType length:1];
    self.locationType = locationType;
    
    
    //经度，4字节
    NSData *longitudeData = [data subdataWithRange:NSMakeRange(7, 4)];
    int32_t longitude;
    [longitudeData getBytes:&longitude length:longitudeData.length];
    NTOHL(longitude);
    self.longitude = longitude;
    
    
    //纬度，4字节
    NSData *latitudeData = [data subdataWithRange:NSMakeRange(11, 4)];
    int32_t latitude;
    [latitudeData getBytes:&latitude length:latitudeData.length];
    NTOHL(latitude);
    self.latitude = latitude;

    //高度，4字节
    NSData *altitudeData = [data subdataWithRange:NSMakeRange(15, 4)];
    int32_t altitude;
    [altitudeData getBytes:&altitude length:altitudeData.length];
    NTOHL(altitude);
    self.altitude = altitude;


    //是否定位，0无效，1定位有效,1字节
    NSData *isLocationData = [data subdataWithRange:NSMakeRange(19, 1)];
    unsigned char isLocation;
    [isLocationData getBytes:&isLocation length:1];
    self.isLocation = isLocation;
    

    //能接受信息的类型，1字节
    NSData *acceptDataTypeData = [data subdataWithRange:NSMakeRange(20, 1)];
    unsigned char acceptDataType;
    [acceptDataTypeData getBytes:&acceptDataType length:1];
    self.acceptDataType = acceptDataType;

    //最近一次通讯距离现在的时间差，单位：分钟，2字节
    Byte byte[] = {0x88,0x88};
    NSData *invalid = [NSData dataWithBytes:byte length:sizeof(byte)];
    
    //提取出从第 21 字节开始的 2 字节数据
    NSData *timeIntervalData = [data subdataWithRange:NSMakeRange(21, 2)];//假如：88
    //声明一个 16 位整数变量
    int16_t timeInterval;
    [timeIntervalData getBytes:&timeInterval length:timeIntervalData.length];
    // 16位整数 网络字节序转主机字节序(iOS使用小端序)
    NTOHS(timeInterval);
    self.timeInterval = timeInterval;//放入里面是：88
    
    return self;
    
    
    
    
    
}




#pragma mark -- 组一包数据，蓝牙每20字节一帧组成一包数据，有DO11、002F、F00E
//解析接收到的蓝牙数据，将每个数据包组装成完整的消息
- (void)analyseData:(NSData *)data callBack:(CallBack)callBack{
    
    //BLE是以每20个字节为一组发送数据给手机端接收，通过D011为开始拼接依据，以监控量长度为结束拼接依据
    self.curReceiveData = data;
    
    //截取接收回来的data前面的两个字节 目的:用来判断是否开始接收第一个20字节的数据,当前数据是否是头部
    NSData *curheader = [NSData data];
    if (data.length > 1) {
        curheader = [data subdataWithRange:NSMakeRange(0, 2)];
    }
    
    //创建DO11字段
    Byte byte_D011[] = {0xD0,0x11};
    NSData *header_d011 = [NSData dataWithBytes:byte_D011 length:2];
    
    //创建002F字段
    Byte byte_002F[] = {0x00,0x2F};
    NSData *header_002f = [NSData dataWithBytes:byte_002F length:2];
    
    //创建F00E字段
    Byte byte_F00E[] = {0xF0,0x0E};
    NSData *header_F00E = [NSData dataWithBytes:byte_F00E length:2];
    
    NSArray *dataTypeArr = [NSArray arrayWithObjects:header_d011,header_002f,header_F00E, nil];
    //检查数据头是否包含 （DO11、002F、F00E）这3个头部，有的话证明，开始第一次接收
    if ([dataTypeArr containsObject:curheader]) {//第一次
        
        //监控量数据长度，2字节
        //NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 2)];
        int16_t length;
        //获取数据长度
        [data getBytes:&length range:NSMakeRange(2, 2)];
        // 16位整数 网络字节序转主机字节序
        // 是为了确保在解析和使用从蓝牙设备接收到的监控量长度时，数据的字节序能够正确匹配当前系统的字节序，避免因字节序不匹配而导致的解析错误
        NTOHS(length);
        self.curLength = length;
        
        //监控量类型,D011、002F、F00E
        self.dataType = [NSString convertDataToHexStr:curheader];//NSData转NSString
        
        self.mutData = [NSMutableData data];
        //拼接数据
        [self.mutData appendData:data];
        // 加4的原因是：self.curLength只包含有效负载的数据长度 = 数据头(4) + 数据长度(有效负载长度)
        // 也就是前面开头的(D011、002F、F00E)没有包含在里面
        if (self.mutData.length >= self.curLength + 4) {
            self.receiveData = [self endAppendData:self.mutData];//结束组包
            self.curLength = 0;
            if (self.receiveData) {
                callBack(self,nil);
            }
        }
    }else{//非第一次
        if (self.curLength == 0) {
            return;
        }
        //拼接数据
        [self.mutData appendData:data];
        // 加4的原因是：self.curLength只包含有效负载的数据长度+数据头+数据长度
        if (self.mutData.length >= self.curLength +4) {
            self.receiveData = [self endAppendData:self.mutData];//结束组包
            self.curLength = 0;
            if (self.receiveData) {
                callBack(self,nil);
            }
        }
    }
    
}

//结束组包
- (NSData *)endAppendData:(NSData *)data{
    NSData *resultData = [self.mutData subdataWithRange:NSMakeRange(0, self.curLength+4)];
    //NSLog(@"收到一帧数据，%@",resultData);
    //校验包的完整性
    BOOL isResult =  [self verbCrc8_maxin_byteCheckWithNSData:resultData];
    if (isResult) {
        return resultData;
    }else{
        return nil;
    }
}

//用于 CRC8 校验，以验证数据包的完整性。这一校验是为了保证接收到的数据没有在传输过程中出错
- (BOOL)verbCrc8_maxin_byteCheckWithNSData:(NSData *)data{
    
    //提取的是完整数据最后一字节，作为CRC8 校验码
    NSData *verbCRC8 = [data subdataWithRange:NSMakeRange(data.length-1, 1)];
    NSString *crc8 = [NSString convertDataToHexStr:verbCRC8];// NSData转16进制

    //原始数据余数部分(意思就是不包含上面刚提取的最后一个字节)
    NSData *verbData = [data subdataWithRange:NSMakeRange(0, data.length-1)];
    NSString *verbStr = [NSString convertDataToHexStr:verbData];// NSData转16进制
    NSString *resCRC8 = [[self class] crc8_maxin_byteCheckWithHexString:verbStr];//进行CRC8校验

    if ([crc8 isEqualToString:resCRC8]) {
        NSLog(@"CRC8校验成功--数据:%@",data);
        return YES;
    }else{
        NSLog(@"CRC8校验失败--数据长度：%lu,校验前%@,校验后%@,数据:%@",(unsigned long)data.length,crc8,resCRC8,data);
        return NO;
    }
  
}

#pragma mark -- 云端设备MAC地址 转 WiFiMACData (BleMacID = WiFiMacID【末位】 + 2)
//蓝牙的地址跟Wi-Fi的地址是一样的，但是数据格式可能不一样，值是一样的，所以需要转换一下
+ (NSData *)convertHexStrToMACData:(NSString *)str{
    
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str = [str substringToIndex:12];
    if (str) {
        NSData *data = [NSData convertHexStrToData:str];
        Byte *byte = (Byte *)[data bytes];
        byte[5] -= 2;
        NSData *wifiData = [NSData dataWithBytes:byte length:6];
        return wifiData;
    }else{
        return nil;
    }
    
}

#pragma mark -- WiFiMACData 转 云端设备MAC地址 (BleMacID = WiFiMacID【末位】 + 2)
//蓝牙的地址跟Wi-Fi的地址是一样的，但是数据格式可能不一样，值是一样的，所以需要转换一下
+ (NSString *)stringMacIdWithMacIdData:(NSData *)wifiData{
    
    if (wifiData && wifiData.length > 5) {
        Byte *byte = (Byte *)[wifiData bytes];
        byte[5] += 2;
        NSData *macIdData = [NSData dataWithBytes:byte length:6];
        
        NSString *macId = [NSString convertDataToHexStr:macIdData];
        
        macId = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[macId substringWithRange:NSMakeRange(0, 2)].uppercaseString,[macId substringWithRange:NSMakeRange(2, 2)].uppercaseString,[macId substringWithRange:NSMakeRange(4, 2)].uppercaseString,[macId substringWithRange:NSMakeRange(6, 2)].uppercaseString,[macId substringWithRange:NSMakeRange(8, 2)].uppercaseString,[macId substringWithRange:NSMakeRange(10, 2)].uppercaseString];
        
        return macId;
    }else{
        return nil;
    }
 
}

#pragma mark--CRC8校验   用于校验传输值的完整行
+ (NSString *)crc8_maxin_byteCheckWithHexString:(NSString*)hexString {
//    NSString * tempStr = hexString;
    NSArray *tempArray = [self getByteForString:hexString];
//    NSArray  * tempArray = [tempStr componentsSeparatedByString:@" "];//分隔符
    unsigned char testChars[(int)tempArray.count];
    for(int i=0;i<tempArray.count;i++){
        NSString * string = tempArray[i];
        unsigned char fristChar = [self hexHighFromChar:[string characterAtIndex:0]];
        unsigned char lastChar  = [self hexLowFromChar:[string characterAtIndex:1]];
        unsigned char temp = fristChar+lastChar;
        testChars[i] = temp;
    }
    unsigned char res = [self crc8_maxin_checkWithChars:testChars length:(int)tempArray.count];
    NSString *resCRC8 = [NSString stringWithFormat:@"%x", res];
    if ([resCRC8 length] == 1) {
        resCRC8 = [NSString stringWithFormat:@"0%@",resCRC8];
    }
    //NSLog(@"CRC8校验,char:%c,string:%@",res,resCRC8);
    return resCRC8;
}

+(unsigned char)hexHighFromChar:(unsigned char) tempChar{
    unsigned char temp = 0x00;
    switch (tempChar) {
        case 'a':temp = 0xa0;break;
        case 'A':temp = 0xA0;break;
        case 'b':temp = 0xb0;break;
        case 'B':temp = 0xB0;break;
        case 'c':temp = 0xc0;break;
        case 'C':temp = 0xC0;break;
        case 'd':temp = 0xd0;break;
        case 'D':temp = 0xD0;break;
        case 'e':temp = 0xe0;break;
        case 'E':temp = 0xE0;break;
        case 'f':temp = 0xf0;break;
        case 'F':temp = 0xF0;break;
        case '1':temp = 0x10;break;
        case '2':temp = 0x20;break;
        case '3':temp = 0x30;break;
        case '4':temp = 0x40;break;
        case '5':temp = 0x50;break;
        case '6':temp = 0x60;break;
        case '7':temp = 0x70;break;
        case '8':temp = 0x80;break;
        case '9':temp = 0x90;break;
        default:temp = 0x00;break;
    }
    return temp;
}

+(unsigned char)hexLowFromChar:(unsigned char) tempChar{
    unsigned char temp = 0x00;
    switch (tempChar) {
            case 'a':temp = 0x0a;break;
            case 'A':temp = 0x0A;break;
            case 'b':temp = 0x0b;break;
            case 'B':temp = 0x0B;break;
            case 'c':temp = 0x0c;break;
            case 'C':temp = 0x0C;break;
            case 'd':temp = 0x0d;break;
            case 'D':temp = 0x0D;break;
            case 'e':temp = 0x0e;break;
            case 'E':temp = 0x0E;break;
            case 'f':temp = 0x0f;break;
            case 'F':temp = 0x0F;break;
            case '1':temp = 0x01;break;
            case '2':temp = 0x02;break;
            case '3':temp = 0x03;break;
        case '4':temp = 0x04;break;
            case '5':temp = 0x05;break;
            case '6':temp = 0x06;break;
            case '7':temp = 0x07;break;
            case '8':temp = 0x08;break;
            case '9':temp = 0x09;break;
            default:temp = 0x00;break;
            }
    return temp;
    
}

/**
 作用是计算输入字节数组的 CRC-8 校验值，具体是使用了一个特定的多项式（0x8C）进行计算。
 CRC（循环冗余校验）是一种用于检测数据传输或存储中的错误的常用算法。
 */
+(char)crc8_maxin_checkWithChars:(unsigned char *)chars length:(int)len{
    unsigned char i;
    unsigned char crc=0x00; /* 计算的初始crc值 */
    unsigned char *ptr = chars;
    while(len--){
        crc ^= *ptr++;
            for(i = 0;i < 8;i++)
                {
                    if(crc & 0x01){
                        crc = (crc >> 1) ^ 0x8C;
                    }else crc >>= 1;
                }
    }
    return crc;
}

//将一个十六进制字符串拆分成每两个字符一组的数组
/**
 例如：  @"D011002F"
 转换成
       @[@"D0", @"11", @"00", @"2F"]
 */
+ (NSArray *)getByteForString:(NSString *)string {
    NSMutableArray *strArr = [NSMutableArray array];
    for (int i = 0; i < string.length/2; i++) {
        NSString *str = [string substringWithRange:NSMakeRange(i * 2, 2)];
        [strArr addObject:str];
    }
    return [strArr copy];
}


#pragma mark -- F00C
+ (NSData *)sendBeatData{
    
    NSString *string = @"D010005D5E73177500018800F00C003C5E85E9C500020001320011138888252E888888888888888888880606C063CB0160C03388888888888801171B27819188888888888888888888000189AABBCCDDEEFF807D3ADAC4C3820100020000000065";
    
    NSData *data = [NSData convertHexStrToData:string];
    
    return data;
    
}


#pragma mark --- 设备间聊天发送位置消息封装
//将要发送的位置信息和相关的用户 ID 封装成二进制数据格式，以便通过蓝牙进行传输
- (NSData *)getChatLocationData:(CLLocationCoordinate2D)coordinate userId:(NSString *)userId type:(NSInteger)type{
    
    //CLLocationCoordinate2D coordinate = [LocationTool shareInstance].curLocation.coordinate;
    int lon = coordinate.longitude*1000000;
    int lat = coordinate.latitude*1000000;
    
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    NSInteger locType = type;
    [mutData appendBytes:&locType length:1];

    int32_t latitude = lat;
    HTONL(latitude);
    [mutData appendBytes:&latitude length:4];
    
    int32_t longitude = lon;
    HTONL(longitude);
    [mutData appendBytes:&longitude length:4];
    
    int32_t userid = [userId intValue];
    HTONL(userid);
    [mutData appendBytes:&userid length:4];
    
    return mutData;
    
}



#pragma mark --- 向指挥机/cloud发送位置消息封装
- (NSData *)getCurLocationData:(CLLocationCoordinate2D)coordinate userId:(NSString *)userId type:(NSInteger)type{
    
    //CLLocationCoordinate2D coordinate = [LocationTool shareInstance].curLocation.coordinate;
    int lon = coordinate.longitude*1000000;
    int lat = coordinate.latitude*1000000;
    
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    NSInteger locType = type;
    [mutData appendBytes:&locType length:1];
    
    int32_t latitude = lat;
    HTONL(latitude);
    [mutData appendBytes:&latitude length:4];
    
    int32_t longitude = lon;
    HTONL(longitude);
    [mutData appendBytes:&longitude length:4];
    
    int32_t userid = [userId intValue];
    HTONL(userid);
    [mutData appendBytes:&userid length:4];
    
    int curDate = [[NSDate getCurrentTimestamp10] intValue];
    int32_t timeData = curDate;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    return mutData;
    
}

#pragma mark --- 向指挥机发送标记位置消息封装
- (NSData *)getMarkerLocationData:(NSString *)type{
    
    // 广州的经纬度（约在天河体育中心附近）
    CLLocationCoordinate2D coordinate = [LocationTool sharedInstance].coordinate;
    
    int lon = coordinate.longitude*1000000;
    int lat = coordinate.latitude*1000000;
    
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    
    int32_t userId = [GetUserID intValue];
    HTONL(userId);
    [mutData appendBytes:&userId length:4];
    
    int32_t latitude = lat;
    HTONL(latitude);
    [mutData appendBytes:&latitude length:4];
    
    int32_t longitude = lon;
    HTONL(longitude);
    [mutData appendBytes:&longitude length:4];
    
    int32_t markerTypeID = [type intValue];
    HTONL(markerTypeID);
    [mutData appendBytes:&markerTypeID length:4];
    
    int curDate = [[NSDate getCurrentTimestamp10] intValue];
    int32_t timeData = curDate;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    return mutData;
    
}


#pragma mark --- 向指挥机发送SOS消息封装
- (NSData *)getSOSData{
    
    // 广州的经纬度（约在天河体育中心附近）
    CLLocationCoordinate2D coordinate = [LocationTool sharedInstance].coordinate;
    
    int lon = coordinate.longitude*1000000;
    int lat = coordinate.latitude*1000000;
    
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    
    int32_t userId = [GetUserID intValue];
    HTONL(userId);
    [mutData appendBytes:&userId length:4];
    
    int32_t latitude = lat;
    HTONL(latitude);
    [mutData appendBytes:&latitude length:4];
    
    int32_t longitude = lon;
    HTONL(longitude);
    [mutData appendBytes:&longitude length:4];
    
    int curDate = [[NSDate getCurrentTimestamp10] intValue];
    int32_t timeData = curDate;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    return mutData;
    
}

#pragma mark --- 向指挥机发送事件消息封装
- (NSData *)getEventLocationData:(NSString *)eventTypeId{

    // 广州的经纬度（约在天河体育中心附近）
    CLLocationCoordinate2D coordinate = [LocationTool sharedInstance].coordinate;
    
    int lon = coordinate.longitude*1000000;
    int lat = coordinate.latitude*1000000;
    
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    
    int32_t userId = [GetUserID intValue];
    HTONL(userId);
    [mutData appendBytes:&userId length:4];
    
    int32_t latitude = lat;
    HTONL(latitude);
    [mutData appendBytes:&latitude length:4];
    
    int32_t longitude = lon;
    HTONL(longitude);
    [mutData appendBytes:&longitude length:4];
    
    int32_t typeId = [eventTypeId intValue];
    HTONL(typeId);
    [mutData appendBytes:&typeId length:4];
    
    int curDate = [[NSDate getCurrentTimestamp10] intValue];
    int32_t timeData = curDate;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    return mutData;
    
}

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
+ (NSData *)getFenceEventDataWithRegion:(AMapGeoFenceRegion *)region type:(NSNumber *)type marker:(CellsysMarker *)marker{
    
    // 广州的经纬度（约在天河体育中心附近）
    CLLocationCoordinate2D coordinate = [LocationTool sharedInstance].coordinate;
    
    int lon = coordinate.longitude*1000000;
    int lat = coordinate.latitude*1000000;
    
    NSMutableData *mutData = [[NSMutableData alloc] init];
    
    int32_t orgId = [GetOrgID intValue];
    HTONL(orgId);
    [mutData appendBytes:&orgId length:4];
    
    int32_t fenceId = [marker.markerId intValue];
    HTONL(fenceId);
    [mutData appendBytes:&fenceId length:4];
    
    int32_t userId = [GetUserID intValue];
    HTONL(userId);
    [mutData appendBytes:&userId length:4];
    
    int32_t latitude = lat;
    HTONL(latitude);
    [mutData appendBytes:&latitude length:4];
    
    int32_t longitude = lon;
    HTONL(longitude);
    [mutData appendBytes:&longitude length:4];
    
    int32_t timeData = [[NSDate getCurrentTimestamp10] intValue];;
    HTONL(timeData);
    [mutData appendBytes:&timeData length:4];
    
    int32_t ablitity = (int32_t)region.fenceStatus;
    HTONL(ablitity);
    [mutData appendBytes:&ablitity length:4];
    
    int32_t typeId = [type intValue];
    HTONL(typeId);
    [mutData appendBytes:&typeId length:4];
    
    return mutData;
    
}

#pragma mark --- 发送个人名片(编码)
- (NSString *)getMemberCardData:(CellsysMember *)member{
    

    NSMutableData *mutData = [[NSMutableData alloc] init];

    //user_id
    long long userId = [member.user_id longLongValue];
    HTONLL(userId);
    NSData *userIdData = [NSData dataWithBytes:&userId length:sizeof(userId)];
    [mutData appendData:userIdData];
    //NSLog(@"%@",userIdData);
    
    //wifimacid
    NSData *sendWifiMacData = [CellsysBLEMsgBody convertHexStrToMACData:member.macid];
    [mutData appendData:sendWifiMacData];
    
    //realname
    NSData *realnameData = [member.mark dataUsingEncoding:NSUTF8StringEncoding];
    Byte *realnameByte = (Byte *)[realnameData bytes];
//    for(int i=0;i<[realnameData length];i++)
//    printf("realnameByte = %d\n",realnameByte[i]);
    [mutData appendBytes:realnameByte length:[realnameData length]];
    
    NSString *content = [NSString convertDataToHexStr:mutData];
    
    return content;
    
}

#pragma mark --- 解析个人名片数据
- (CellsysMember *)getMemberObjWithContent:(NSString *)content{
    if (content.length < 14) {
        return nil;
    }
    
    CellsysMember *member = [CellsysMember initWithCellMember];
    NSData *data = [NSData convertHexStrToData:content];
    
    NSData *userIdData = [data subdataWithRange:NSMakeRange(0, 8)];
    long userId;
    [userIdData getBytes:&userId length:8];
    NTOHLL(userId);
    member.user_id = [NSString stringWithFormat:@"%ld",userId];
    
    NSData *sendWifiMac = [data subdataWithRange:NSMakeRange(8, 6)];
    member.macid = [[self class] stringMacIdWithMacIdData:sendWifiMac];
    
    NSData *realnameData = [data subdataWithRange:NSMakeRange(14, [data length]-14)];
    member.mark = realnameData.mj_JSONString;
    
    return member;
    
}



#pragma mark -- D011数据中的单个传感设备数据解析
- (CellsysBLEMsgBody *)analysSensorEquDataToComData:(NSData *)data{
    
    //    byte[0] 经纬度类型
    NSData *locTypeData = [data subdataWithRange:NSMakeRange(0, 1)];
    unsigned char locationType;
    [locTypeData getBytes:&locationType length:1];
    //NSLog(@"%d",locationType);
    self.locationType = locationType;
        
    //    byte[1-4] 经度
    NSData *longitudedata = [data subdataWithRange:NSMakeRange(1, 4)];
    int32_t longitude;
    [longitudedata getBytes:&longitude length:4];
    NTOHL(longitude);
    //NSLog(@"%d",longitude);
    self.longitude = longitude;
        
    //    byte[5-8] 纬度
    //纬度
    NSData *latitudedata = [data subdataWithRange:NSMakeRange(5, 4)];
    int32_t latitude;
    [latitudedata getBytes:&latitude length:4];
    NTOHL(latitude);
    //NSLog(@"%d",longitude);
    self.latitude = latitude;
        
    //    byte[9-12] 采集时间
    NSData *timeData = [data subdataWithRange:NSMakeRange(9, 4)];
    int32_t createTime;
    [timeData getBytes:&createTime length:4];
    NTOHL(createTime);
    //NSLog(@"%d",createTime);
    self.equTime = createTime;
        
    //    byte[13-16] 温度
    NSData *temperatureData = [data subdataWithRange:NSMakeRange(13, 4)];
    int temperature;
    [temperatureData getBytes:&temperature length:4];
    NTOHL(temperature);
    //NSLog(@"%d",emTemperature);
    self.temperature = temperature;
    
        
    //    byte[17-20] 湿度
    NSData *humidityData = [data subdataWithRange:NSMakeRange(17, 4)];
    int32_t humidity;
    [humidityData getBytes:&humidity length:4];
    NTOHL(humidity);
    //NSLog(@"%d",humidity);
    self.humidity = humidity;
        
//        NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",(double)longitude/1000000];
//        NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",(double)latitude/1000000];
//
//        NSString *createtime = [NSString stringWithFormat:@"%d",createTime];
//        //NSString *createTimeStr = [NSDate stringDateFromTimestamp:createtime];
//
//        NSString *emTemperatureStr = [NSString stringWithFormat:@"%.1f",(double)emTemperature/10];
//        NSString *emHumidityStr = [NSString stringWithFormat:@"%.1f",(double)emHumidity/10];

    return self;
    
}

#pragma mark --- ble、文本、语音通道
//sx1278-->文本通道:324   0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
+ (NSString *)isTextToInfo:(NSInteger)isText{
    
    NSString *info = @"-";
    switch (isText) {
        case 0:
        {
            info = @"文本初始化进行中，请稍候";
        }
            break;
        case 1:
        {
            info = @"文本初始化成功";
        }
            break;
        case 3:
        {
            info = @"文本组网成功";
        }
            break;
        case 7:
        {
            info = @"文本组网成功,仅可接收";
        }
            break;
        case 11:
        {
            info = @"文本组网成功,仅可发送";
        }
            break;
        case 15:
        {
            info = @"恭喜您！文本组网成功";
        }
            break;
            
        default:
        {
            NSLog(@"文本通道，收到错误的值：%ld",isText);
        }
            break;
    }
    
    return info;
    
}

//sx1280-->语音通道:328   0：未初始化成功 1：初始化成功 3：初始化成功，组网成功、不可用 7、初始化成功、组网成功、可收  11、初始化成功、组网成功、可发  15、初始化成功、组网成功、可收发  其他数值可不做处理，错误数值
+ (NSString *)isAudioToInfo:(NSInteger)isAudio{
    
    NSString *info = @"-";
    switch (isAudio) {
        case 0:
        {
            info = @"语音初始化进行中，请稍候";
        }
            break;
        case 1:
        {
            info = @"语音初始化成功";
        }
            break;
        case 3:
        {
            info = @"语音组网成功";
        }
            break;
        case 7:
        {
            info = @"语音组网成功,仅可接收";
        }
            break;
        case 11:
        {
            info = @"语音组网成功,仅可发送";
        }
            break;
        case 15:
        {
            info = @"恭喜您！语音组网成功";
        }
            break;
            
        default:
        {
            NSLog(@"语音通道，收到错误的值：%ld",isAudio);
        }
            break;
    }
    
    return info;
    
}


@end
