//
//  CellsysGeometry.h
//  cellsys
//
//  Created by 刘磊 on 2019/11/11.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


NS_ASSUME_NONNULL_BEGIN

@interface CellsysGeometry : CSArchiveBaseModel


/***/
@property (nonatomic, copy) NSString *type;

/***/
@property (nonatomic, strong) NSArray *coordinates;

//CLLocationCoordinate2D(世界标准地理坐标 WGS-84) 转 CLLocation(中国国测局地理坐标 GCJ-02）
+ (CLLocation *)getCLLocationFromWGS84WithLongitude:(NSInteger)longitude latitude:(NSInteger)latitude;

//CLLocationCoordinate2D 转 CellsysGeometry 中国国测局地理坐标 （GCJ-02）
+ (CellsysGeometry *)getGeometryFromCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate;

//CellsysGeometry 转 CLLocationCoordinate2D   中国国测局地理坐标 （GCJ-02）
+ (CLLocationCoordinate2D)getCLLocationCoordinate2DFromGeometry:(CellsysGeometry *)geometry;



@end

NS_ASSUME_NONNULL_END
