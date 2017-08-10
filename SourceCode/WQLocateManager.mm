//
//  WQLocateManager.m
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 shmily. All rights reserved.
//

#import "WQLocateManager.h"
#import "WQBackgroundLocate.h"


@interface WQLocateManager () <BMKGeneralDelegate>

@property (nonatomic, strong) BMKMapManager *mapManager; // 百度地图引擎

@end

@implementation WQLocateManager

+ (WQLocateManager *)shareManager
{
    static WQLocateManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WQLocateManager alloc] init];
    });
    return manager;
}

- (void)startBMKWithKey:(NSString *)key generalDelegate:(id<BMKGeneralDelegate>)delegate
{
    _mapManager = [[BMKMapManager alloc] init];
    BOOL result = [self.mapManager start:key generalDelegate:self];
    if (!result) {
        WQLog(@"百度地图启动引擎失败");
    }
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        WQLog(@"百度地图联网成功");
    }
    else{
        WQLog(@"百度地图联网失败: %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        WQLog(@"百度地图授权成功");
    }
    else {
        WQLog(@"百度地图授权失败: %d",iError);
    }
}
@end
