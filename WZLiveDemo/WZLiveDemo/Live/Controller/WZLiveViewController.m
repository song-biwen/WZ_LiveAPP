//
//  WZLiveViewController.m
//  WZLiveDemo
//
//  Created by songbiwen on 2016/10/20.
//  Copyright © 2016年 songbiwen. All rights reserved.
//

#import "WZLiveViewController.h"
#import "WZLiveItem.h"
#import "WZCreatorItem.h"

@interface WZLiveViewController ()
@property (nonatomic, strong) IJKFFMoviePlayerController *plyerVC;
@end

@implementation WZLiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.liveItem.creator.nick;
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    // 设置直播占位图片
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",self.liveItem.creator.portrait]];
//    [imageView sd_setImageWithURL:imageUrl placeholderImage:nil];
    
    // 创建IJKFFMoviePlayerController：专门用来直播，传入拉流地址就好了
    IJKFFOptions *option = [IJKFFOptions optionsByDefault];
    self.plyerVC = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.liveItem.stream_addr] withOptions:option];
    
    self.plyerVC.view.frame = CGRectMake(0, 64, WZScreenWidth, WZScreenHeight - 64);
    [self.view addSubview:self.plyerVC.view];
    [self.plyerVC prepareToPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 界面消失，一定要记得停止播放
    [self.plyerVC pause];
    [self.plyerVC stop];
}

@end
