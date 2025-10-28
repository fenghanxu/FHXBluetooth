//
//  CellsysStyle.h
//  cellsys
//
//  Created by 刘磊 on 2019/11/15.
//  Copyright © 2019 LarryLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellsysStyle : CSArchiveBaseModel

///***/
@property (nonatomic, copy) NSString *iconId;

/***/
@property (nonatomic, copy) NSString *path;
/***/
@property (nonatomic, copy) NSString *strokeColor;//边框颜色

/***/
@property (nonatomic, copy) NSString *strokeOpacity;//边框透明度


/***/
@property (nonatomic, copy) NSString *fillColor;//填充颜色

/***/
@property (nonatomic, copy) NSString *fillOpacity;//填充透明度

/***/
@property (nonatomic, copy) NSString *weight;


/***/
@property (nonatomic, copy) NSString *name;

/***/
@property (nonatomic, copy) NSString *data;

/***/
@property (nonatomic, copy) NSString *rotate;

/***/
@property (nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
