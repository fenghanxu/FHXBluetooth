//
//  OveralHeader.h
//  Frame
//
//  Created by 冯汉栩 on 2021/2/8.
//

#ifndef OveralHeader_h
#define OveralHeader_h

#define isSE ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPhone ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPhonePlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define IPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneXSMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone11 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1792, 828), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone11Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(2436, 1125), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone11ProMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(2688, 1242), [[UIScreen mainScreen] currentMode].size) : NO)


//这里用到的不外乎两种 1:用于设置高度 2:用于约束距离之外
//keyWindow
#define win [UIApplication sharedApplication].keyWindow
///状态栏的高度
#define statusHight [[UIApplication sharedApplication] statusBarFrame].size.height
///获取导航栏
#define navHight self.navigationController.navigationBar.frame.size.height
///是否是iphineX
#define isX statusHight > 20 ? YES : NO
///顶部安全距离
/*使用时注意  topSafeH 相加减要加括号 例如:Phone_Height - headerViewHeight - (topSafeH)*/
#define topSafeH statusHight + navHight
//底部安全距离
#define bottomSafeHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20.0?-34.0:0.0)
//底部安全距离 (正数)
#define positivesafeHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20.0?34.0:0.0)

//字符串为nil NuLL
#define NullString @""
//屏幕高度
#define Phone_Height [[UIScreen mainScreen] bounds].size.height
//屏幕宽度
#define Phone_Width [[UIScreen mainScreen] bounds].size.width
//tarBar+底部安全距离   加上tabbar
#define TabBarAndSafeHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?-83:-49) //底部tabbar高度
// 约束底部安全距离之上   加上tabbar
#define bottomSafeDistance ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)

#define navigationHeight 64

//#define iosVersion @"1.39"  //确认订单  保存订单  支付接口
//确认订单  保存订单  支付接口
#define iosVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]






#define GetUserID @"123456"

#define GetOrgID @"654321"

#define UpdateMemberStatus @"UpdateMemberStatus"

#endif /* OveralHeader_h */
