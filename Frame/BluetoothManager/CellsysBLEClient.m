//
//  CellsysBLEClient.m
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import "CellsysBLEClient.h"

#define beatsInterval  60.0

@interface CellsysBLEClient ()<CBCentralManagerDelegate,CBPeripheralDelegate>

//所有的代理
@property (nonatomic, strong) NSMutableArray    *delegates;
//蓝牙管理器
@property (nonatomic, strong) CBCentralManager  *manager;
//订阅数据特征值
@property (nonatomic, strong) CBCharacteristic  *notifyCharacteristic;
//当前连接的外围设备
@property (nonatomic, strong) CBPeripheral      *currentPeripheral;

@property (nonatomic, strong) NSTimer           *timer;
@property (strong, nonatomic) dispatch_group_t  group;
@property (strong, nonatomic) dispatch_queue_t  queue;
@property (nonatomic, strong) CellsysBLEMsgBody *bleMsgBody;

@end

@implementation CellsysBLEClient

- (CellsysBLEMsgBody *)bleMsgBody{
    if (_bleMsgBody == nil) {
        _bleMsgBody = [[CellsysBLEMsgBody alloc] init];
    }
    return _bleMsgBody;
}

- (NSMutableArray *)delegates
{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

#pragma mark - 添加代理
- (void)addDelegate:(id<CellsysBLEClientDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

#pragma mark - 移除代理
- (void)removeDelegate:(id<CellsysBLEClientDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

- (NSMutableArray *)peripheralArr{
    if (!_peripheralArr) {
        _peripheralArr = [NSMutableArray array];
    }
    return _peripheralArr;
}

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
        [self initManager];
    }
    return self;
}

- (void)initManager{
    self.manager  = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) options:nil];
}

#pragma mark 对蓝牙操作
/// 蓝牙状态
- (void)systemBluetoothState:(CBManagerState)state  API_AVAILABLE(ios(10.0)) {
    if (state == CBManagerStatePoweredOn) {
        for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(sysytemBluetoothOpen)]) {
                [delegate sysytemBluetoothOpen];
            }
        }
        
        
    }else if (state == CBManagerStatePoweredOff) {
        for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
            
            if ([delegate respondsToSelector:@selector(systemBluetoothClose)]) {
                [delegate systemBluetoothClose];
            }
        }
    }else if (state == CBManagerStateUnauthorized){

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                           message:@"请求访问您的蓝牙，将用于连接空天设备"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }];
            
            [alert addAction:okAction];
            [[GetVC getCurrentViewController] presentViewController:alert animated:YES completion:nil];
        
        
    }
}

#pragma mark --- 开始扫描
- (void)startScanPeripheral{
    
//    if (self.currentPeripheral.state == CBPeripheralStateConnected) {
//        return;
//    }
    
    // 扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    //NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerRestoredStateScanOptionsKey:@(YES)};
    
    //CBUUID *cbuuid = [CBUUID UUIDWithString:serverUUIDString];
    //开始扫描周围的外设
    [self.manager scanForPeripheralsWithServices:nil options:scanForPeripheralsWithOptions];
}

#pragma mark --- 扫描到的设备[由block回主线程]
- (void)scanResultPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData rssi:(NSNumber *)RSSI {
    for (CellsysPeripheralInfo *peripheralInfo in self.peripheralArr) {
        if ([peripheralInfo.peripheral.identifier isEqual:peripheral.identifier]) {
            return;
        }
    }
    
    CellsysPeripheralInfo *peripheralInfo = [[CellsysPeripheralInfo alloc] init];
    peripheralInfo.peripheral = peripheral;
    peripheralInfo.advertisementData = advertisementData;
    peripheralInfo.RSSI = RSSI;
    [self.peripheralArr addObject:peripheralInfo];

    for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(getScanResultPeripherals:)]) {
            [delegate getScanResultPeripherals:[self.peripheralArr copy]];
        }
    }
    
}


