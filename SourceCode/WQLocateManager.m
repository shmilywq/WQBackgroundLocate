//
//  WQLocateManager.m
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 NotHY. All rights reserved.
//

#import "WQLocateManager.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "WQBackgroundLocate.h"
#import "WQLocateModel.h"

#define kUploadInfoTimeInterval 300.f //上传间隔
#define kWQLocMinFilter 1000.f // 最小更新距离
#define kWQDefaultSpeed (kWQLocMinFilter / kUploadInfoTimeInterval)

@interface WQLocateManager ()<AMapLocationManagerDelegate>

@property (nonatomic, strong) AMapLocationManager *locationManager; // 定位服务

@property (nonatomic, strong) NSTimer *uploadTimer; // 上传位置信息所用计时器

@property (nonatomic, strong) WQLocateModel *locateModel; // 定位信息

@property (nonatomic, strong) CLLocation *noReGeocodeLocation; // 无详细地址的定位信息

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

#pragma mark - Initialize

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpManager];
    }
    return self;
}

- (void)setUpManager
{
    [AMapServices sharedServices].apiKey = @"0ec9145e6373275e9e7d331750bb2241";
}

#pragma mark - Background Location
// 开启后台定位
- (void)startBackgroundLocationSever
{
    // 判断权限
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
        // 有权限,开始定位
        [self.locationManager startUpdatingLocation];
        // 上传数据计时器
        _uploadTimer = [NSTimer scheduledTimerWithTimeInterval:kUploadInfoTimeInterval target:self selector:@selector(uploadLocateInfoWhenTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_uploadTimer forMode:NSRunLoopCommonModes];
    } else {
        // 无定位权限,提示用户
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"打开定位开关" message:@"定位服务未开启，请点击“设置” > “位置” > “始终”，允许使用您的位置信息" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *trueAction = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        [alertController addAction:trueAction];
        
        [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}
// 结束后台定位
- (void)stopBackgroundLocationSever
{
    [self.uploadTimer invalidate];
    self.uploadTimer = nil;
    [self.locationManager stopUpdatingLocation];
}
// 收集定位信息
- (void)uploadLocateInfoWhenTimer
{
    if (!_locateModel) {
        [self uploadLocateInfoWithModel:_locateModel];
    }
}
- (void)uploadLocateInfoWithModel:(WQLocateModel *)model
{
    [self.pointsArr addObject:model];
}
#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    WQLog(@"定位信息location:{lat:%f; lon:%f; accuracy:%f} reGeocode:%@", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode);
    if (location.coordinate.latitude < 0 || location.coordinate.longitude < 0) {
        // 没有经纬度
        return;
    }
    if (!reGeocode) {
        _noReGeocodeLocation = location;
        return;
    } else {
        if (_noReGeocodeLocation) {
            // 上次有没有编码成功的定位点
            NSTimeInterval tempTime = [location.timestamp timeIntervalSinceDate:_noReGeocodeLocation.timestamp];
            if (tempTime < 2 || (location.coordinate.latitude == _noReGeocodeLocation.coordinate.latitude && location.coordinate.longitude == _noReGeocodeLocation.coordinate.longitude)) {
                _noReGeocodeLocation = nil;
            } else {
                // 地址不一样, 先上传上一次的点
                WQLocateModel *lastModel = [[WQLocateModel alloc] init];
                lastModel.longitude = location.coordinate.longitude;
                lastModel.latitude = location.coordinate.latitude;
                lastModel.address = reGeocode.formattedAddress;
                lastModel.timestamp = location.timestamp;
                [self uploadLocateInfoWithModel:lastModel];
            }
        }
    }
    // 和上一次上传定位的时间差
    NSTimeInterval timeInterVal = [location.timestamp timeIntervalSinceDate:_locateModel.timestamp];
    if (timeInterVal < 2) {
        return;
    }
    
    // 上传定位点
    _locateModel = nil;
    _locateModel = [[WQLocateModel alloc] init];
    _locateModel.longitude = location.coordinate.longitude;
    _locateModel.latitude = location.coordinate.latitude;
    _locateModel.address = reGeocode.formattedAddress;
    _locateModel.timestamp = location.timestamp;
    [self uploadLocateInfoWithModel:_locateModel];
    
    // 修改定位精度
    if (location.speed <= 0.f) {
        if (self.locationManager.distanceFilter != 100.f) {
            self.locationManager.distanceFilter = 100.f;
        }
    } else if (location.speed > 0.f && location.speed < kWQDefaultSpeed) {
        self.locationManager.distanceFilter = location.speed * kUploadInfoTimeInterval;
    } else {
        if (self.locationManager.distanceFilter != kWQLocMinFilter) {
            self.locationManager.distanceFilter = kWQLocMinFilter;
        }
    }
}

#pragma mark - LazyLoad
- (AMapLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc] init];
        [_locationManager setDelegate:self];
        //设置定位最小更新距离方法如下，单位米。当两次定位距离满足设置的最小更新距离时，SDK会返回符合要求的定位结果。
        _locationManager.distanceFilter = kWQLocMinFilter;
        //持续定位是否返回逆地理信息，默认NO。
        _locationManager.locatingWithReGeocode = YES;
        //设置期望定位精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //设置不允许系统暂停定位
        [_locationManager setPausesLocationUpdatesAutomatically:NO];
        //设置允许在后台定位
        [_locationManager setAllowsBackgroundLocationUpdates:YES];
        //如果需要持续定位返回逆地理编码信息，（自 V2.2.0版本起支持）需要做如下设置：
        [_locationManager setLocatingWithReGeocode:YES];
    }
    return _locationManager;
}
- (NSMutableArray *)pointsArr
{
    if (!_pointsArr) {
        _pointsArr = [NSMutableArray array];
    }
    return _pointsArr;
}

@end
