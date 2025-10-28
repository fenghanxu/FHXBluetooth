//
//  NewViewController.m
//  Frame
//
//  Created by Hao on 2022/8/29.
//

#import "NewViewController.h"
//#import "PlayerViewController.h"
//#import "AlbumDetailViewController.h"
//#import <NerdyUI/NerdyUI.h>
@interface NewViewController ()

@end

@implementation NewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    self.title = @"New";
    
//    UIButton *btn = [UIButton new];
//    btn.addTo(self.view).str(@"跳去Player").fnt(14).color([UIColor blackColor]).bgColor([UIColor redColor]).borderRadius(4).makeCons(^{
//        make.top.equal.view(self.view).constants(100);
//        make.centerX.equal.view(self.view);
//        make.width.equal.constants(200);
//        make.height.equal.constants(50);
//    }).onClick(^{
//        PlayerViewController *vc = [PlayerViewController new];
//        vc.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:vc animated:YES completion:^{
//            for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
//                NSLog(@"1 - %@",self.navigationController.viewControllers[i]);
//            }
//            NSMutableArray *tempMarr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//            [tempMarr addObject:[AlbumDetailViewController new]];
//            [self.navigationController setViewControllers:tempMarr animated:YES];
//
//            for (int i = 0; i < self.navigationController.viewControllers.count; i++) {
//                NSLog(@"2 - %@",self.navigationController.viewControllers[i]);
//            }
//        }];
//    });
    
}



@end
