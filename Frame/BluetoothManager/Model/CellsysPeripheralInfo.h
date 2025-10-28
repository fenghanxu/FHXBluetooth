//
//  CellsysPeripheralInfo.h
//  cellsys
//
//  Created by 刘磊 on 2020/6/2.
//  Copyright © 2020 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellsysPeripheralInfo : NSObject

//信号强度
@property (nonatomic, strong) NSNumber     *RSSI;
//设备
@property (nonatomic, strong) CBPeripheral *peripheral;
//广播数据
@property (nonatomic, strong) NSDictionary *advertisementData;

/**设备macid*/
@property (nonatomic, copy) NSString *macid;

@end

NS_ASSUME_NONNULL_END
