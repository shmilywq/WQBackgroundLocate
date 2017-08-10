//
//  WQLocateManager.h
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 shmily. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface WQLocateManager : NSObject

/**
 初始化单例对象

 @return 初始化结果
 */
+ (WQLocateManager *)shareManager;

/**
 启动百度地图的引擎,注:如果在其他地方已经启动了百度地图的引擎,这里可以不调用

 @param key      申请的有效key
 @param delegate 代理
 */
- (void)startBMKWithKey:(NSString *)key generalDelegate:(id<BMKGeneralDelegate>)delegate;


@end
