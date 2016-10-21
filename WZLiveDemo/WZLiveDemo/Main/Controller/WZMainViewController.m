//
//  WZMainViewController.m
//  WZLiveDemo
//
//  Created by songbiwen on 2016/10/20.
//  Copyright © 2016年 songbiwen. All rights reserved.
//

#import "WZMainViewController.h"
#import "WZBroadcastListController.h" //直播列表
#import "WZCaptureViewController.h" //音频采集

@interface WZMainViewController ()
@end

@implementation WZMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"直播功能";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *playVideo = [[UIButton alloc] initWithFrame:CGRectMake(20, 100, WZScreenWidth - 40, 40)];
    [playVideo setTitle:@"直播列表" forState:UIControlStateNormal];
    playVideo.backgroundColor = [UIColor brownColor];
    [playVideo addTarget:self action:@selector(playVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playVideo];
    
    
    UIButton *videoVideo = [[UIButton alloc] initWithFrame:CGRectMake(20, 200, WZScreenWidth - 40, 40)];
    [videoVideo setTitle:@"音频采集" forState:UIControlStateNormal];
    videoVideo.backgroundColor = [UIColor brownColor];
    [videoVideo addTarget:self action:@selector(videoCaptureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoVideo];
    
}


/** 直播列表 */
- (void)playVideoAction {
    WZBroadcastListController *broadcastList = [[WZBroadcastListController alloc] init];
    [self.navigationController pushViewController:broadcastList animated:YES];
}


/** 音频采集 */
- (void)videoCaptureAction {
    WZCaptureViewController *captureVC =  [[WZCaptureViewController alloc] init];
    [self.navigationController pushViewController:captureVC animated:YES];
}
@end
