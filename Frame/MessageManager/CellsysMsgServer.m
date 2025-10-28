//
//  CellsysMsgServer.m
//  Chat
//
//  Created by 刘磊 on 2021/3/23.
//

#import "CellsysMsgServer.h"

@interface CellsysMsgServer ()<CellsysBLEClientDelegate>
//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation CellsysMsgServer

+ (instancetype)sharedManager{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[CellsysBLEClient sharedManager] addDelegate:self];
    }
    return self;
}


#pragma mark - 添加代理
- (void)addDelegate:(id<CellsysMessageGeneratorDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}



#pragma mark - 移除代理
- (void)removeDelegate:(id<CellsysMessageGeneratorDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}


- (NSMutableArray *)delegates
{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}


#pragma mark - CellsysBLEClientDelegate,CellsysMQTTClientDelegate

- (void)handleMessageData:(id)msgBody {
    
    for (id<CellsysMsgServerDelegate>delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(handleMessageToCellsysMessageGenerator:)] ) {
            [delegate handleMessageToCellsysMessageGenerator:msgBody];
        }
    }
    
    
}



@end