#pragma mark --- 停止扫描
- (void)stopScanPeripheral {
    //[self.babyBluetooth cancelScan];
    [self.manager stopScan];
}


#pragma mark --- 连接设备
-(void)connectPeripheral:(CBPeripheral *)peripheral {
    
    NSArray<CBPeripheral *> *pers = [self getCurrentPeripherals];
    if ([pers containsObject:peripheral]) {
        return;
    }
    
    //断开之前的所有连接
    [self disconnectAllPeripherals];
    self.currentPeripheral = peripheral;
    
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    // 连接外围设备
    [self.manager connectPeripheral:peripheral options:connectOptions];

}

#pragma mark --- 重新连接设备
- (void)reconnectPeripheral:(CBPeripheral *)peripheral{
    [self connectPeripheral:peripheral];
}

#pragma mark --- 连接成功[由block回主线程]
- (void)connectSuccess:(CBPeripheral *)peripheral {
    for (CellsysPeripheralInfo *info in self.peripheralArr) {
        if ([info.peripheral isEqual:peripheral]) {
            self.currentPeripheralInfo = info;

            //蓝牙连接成功回调
            for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(connectSuccess:)]) {
                    [delegate connectSuccess:self.currentPeripheralInfo];
                }
            }
        }
    }
}


#pragma mark --- 连接失败[由block回主线程]
- (void)connectFailed{
    for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(connectFailed)]) {
            [delegate connectFailed];
        }
    }
}


#pragma mark --- 已断开设备的回调处理 [由block回主线程]
- (void)disconnectPeripheral:(CBPeripheral *)peripheral {

    [self.timer setFireDate:[NSDate distantFuture]];
    //[self cancelNotifyCharacteristic:peripheral characteristic:self.notifyCharacteristic];
    self.currentPeripheralInfo = [CellsysPeripheralInfo new];
    self.notifyCharacteristic = nil;
    //[self.babyBluetooth cancelNotify:self.currentPeripheral characteristic:self.notifyCharacteristic];
    for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(disconnectPeripheral:)]) {
            [delegate disconnectPeripheral:peripheral];
        }
    }
}


#pragma mark --- 获取当前连接
- (NSArray *)getCurrentPeripherals{
    CBUUID *cbuuid = [CBUUID UUIDWithString:serverUUIDString];
    NSArray<CBPeripheral *> *pers = [self.manager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:cbuuid]];
    return pers;
}


#pragma mark ---  断开所有连接
- (void)disconnectAllPeripherals {
    CBUUID *cbuuid = [CBUUID UUIDWithString:serverUUIDString];
    NSArray<CBPeripheral *> *pers = [self.manager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:cbuuid]];
    for (CBPeripheral *peripheral in pers) {
        [self.manager cancelPeripheralConnection:peripheral];
    }
}


#pragma mark --- 断开当前连接
- (void)disconnectLastPeripheral:(CBPeripheral *)peripheral {
    CBUUID *cbuuid = [CBUUID UUIDWithString:serverUUIDString];
    NSArray<CBPeripheral *> *pers = [self.manager retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:cbuuid]];
    for (CBPeripheral *peripheral in pers) {
        if ([peripheral isEqual:peripheral]) {
            [self.manager cancelPeripheralConnection:peripheral];
        }
    }
}

- (void)handleWriteBeatData:(NSTimer *)timer{
    if (self.currentPeripheral && self.notifyCharacteristic) {
        NSString *string = @"D010005D5E73177500018800F00C003C5E85E9C500020001320011138888252E888888888888888888880606C063CB0160C03388888888888801171B27819188888888888888888888000189AABBCCDDEEFF807D3ADAC4C3820100020000000065";
        NSData *beatData = [NSData convertHexStrToData:string];
        [self writeData:beatData];
    }
}

