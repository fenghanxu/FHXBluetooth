//
//  CellsysMarker.h
//  cellsys
//
//  Created by LarryLiu on 2019/10/31.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CellsysGeometry.h"
#import "GeometryType.h"
#import "CellsysStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface CellsysMarker : CSArchiveBaseModel<NSMutableCopying,NSCopying>

#pragma mark --- 服务器字段

///标题
@property (nonatomic, copy) NSString *title;

/***/
@property (nonatomic, copy) NSString *markerId;

/***/
@property (nonatomic, copy) NSString *name;

/***/
@property (nonatomic, copy) NSString *org_id;

/**点线面要素类型ID*/
@property (nonatomic, copy) NSString *type;

/***/
@property (nonatomic, copy) NSString *org_name;

/***/
@property (nonatomic, copy) NSString *or_id;

/***/
@property (nonatomic, copy) NSDictionary *style;

/***/
@property (nonatomic, copy) NSString *status;

/***/
@property (nonatomic, copy) NSString *function;

/***/
@property (nonatomic, copy) NSString *geom_type;

/***/
@property (nonatomic, copy) NSDictionary *geometry;

/***/
@property (nonatomic, copy) NSString *type_name;

/***/
@property (nonatomic, copy) NSString *radius;

/***/
@property (nonatomic, copy) NSString *buffer_distance;

/**action，0表示不启用围栏，1表示进入围栏，2表示离开围栏，3表示长时间停在围栏里*/
@property (nonatomic, copy) NSString *action;

/***/
@property (nonatomic, copy) NSString *Description;

/***/
@property (nonatomic, copy) NSString *create_by;

/**创建时间*/
@property (nonatomic, copy) NSString *create_time;

/**更新时间*/
@property (nonatomic, copy) NSString *update_time;

/**用于展示的时间*/
@property (nonatomic, copy) NSString *datetime;

/***/
@property (nonatomic, copy) NSString *update_by;

/***/
@property (nonatomic, copy) NSString *type_description;


#pragma mark --- 本地字段

#pragma mark - 设备相关
/***/
@property (nonatomic, copy) NSString *macid;

#pragma mark - 人员位置相关
/***/
@property (nonatomic, copy) NSString *user_id;

/***/
@property (nonatomic, copy) NSString *group_id;

/***/
@property (nonatomic, copy) NSString *member_type;

/***/
@property (nonatomic, copy) NSString *realname;

/***/
@property (nonatomic, copy) NSString *mobile;


/**离线区域zip是否存在服务器*/
@property (nonatomic, copy) NSString *is_tile;


//本地标识在地图显示的要素类型，0未知、1点、2线、3面、4成员、5设备
@property (nonatomic, assign) NSInteger localMarkerType;

/**该属性用来管理本地数据的 增（Create）、删（Remove）、改（Update），后期同步云服务器*/
@property (nonatomic, copy) NSString *localEditType;

//是否同步服务器
@property (nonatomic, copy) NSString *isSynchronize;

/**本地字段，用来在APP界面展示*/
@property (nonatomic, copy) NSString *showTime;

//方向
@property (nonatomic, assign) double direction;


///***/
//@property (nonatomic, strong) NSArray *apps;


- (CellsysStyle *)toCellsysStyle;

- (CellsysGeometry *)toCellsysGeometry;

@end

NS_ASSUME_NONNULL_END
