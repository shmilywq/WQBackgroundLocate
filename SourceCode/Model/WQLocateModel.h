//
//  WQLocateModel.h
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 NotHY. All rights reserved.
//
/*
 * 定位信息model
 */
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface WQLocateModel : NSObject

@property (nonatomic, copy) NSString *address; // 地址描述
@property (nonatomic, assign) CLLocationDegrees longitude; // 经度
@property (nonatomic, assign) CLLocationDegrees latitude; // 纬度
@property (nonatomic, assign) CLLocationSpeed speed; // 速度
@property (nonatomic, strong) NSDate *timestamp; // 定位时间戳

@end
