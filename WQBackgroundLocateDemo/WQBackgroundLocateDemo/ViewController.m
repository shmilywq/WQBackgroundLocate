//
//  ViewController.m
//  WQBackgroundLocateDemo
//
//  Created by shmily on 2017/8/10.
//  Copyright © 2017年 shmily. All rights reserved.
//

#import "ViewController.h"
#import "WQTrackViewController.h"
#import "WQLocateManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[WQLocateManager shareManager] startBackgroundLocationSever];
    [self setUpSubViews];
}

- (void)setUpSubViews
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"查看定位轨迹" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor blueColor];
    btn.frame = CGRectMake(100, 100, 100, 35);
    btn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [btn addTarget:self action:@selector(showTrackVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)showTrackVC
{
    WQTrackViewController *trackVC = [[WQTrackViewController alloc] init];
    trackVC.title = @"查看定位轨迹";
    [self.navigationController pushViewController:trackVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