#pragma mark --- 发送数据
- (void)writeData:(NSData *)msgData{
    if (self.notifyCharacteristic == nil || msgData == nil) {
        NSLog(@"【CellsysBabyBluetooth】->数据发送失败");
        return;
    }
    
    CBCharacteristicProperties properties = self.notifyCharacteristic.properties;
    
    if (msgData.length == 97) {
        NSLog(@"writebeatData---notify:%@",msgData);
    }else{
        NSLog(@"write---notify:%@",msgData);
        
    }
    
    if (properties & CBCharacteristicPropertyWrite) {
        [self.currentPeripheral writeValue:msgData forCharacteristic:self.notifyCharacteristic type:CBCharacteristicWriteWithResponse];
    }
  
}

#pragma mark 对蓝牙操作CBCentralManager

//设置通知，setNotifyValue是写了一次之后，下次外设数据有更新就会回调下面的函数，类似socket请求，只要外设有推送数据过来就能收到数据。因此正常来说setNotifyValue只要写一次
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];

}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}


#pragma mark -- CBCentralManagerDelegate
//当蓝牙状态改变的时候就会调用这个方法
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    
    if (central.state == CBManagerStatePoweredOn) {
        for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(sysytemBluetoothOpen)]) {
                [delegate sysytemBluetoothOpen];
            }
        }
    }else if (central.state == CBManagerStatePoweredOff) {
        for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(systemBluetoothClose)]) {
                [delegate systemBluetoothClose];
            }
        }
    }else if (central.state == CBManagerStateUnauthorized){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        });
    }
    
//    typedef NS_ENUM(NSInteger, CBManagerState) {
//        CBManagerStateUnknown = 0,
//        CBManagerStateResetting,
//        CBManagerStateUnsupported,
//        CBManagerStateUnauthorized,
//        CBManagerStatePoweredOff,
//        CBManagerStatePoweredOn,
//    } NS_ENUM_AVAILABLE(10_13, 10_0);
    
    switch (central.state) {
        case CBManagerStateUnknown:
             //设备不支持的状态
            NSLog(@">>>CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            //正在重置状态
            NSLog(@">>>CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
             //设备不支持的状态
            NSLog(@">>>CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            // 设备未授权状态
            NSLog(@">>>CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            //设备关闭状态
            NSLog(@">>>CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@">>>CBManagerStatePoweredOn");
            break;
        default:
            break;
    }

}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
 *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"设备断开连接---%@,%@",peripheral,error);
    
    // 从block中取到值，再回到主线程
    [self disconnectPeripheral:peripheral];
    
    if (error) {
        NSLog(@"设备异常断开");
        [self reconnectPeripheral:peripheral];
        
        [[CellsysUserNotifications sharedInstance] speechAudioMessage:@"设备异常断开"];
        
        [CellsysUserNotifications addLocalNotificationWithTitle:@"温馨提示" subTitle:@"设备异常断开" body:@"" timeInterval:1 identifier:[NSDate getCurrentTimestamp13] userInfo:nil repeats:0 sound:NO];
        
    }else{
        
        [[CellsysUserNotifications sharedInstance] speechAudioMessage:@"设备连接已断开"];
        
        [CellsysUserNotifications addLocalNotificationWithTitle:@"温馨提示" subTitle:@"设备主动断开连接" body:@"" timeInterval:1 identifier:[NSDate getCurrentTimestamp13] userInfo:nil repeats:0 sound:NO];
        
    }
    
}

//连接到Peripherals-成功 //扫描外设中的服务和特征  连接上外围设备的时候会调用该方法
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    [self.manager stopScan];
    
    [[CellsysUserNotifications sharedInstance] speechAudioMessage:@"设备连接成功"];
    [CellsysUserNotifications addLocalNotificationWithTitle:@"温馨提示" subTitle:@"设备连接成功" body:@"" timeInterval:1 identifier:[NSDate getCurrentTimestamp13] userInfo:nil repeats:0 sound:NO];
    
    self.currentPeripheral = peripheral;
    [self connectSuccess:peripheral];
    //设置的peripheral委托CBPeripheralDelegate
    //@interface ViewController : UIViewController
    [peripheral setDelegate:self];
    //扫描外设Services，成功后会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //CBUUID *cbuuid = [CBUUID UUIDWithString:serverUUIDString];
    [peripheral discoverServices:nil];
    
}


//连接到Peripherals-失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self connectFailed];
    NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
    
    [[CellsysUserNotifications sharedInstance] speechAudioMessage:@"设备连接失败"];
    [CellsysUserNotifications addLocalNotificationWithTitle:@"温馨提示" subTitle:@"设备连接失败" body:@"" timeInterval:1 identifier:[NSDate getCurrentTimestamp13] userInfo:nil repeats:0 sound:NO];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"Discovered services for %@ ", peripheral.name);
    
    // 最常用的场景是查找某一个前缀开头的设备
    if (![peripheral.name containsString:kMyDevicePrefix] || peripheral.name == nil) {
        return;
    }
    
    for (CellsysPeripheralInfo *peripheralInfo in self.peripheralArr) {
        
        if ([peripheralInfo.peripheral.identifier isEqual:peripheral.identifier]) {
            return;
        }
        
    }
    
    NSString *macid = [self getMacidFromAdvertisementData:advertisementData];
    
    CellsysPeripheralInfo *peripheralInfo = [[CellsysPeripheralInfo alloc] init];
    peripheralInfo.peripheral = peripheral;
    peripheralInfo.advertisementData = advertisementData;
    peripheralInfo.RSSI = RSSI;
    peripheralInfo.macid = macid;
    
    [self.peripheralArr addObject:peripheralInfo];

    for (id<CellsysBLEClientDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(getScanResultPeripherals:)]) {
            [delegate getScanResultPeripherals:[self.peripheralArr copy]];
        }
    }
        
    NSLog(@"%@",peripheral);
   

}


