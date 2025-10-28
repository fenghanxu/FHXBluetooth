//
//  CellsysGeometry.m
//  cellsys
//
//  Created by 刘磊 on 2019/11/11.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import "CellsysGeometry.h"
#import "GeometryType.h"

@implementation CellsysGeometry

//CLLocationCoordinate2D(世界标准地理坐标 WGS-84) 转 CLLocation(中国国测局地理坐标 GCJ-02）
+ (CLLocation *)getCLLocationFromWGS84WithLongitude:(NSInteger)longitude latitude:(NSInteger)latitude{
    
    CLLocationDegrees lon  =  longitude;
    CLLocationDegrees  lat  =  latitude;
    lon = [[NSString stringWithFormat:@"%.6lf",lon/1000000] doubleValue];
    lat = [[NSString stringWithFormat:@"%.6lf",lat/1000000] doubleValue];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(lat, lon);
    //世界标准地理坐标（WGS-84） 转换成 中国国测局地理坐标 （GCJ-02）
    CLLocationCoordinate2D gcj02Coordinate = [JZLocationConverter wgs84ToGcj02:coordinate];
    //NSLog(@"%s,世界标准地理坐标（WGS-84） %f,%f",__func__,coordinate.longitude,coordinate.latitude);
    //NSLog(@"%s,中国国测局地理坐标（GCJ-02） %f,%f",__func__,gcj02Coordinate.longitude,gcj02Coordinate.latitude);
    
    //坐标：海拔高度：水平精度：垂直精度：时间戳：
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:gcj02Coordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:0 timestamp:[NSDate date]];
    

    return location;
    
}

//CLLocationCoordinate2D 转 CellsysGeometry 中国国测局地理坐标 （GCJ-02）
+ (CellsysGeometry *)getGeometryFromCLLocationCoordinate2D:(CLLocationCoordinate2D)coordinate{
    CellsysGeometry *geometry = [[CellsysGeometry alloc] init];
    geometry.type = [GeometryType sharedGeometryType].marker;
    NSString *longitude = [NSString stringWithFormat:@"%.6lf",coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%.6lf",coordinate.latitude];
    
    geometry.coordinates = [NSArray arrayWithObjects:longitude,latitude, nil];
    return geometry;
}



//CellsysGeometry 转 CLLocationCoordinate2D
+ (CLLocationCoordinate2D)getCLLocationCoordinate2DFromGeometry:(CellsysGeometry *)geometry{
    
    if ([geometry.type isEqualToString:[GeometryType sharedGeometryType].marker] || [geometry.type isEqualToString:[GeometryType sharedGeometryType].multiPoint]) {
             
        NSArray *coordinates = geometry.coordinates;
        CLLocationDegrees longitude  =  [coordinates[0] doubleValue];
        CLLocationDegrees  latitude  =  [coordinates[1] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        return coordinate;
             
    }else if ([geometry.type isEqualToString:[GeometryType sharedGeometryType].line]){
        
        NSArray *coordinates = geometry.coordinates;
        CLLocationCoordinate2D linePoints[coordinates.count];
        for (int i = 0; i < coordinates.count; i++) {
            linePoints[i].longitude = [coordinates[i][0] doubleValue];
            linePoints[i].latitude = [coordinates[i][1] doubleValue];
        }
        
        return linePoints[coordinates.count];
        
    }else if ([geometry.type isEqualToString:[GeometryType sharedGeometryType].multiLine]){
        
        NSArray *coordinates = [geometry.coordinates firstObject];
        CLLocationCoordinate2D linePoints[coordinates.count];
        for (int i = 0; i < coordinates.count; i++) {
            linePoints[i].longitude = [coordinates[i][0] doubleValue];
            linePoints[i].latitude = [coordinates[i][1] doubleValue];
        }
        
        return linePoints[coordinates.count];
             
    }else if ([geometry.type isEqualToString:[GeometryType sharedGeometryType].polygon]){
             
        NSArray *coordinates = [geometry.coordinates firstObject];
        CLLocationCoordinate2D polygonPoints[coordinates.count];
        for (int i = 0; i < coordinates.count; i++) {
            polygonPoints[i].longitude = [coordinates[i][0] doubleValue];
            polygonPoints[i].latitude = [coordinates[i][1] doubleValue];
        }
        
        return polygonPoints[coordinates.count];;
            
    }else if ([geometry.type isEqualToString:[GeometryType sharedGeometryType].multiPolygon]){
        
        NSArray *coordinates = [[geometry.coordinates firstObject] firstObject];
        CLLocationCoordinate2D polygonPoints[coordinates.count];
        for (int i = 0; i < coordinates.count; i++) {
            polygonPoints[i].longitude = [coordinates[i][0] doubleValue];
            polygonPoints[i].latitude = [coordinates[i][1] doubleValue];
        }
        
        return polygonPoints[coordinates.count];;
        
    }else{
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
        return coordinate;
    }
    


}


@end
