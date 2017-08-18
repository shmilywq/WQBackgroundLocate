//
//  WQLocateManager.h
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 NotHY. All rights reserved.
//
/*
 * 定位功能的管理者
 */

/*
 重点请看README文件
 */
#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>

@class WQLocateManager;

@interface WQLocateManager : NSObject

/**
  初始化单例对象
 */
+ (WQLocateManager *)shareManager;

/**
 开始后台定位
 */
- (void)startBackgroundLocationSever;

/**
 结束后台定位
 */
- (void)stopBackgroundLocationSever;

/**
 定位结果数组
 */
@property (nonatomic, strong) NSMutableArray *pointsArr;


@end
