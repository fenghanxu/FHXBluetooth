//
//  GeometryType.h
//  cellsys
//
//  Created by 刘磊 on 2019/11/13.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeometryType : CSArchiveBaseModel

// 单例相关方法
+ (instancetype)sharedGeometryType;

/***/
@property (nonatomic, copy) NSString *marker;

/***/
@property (nonatomic, copy) NSString *multiPoint;

/***/
@property (nonatomic, copy) NSString *line;

/***/
@property (nonatomic, copy) NSString *multiLine;

/***/
@property (nonatomic, copy) NSString *polygon;

/***/
@property (nonatomic, copy) NSString *multiPolygon;


@end

NS_ASSUME_NONNULL_END
