//
//  LocationTool.m
//  Frame
//
//  Created by 冯汉栩 on 2025/9/23.
//

#import "LocationTool.h"

@implementation LocationTool

Single_implementation(LocationTool)

- (instancetype)init {
    self = [super init];
    if (self) {
        // 直接使用广州坐标初始化
        CLLocationCoordinate2D guangzhouCoordinate = CLLocationCoordinate2DMake(23.132, 113.264);
        
        _coordinate = guangzhouCoordinate;
        _location = [[CLLocation alloc] initWithLatitude:guangzhouCoordinate.latitude
                                              longitude:guangzhouCoordinate.longitude];
    }
    return self;
}

#pragma mark - Setter方法重写

// 当coordinate被设置时，同步更新location
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
    _coordinate = coordinate;
    
    // 更新location属性
    _location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                          longitude:coordinate.longitude];
}

// 当location被设置时，同步更新coordinate
- (void)setLocation:(CLLocation *)location {
    _location = location;
    
    // 更新coordinate属性
    _coordinate = location.coordinate;
}

@end
