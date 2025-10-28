//
//  NSObject+CellsysObject.h
//  Frame
//
//  Created by 冯汉栩 on 2025/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CellsysObject)

/**
 *  判断对象是否为空
 *  常见的：nil、NSNil、@""、@(0) 以上4种返回YES
 *  如果需要判断字典与数组，可以自行添加
 *  @return YES 为空  NO 为实例对象
 */
+ (BOOL)isEmpty:(id)object;

@end

NS_ASSUME_NONNULL_END
