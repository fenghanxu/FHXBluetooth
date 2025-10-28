//
//  GeometryType.m
//  cellsys
//
//  Created by 刘磊 on 2019/11/13.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import "GeometryType.h"

@implementation GeometryType

// 静态单例对象
static GeometryType *_sharedGeometryType = nil;

+ (instancetype)sharedGeometryType {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedGeometryType = [[super allocWithZone:NULL] init];
    });
    return _sharedGeometryType;
}

- (NSString *)marker{
    return @"Point";
}

- (NSString *)multiPoint{
    return @"MultiPoint";
}

- (NSString *)line{
    return @"LineString";
}

- (NSString *)multiLine{
    return @"MultiLineString";
}

- (NSString *)multiPolygon{
    return @"MultiPolygon";
}

- (NSString *)polygon{
    return @"Polygon";
}


@end
