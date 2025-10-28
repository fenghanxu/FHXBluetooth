//
//  GetVC.h
//  OCDemol
//
//  Created by 冯汉栩 on 2019/3/18.
//  Copyright © 2019年 com.fenghanxu.demol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetVC : NSObject

//获取跟控制器
+ (UIViewController *)getRootViewController;

//获取当前控制器
+ (UIViewController *)getCurrentViewController;

@end

NS_ASSUME_NONNULL_END
