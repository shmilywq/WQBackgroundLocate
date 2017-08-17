//
//  WQTrackViewController.m
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/11.
//  Copyright © 2017年 NotHY. All rights reserved.
//

#import "WQTrackViewController.h"
#import <MAMapKit/MAMapKit.h> 
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "WQLocateManager.h"
#import "WQLocateModel.h"

@interface WQTrackViewController () <MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView; // 地图

@property (nonatomic, strong) NSMutableArray *dataArr; // 定位数据


@end

@implementation WQTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpSubViews];
    self.dataArr = [NSMutableArray arrayWithArray:[WQLocateManager shareManager].pointsArr];
    [self setUpPinAnnotationViewAndPolyline];
}

#pragma mark - 地图处理
- (void)setUpPinAnnotationViewAndPolyline
{
    if (self.dataArr.count == 0) {
        return;
    }
    NSMutableArray *annotationArr = [NSMutableArray array];
    CLLocationCoordinate2D polylineCoordsArr[self.dataArr.count];
    WQLocateModel *model = self.dataArr[0];
    CLLocationDegrees firstLat = model.latitude;
    CLLocationDegrees firstLon = model.longitude;
    CLLocationDegrees maxLon = firstLon; // 最大经度
    CLLocationDegrees minLon = firstLon; // 最小经度
    CLLocationDegrees maxLat = firstLat; // 最大纬度
    CLLocationDegrees minLat = firstLat; // 最小纬度
    for (int i = 0; i < self.dataArr.count; i++) {
        WQLocateModel *model = self.dataArr[i];
        CLLocationDegrees latitude = model.latitude;
        CLLocationDegrees longitude = model.longitude;
        // 地图size
        maxLon = maxLon < longitude ? longitude : maxLon;
        minLon = minLon > longitude ? longitude : minLon;
        maxLat = maxLat < latitude ? latitude : maxLat;
        minLat = minLat > latitude ? latitude : minLat;
        // 大头针
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        pointAnnotation.title = model.address;
        [annotationArr addObject:pointAnnotation];
        // 折线
        polylineCoordsArr[i].latitude = latitude;
        polylineCoordsArr[i].longitude = longitude;
    }
    // 地图添加大头针
    [_mapView addAnnotations:annotationArr];
    // 构造折线对象
    MAPolyline *polyLine = [MAPolyline polylineWithCoordinates:polylineCoordsArr count:self.dataArr.count];
    // 地图添加折线
    [_mapView addOverlay:polyLine];
    // 修改地图中心点及范围
    CLLocationCoordinate2D centerPoint = CLLocationCoordinate2DMake((maxLat - minLat) / 2 + minLat, (maxLon - minLon) / 2 + minLon);
    MACoordinateSpan mapSize = MACoordinateSpanMake(maxLat - minLat, maxLon - minLon);
    MACoordinateRegion boundary = MACoordinateRegionMake(centerPoint, mapSize);
    MAMapRect mapRect = MAMapRectForCoordinateRegion(boundary);
    _mapView.visibleMapRect = mapRect;
    [_mapView setCenterCoordinate:centerPoint animated:YES];
}

#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"WQPointReuseIndentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth    = 2.f;
        polylineRenderer.strokeColor  = [UIColor redColor];
        polylineRenderer.lineJoin = kCGLineJoinRound;
        polylineRenderer.lineCap  = kCGLineCapRound;
        return polylineRenderer;
    }
    return nil;
}
#pragma mark - SubViews
- (void)setUpSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
}
#pragma mark - LazyLoad
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
