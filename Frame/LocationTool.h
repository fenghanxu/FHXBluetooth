//
//  LocationTool.h
//  Frame
//
//  Created by 冯汉栩 on 2025/9/23.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationTool : NSObject

Single_interface(LocationTool)

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) CLLocation *location;

@end

NS_ASSUME_NONNULL_END
