//
//  CellsysBLEClient.h
//  Chat
//
//  Created by 刘磊 on 2021/3/17.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CellsysPeripheralInfo.h"
#import "CellsysBLEMsgBody.h"

@class CellsysBLEMsgBody;

NS_ASSUME_NONNULL_BEGIN

// 设置蓝牙的前缀【
#define kMyDevicePrefix  @"AIRKOON"

//外设的服务UUID值
#define serverUUIDString @"00FF"
//外设的写入UUID值
#define writeUUIDString  @"FF01"
//外设的读取UUID值
#define readUUIDString   @"FF01"
//外设的d订阅UUID值
#define notifyUUIDString @"FF01"


@protocol CellsysBLEClientDelegate <NSObject>

@optional

/**
 蓝牙被关闭
 */
- (void)systemBluetoothClose;


/**
 蓝牙已开启
 */
- (void)sysytemBluetoothOpen;


/**
 扫描到的设备回调
 
 @param peripheralInfoArr 扫描到的蓝牙设备数组
 */
- (void)getScanResultPeripherals:(NSArray *)peripheralInfoArr;


/**
 连接成功
 */
- (void)connectSuccess:(CellsysPeripheralInfo *)peripheralInfo;


/**
 连接失败
 */
- (void)connectFailed;


/**
 当前断开的设备
 
 @param peripheral 断开的peripheral信息
 */
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;


/**
 处理蓝牙数据

 */
//- (void)handleMessageData:(id)msgBody withMsgProtocolType:(MsgProtocolType)msgProtocolType;//旧
- (void)handleMessageData:(id)msgBody;


@end


@interface CellsysBLEClient : CSArchiveBaseModel


//扫描到的外设设备数组
@property (nonatomic, strong) NSMutableArray   *peripheralArr;

//当前连接的外设设备
@property (nonatomic, strong) CellsysPeripheralInfo *currentPeripheralInfo;

////当前连接的macid
//@property (nonatomic, copy) NSString  *macid;


/**
 单例
 
 @return 单例对象
 */
+ (CellsysBLEClient *)sharedManager;




//添加代理
- (void)addDelegate:(id<CellsysBLEClientDelegate>)delegate;
//移除代理
- (void)removeDelegate:(id<CellsysBLEClientDelegate>)delegate;

/**
 开始扫描周边蓝牙设备
 */
- (void)startScanPeripheral;


/**
 停止扫描
 */
- (void)stopScanPeripheral;


/**
 连接所选取的蓝牙外设
 
 @param peripheral 所选择蓝牙外设的perioheral
 */
-(void)connectPeripheral:(CBPeripheral *)peripheral;

#pragma mark --- 重新连接设备
- (void)reconnectPeripheral:(CBPeripheral *)peripheral;


/**
 获取当前连接成功的蓝牙设备数组
 
 @return 返回当前所连接成功蓝牙设备数组
 */
- (NSArray *)getCurrentPeripherals;



/**
 断开当前连接的所有蓝牙设备
 */
- (void)disconnectAllPeripherals;


/**
 断开所选择的蓝牙设备
 
 @param peripheral 所选择蓝牙外设的perioheral
 */
- (void)disconnectLastPeripheral:(CBPeripheral *)peripheral;

/**
 向蓝牙设备发送数据
 
 @param msgData 数据data值
 */

- (void)writeData:(NSData *)msgData;

#pragma mark --- 通过macid蓝牙检索设备，返回CellsysPeripheralInfo
+ (CellsysPeripheralInfo *)verbCellsysPeripheralInfo:(NSString *)macid;



@end

NS_ASSUME_NONNULL_END