#pragma mark -- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    NSLog(@"发现外围设备的服务");
    for (CBService *serivce in peripheral.services) {
        NSLog(@"====%@------%@+++++++",serivce.UUID.UUIDString,self.currentPeripheral.identifier);
        if ([serivce.UUID.UUIDString isEqualToString:serverUUIDString]) {
            // characteristicUUIDs : 可以指定想要扫描的特征(传nil,扫描所有的特征)
            [peripheral discoverCharacteristics:nil forService:serivce];
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    NSLog(@"发现外围设备的特征");

    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"====%@------+",characteristic.UUID.UUIDString);

        if ([characteristic.UUID.UUIDString isEqualToString:notifyUUIDString]) {
            // 拿到特征,和外围设备进行交互
            self.notifyCharacteristic = characteristic;
            
            //[peripheral readValueForCharacteristic:characteristic];
            
            if (characteristic.properties & CBCharacteristicPropertyNotify) {
                
                //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                
//                NSLog(@"dispatch_after");
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                    NSLog(@"dispatch_after");
//
//                });
                
                //[self  notifyCharacteristic:peripheral characteristic:characteristic];
                
            }
               
            
            [peripheral discoverDescriptorsForCharacteristic:characteristic];
            
        }
    }
    
    
}


/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral        The peripheral providing this information.
 *  @param characteristic    A <code>CBCharacteristic</code> object.
 *    @param error            If an error occurred, the cause of the failure.
 *
 *  @discussion                This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *                            they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"发现外围设备的特征的描述,%@",characteristic);
    
    
    
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        NSLog(@"====%@------+",descriptor);
        
