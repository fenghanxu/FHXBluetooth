//
//  HomeViewController.m
//  Frame
//
//  Created by Hao on 2022/8/29.
//

#import "HomeViewController.h"
//#import "PlayerViewController.h"
//#import "AlbumDetailViewController.h"
//#import "LoginViewController.h"
//#import <NerdyUI/NerdyUI.h>
//#import "FHXHUD.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.title = @"Home";
    
//    UIButton *btn = [UIButton new];
//    btn.addTo(self.view).str(@"退出登录").fnt(14).color([UIColor blackColor]).bgColor([UIColor redColor]).borderRadius(4).makeCons(^{
//        make.top.equal.view(self.view).constants(100);
//        make.centerX.equal.view(self.view);
//        make.width.equal.constants(200);
//        make.height.equal.constants(50);
//    }).onClick(^{
//        [FHXHUD showChrysanthemumTime:0.5 finish:^{
//            [UIApplication sharedApplication].keyWindow.rootViewController = [LoginViewController new];
//        }];
//    });
    
}

@end


