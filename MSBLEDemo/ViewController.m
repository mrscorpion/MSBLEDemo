//
//  ViewController.m
//  MSBLEDemo
//
//  Created by mr.scorpion on 16/4/17.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()
<
CBCentralManagerDelegate,
CBPeripheralDelegate
>
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral; // 扫描单个外设
@property (nonatomic, strong) NSArray *peripheralArr; // 外设数组
@property (nonatomic, strong) NSTimer *connectTimer;
@end

@implementation ViewController
#pragma mark - Setter and Getter
- (NSArray *)peripheralArr
{
    if (!_peripheralArr) {
        _peripheralArr = [[NSArray alloc] init];
    }
    return _peripheralArr;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 建立中心角色
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    // 扫描外设(discover)
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - Actions and Responds
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}

/*
 * 发现外设\周边
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"peripheral ---> %@", peripheral);
    // 扫描到了，进行过滤操作
//    if ([peripheral.name  isEqualToString:BLE_SERVICE_NAME]) {
        // 符合条件(多个外设)
        NSMutableArray *peripheralArrM = [NSMutableArray array];
        [peripheralArrM addObject:peripheral];
        self.peripheralArr = [peripheralArrM copy];
    
        // 符合条件，连接外设（一个中心设备可以同时连接多个周围的蓝牙设备）
        [self connect:peripheral];
//    }
}
/*
 * 连接外设
 */
- (BOOL)connect:(CBPeripheral *)peripheral
{
    NSLog(@"connect start");
    _peripheral = nil;
    
    [self.manager connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    
    //开一个定时器监控连接超时的情况
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(connectTimeout:) userInfo:peripheral repeats:NO];
    
    return YES;
}
/*
 * 连接超时
 */
- (void)connectTimeout:(NSTimer *)timer
{
    // 这里可以发出通知，外部监听，接着进行相应操作
    [self.connectTimer invalidate];
    self.connectTimer = nil;
}
/*
 * 当连接上某个蓝牙之后，CBCentralManager会通知代理处理
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Did connect to peripheral: %@", peripheral);
    // 停止时钟
    [self.connectTimer invalidate];
    self.connectTimer = nil;
    
    self.peripheral = peripheral;
    // 设置代理(以便获取信息进行通讯)，查找服务
    self.peripheral.delegate = self;
    [self.peripheral discoverServices:nil];
}
#pragma mark - 扫描外设中的服务和特征(Services & Characteristics)
/*
 * 发现服务
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"didDiscoverServices");
    
//    if (error)
//    {
//        NSLog(@"Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
//        if ([self.delegate respondsToSelector:@selector(DidNotifyFailConnectService:withPeripheral:error:)])
//            [self.delegate DidNotifyFailConnectService:nil withPeripheral:nil error:nil];
//        return;
//    }
    
    for (CBService *service in peripheral.services)
    {
        //发现服务
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]])
//        {
            // 查找特征
            NSLog(@"Service found with UUID: %@", service.UUID);
            [peripheral discoverCharacteristics:nil forService:service];
            break;
//        }
    }
}
/*
 * 发现特征
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if (error)
    {
        NSLog(@"Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
//        [self error];
        return;
    }
    
    NSLog(@"服务：%@",service.UUID);
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //发现特征
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"xxxxxxx"]]) {
            //监听特征
            NSLog(@"监听：%@",characteristic);
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

#pragma mark - 数据交互(explore & interact)[读写操作 (read & write)]
/*
 * 给蓝牙发数据（Data)
 */
- (void)writeData:(CBCharacteristic *)characteristic
{
    //    NSData *d2 = [[PBABluetoothDecode sharedManager] HexStringToNSData:@"0x02"];
    //    [self.peripheral writeValue:d2 forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}
/*
 * 处理蓝牙发过来的数据（Data)
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error updating value for characteristic %@ error: %@", characteristic.UUID, [error localizedDescription]);
//        self.error_b = BluetoothError_System;
//        [self error];
        return;
    }
    //    NSLog(@"收到的数据：%@",characteristic.value);
//    [self decodeData:characteristic.value];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