//        Byte byte[] = {0x01,0x00};
//        NSData *beatData = [NSData dataWithBytes:byte length:sizeof(byte)];
        
        //[peripheral writeValue:beatData forDescriptor:descriptor];
        
        
    }
    
   
    
    
    

}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral        The peripheral providing this information.
 *  @param characteristic    A <code>CBCharacteristic</code> object.
 *    @param error            If an error occurred, the cause of the failure.
 *
 *  @discussion                This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"didWriteValueForCharacteristic --- %@",characteristic);
    //[self.currentPeripheral readValueForCharacteristic:characteristic];
    
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral        The peripheral providing this information.
 *  @param characteristic    A <code>CBCharacteristic</code> object.
 *    @param error            If an error occurred, the cause of the failure.
 *
 *  @discussion                This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    NSLog(@"didUpdateNotificationStateForCharacteristic --- %@",characteristic);
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
//        //取消发送心跳包数据
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//            if (self.timer) {
//                [self.timer setFireDate: [[NSDate date] dateByAddingTimeInterval:beatsInterval]];
//            }
//            else {
//                self.timer = [NSTimer timerWithTimeInterval:beatsInterval target:self selector:@selector(handleWriteBeatData:) userInfo:nil repeats:YES];
//                [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//                [[NSRunLoop currentRunLoop] run];
//
//            }
//        });
        
    } else {
        NSLog(@"取消订阅");
    }
    
    
}

#pragma mark --- 外设数据有更新就会回调下面的函数
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    //NSLog(@"收到蓝牙数据,%s---notify:%@",__func__,characteristic.value);
    
    if (characteristic.value) {
        
        [self analyseData:characteristic.value];
        
    }else{
        NSLog(@"收到空的蓝牙数据---notify");
    }
    
    
}


//组包
- (void)analyseData:(NSData *)valueData{
    
    //NSLog(@"读取数据:%@",valueData);
    //组一包数据，蓝牙每20字节一帧组成一包数据，有DO11、002F、F00E
    
    [self.bleMsgBody analyseData:valueData callBack:^(id  _Nullable success, NSError * _Nullable fail) {
        
        CellsysBLEMsgBody *bleMsgBody = (CellsysBLEMsgBody *)success;
        
        NSData *data = bleMsgBody.receiveData;
        
        CellsysBLEMsgBody *model = [CellsysBLEMsgBody analyseDataToCellsysBLEMsgBody:data];
        
        NSArray *delegates = [NSArray arrayWithArray:self.delegates];
        for (id <CellsysBLEClientDelegate> delegate in delegates) {
            if ([delegate respondsToSelector:@selector(handleMessageData:)] ) {
                [delegate handleMessageData:model];
            }
            
        }
  
    }];
 
}


- (NSString *)getMacidFromAdvertisementData:(NSDictionary *)advertisementData{
    NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    if (data.length > 6) {
        NSData *macidData = [data subdataWithRange:NSMakeRange(0, 6)];
        NSString *macid = [NSString convertDataToHexStr:macidData];
        macid = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",[macid substringWithRange:NSMakeRange(0, 2)].uppercaseString,[macid substringWithRange:NSMakeRange(2, 2)].uppercaseString,[macid substringWithRange:NSMakeRange(4, 2)].uppercaseString,[macid substringWithRange:NSMakeRange(6, 2)].uppercaseString,[macid substringWithRange:NSMakeRange(8, 2)].uppercaseString,[macid substringWithRange:NSMakeRange(10, 2)].uppercaseString];
        
        return macid;
    }else{
        return nil;
    }
}

#pragma mark --- 通过macid蓝牙检索设备，返回CellsysPeripheralInfo
+ (CellsysPeripheralInfo *)verbCellsysPeripheralInfo:(NSString *)macid{
    
    if (macid == nil || [CellsysBLEClient sharedManager].peripheralArr.count == 0) {
        return nil;
    }
    
    for (CellsysPeripheralInfo *info in [CellsysBLEClient sharedManager].peripheralArr) {
        if ([info.macid isEqualToString:macid]) {
            return info;
        }
    }
    return nil;
    
}

@end
