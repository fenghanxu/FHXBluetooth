//
//  BrowseViewController.m
//  Frame
//
//  Created by Hao on 2022/8/29.
//

#import "BrowseViewController.h"
#import "CellsysBLEClient.h"

@interface BrowseViewController ()<CellsysBLEClientDelegate>
@property (nonatomic, strong) NSMutableArray<CellsysMember *> *memberArr;
@end

@implementation BrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.title = @"Browse";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upadteMemberStatusFromNotification:) name:UpdateMemberStatus object:nil];
    
    [[CellsysBLEClient sharedManager] addDelegate:self];
    [[CellsysBLEClient sharedManager] startScanPeripheral];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [[CellsysBLEClient sharedManager] stopScanPeripheral];
    [[CellsysBLEClient sharedManager] removeDelegate:self];
    [SVProgressHUD dismiss];
}

- (void)upadteMemberStatusFromNotification:(NSNotification *)notification{
    NSMutableArray<CellsysMember *> *memberArr = notification.object;
    self.memberArr = memberArr;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView reloadData];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark CellsysBLEClientDelegate 代理回调
- (void)getScanResultPeripherals:(NSArray *)peripheralInfoArr {
//    CellsysMember *me = [[[CellsysDataManager sharedCellsysDataManager] queryWithTableName:CellsysMemberForm Class:[CellsysMember class] key:@"user_id" value:GetUserID] firstObject];
//    CellsysPeripheralInfo *info = [CellsysBLEClient verbCellsysPeripheralInfo:me.macid];
//    if (info.peripheral.state != CBPeripheralStateConnected && info) {
//        [[CellsysBLEClient sharedManager] stopScanPeripheral];
//        [[CellsysBLEClient sharedManager] connectPeripheral:info.peripheral];
//    }
}

- (void)connectSuccess:(CBPeripheral *)peripheral {
    NSLog(@"蓝牙连接成功");
}

- (void)connectFailed {
    NSLog(@"蓝牙连接失败");
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral {
    
}

@end

