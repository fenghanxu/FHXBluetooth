//
//  FHXTabBarController.m
//  Navigation和TarBar
//
//  Created by 冯汉栩一体机 on 2018/7/13.
//  Copyright © 2018年 com.fenghanxu.demol. All rights reserved.
//

#import "FHXTabBarController.h"
//#import "FHXNavigationController.h"
//#import "Color.h"
//#import "UIColor+Hex.h"
//#import "UIImage+FHXImage.h"

@interface FHXTabBarController ()<UITabBarControllerDelegate>

@end

@implementation FHXTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.view.backgroundColor = [UIColor whiteColor];//设置tabbarVC的背景颜色
    
    [self.tabBar setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]]];//底部tabbar的背景颜色
    
    [self.tabBar setBarTintColor:[UIColor whiteColor]];//设置控件背景颜色
   
    [self.tabBar setShadowImage:[UIImage createImageWithColor:[UIColor whiteColor]]];//底部tabbar的顶部的线条颜色
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
}

//此方法用来设置是否让页面支持自动旋转屏幕，return YES既可以自动旋转屏幕。NO就不能自动旋转屏幕。
- (BOOL)shouldAutorotate {
    return NO;//不能自动旋转屏幕
}

/*
 UIInterfaceOrientationUnknown = 屏幕方向未知
 UIInterfaceOrientationPortrait = 向上正方向的竖屏
 UIInterfaceOrientationPortraitUpsideDown = 向下正方向的竖屏
 UIInterfaceOrientationLandscapeLeft = 向右旋转的横屏
 UIInterfaceOrientationLandscapeRight = 向左旋转的横屏
 */
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;//向上正方向的竖屏
}

#pragma mark - 添加一个子控制器
- (void)setUpOneChildViewController:(UIViewController *)vc image:(NSString *)imageName selectedImage:(NSString *)selectedImageName title:(NSString *)title{
    // 设置标题
    vc.tabBarItem.title = title;
    // 设置为选中的图片
    vc.tabBarItem.image = [[UIImage imageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置点击选中的图片
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    // 设置选中的文字颜色，字体
    [vc.tabBarItem setTitleTextAttributes:@{
                                            NSFontAttributeName : [UIFont systemFontOfSize:12],
                                            NSForegroundColorAttributeName : [Color theme]
                                           } forState:UIControlStateSelected];
    // 设置未选中的文字颜色，字体
    [vc.tabBarItem setTitleTextAttributes:@{
                                            NSFontAttributeName : [UIFont systemFontOfSize:12],
                                            NSForegroundColorAttributeName : [Color textBlank]
                                            } forState:UIControlStateNormal];
    
    // 选择对应的自定义导航栏
    FHXNavigationController *nav = [[FHXNavigationController alloc] initWithRootViewController:vc];
    // 把控制器添加到tabbar的list里面
    [self addChildViewController:nav];
}

// 该代理方法的作用就是点击tabbarItem的时候就会进来这个代理方法，如果返回：YES代表允许切换控制器，如果返回：NO不允许切换控制器
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (viewController == self.selectedViewController) {
        if (self.selectedIndex == 1) {
            NSLog(@"  ");
            return NO;
        }

    }
    return YES;

}

@end
