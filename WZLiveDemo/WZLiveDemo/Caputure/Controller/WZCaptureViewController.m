//
//  WZCaptureViewController.m
//  WZLiveDemo
//
//  Created by songbiwen on 2016/10/21.
//  Copyright © 2016年 songbiwen. All rights reserved.
//

#import "WZCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface WZCaptureViewController ()
<
    AVCaptureAudioDataOutputSampleBufferDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate
>
//创建捕获会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//创建对应视频输入对象
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
//创建对应音频输入对象
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;

//音频数据输出
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
//视频数据输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
//视频输入输出建立连接
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
//视频图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;

@property (nonatomic, weak) UIImageView *focusCursorImageView;

@end

@implementation WZCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"音频采集";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *toggleButton = [[UIButton alloc] initWithFrame:CGRectMake(WZScreenWidth -  40 - 40, 64, 40, 40)];
    [toggleButton setTitle:@"切换" forState:UIControlStateNormal];
    toggleButton.backgroundColor = [UIColor brownColor];
    [toggleButton addTarget:self action:@selector(toggleCaptureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toggleButton];
    
    [self setupCaptureVideo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.captureSession stopRunning];
}


/** 捕获音视频 */
- (void)setupCaptureVideo {
    //创建捕获会话，必须强引用
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    self.captureSession = captureSession;
    
    
    //创建视频设备
    AVCaptureDevice *videoDevice = [self getVideoDevice:AVCaptureDevicePositionFront];
    //创建对应视频输入对象
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    self.videoInput = videoInput;
    
    //创建音频设备
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //创建对应音频输入对象
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    self.audioInput = audioInput;
    
    //将视频添加到会话中
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    }
    
    //将音频添加到会话中
    if ([self.captureSession canAddInput:self.audioInput]) {
        [self.captureSession addInput:self.audioInput];
    }
    
    
    //获取音频数据输出
    AVCaptureAudioDataOutput *audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    dispatch_queue_t audioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    [audioOutput setSampleBufferDelegate:self queue:audioQueue];
    self.audioOutput = audioOutput;
    
    //获取视频数据输出
    AVCaptureVideoDataOutput *videoOuput = [[AVCaptureVideoDataOutput alloc] init];
    dispatch_queue_t videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    [videoOuput setSampleBufferDelegate:self queue:videoQueue];
    self.videoOutput = videoOuput;
    //获取视频输入与输出连接，用于分辨音视频数据
    self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //将视频数据添加到会话
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    
    //将音频数据添加到会话
    if ([self.captureSession canAddOutput:self.audioOutput]) {
        [self.captureSession addOutput:self.audioOutput];
    }
    
    // 添加视频预览图层
    AVCaptureVideoPreviewLayer *videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    videoLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:videoLayer atIndex:0];
    self.videoLayer = videoLayer;
    
    //启动会话
    [captureSession startRunning];
    
}

// 指定摄像头方向获取摄像头
- (AVCaptureDevice *)getVideoDevice:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}


#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (connection == self.videoConnection) {
        //视频输出
        WZLog(@"视频输出");
    }else {
        //音频输出
        WZLog(@"音频输出");
    }
}

/** 切换摄像头 */
- (void)toggleCaptureAction {
    //获取当前摄像头方向
    AVCaptureDevicePosition currentPosition = self.videoInput.device.position;
    //获取需要改变的方向
    AVCaptureDevicePosition togglePosition = currentPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    // 获取改变的摄像头设备
    AVCaptureDevice *currVideoDevice = [self getVideoDevice:togglePosition];
    // 获取改变的摄像头输入设备
    AVCaptureDeviceInput *currVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:currVideoDevice error:nil];
    // 移除之前摄像头输入设备
    [self.captureSession removeInput:self.videoInput];
    // 添加新的摄像头输入设备
    [self.captureSession addInput:currVideoInput];
    // 记录当前摄像头输入设备
    self.videoInput = currVideoInput;
}

// 点击屏幕，出现聚焦视图
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 获取点击位置
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    // 把当前位置转换为摄像头点上的位置
    CGPoint cameraPoint = [self.videoLayer captureDevicePointOfInterestForPoint:point];
    
    // 设置聚焦点光标位置
    [self setFocusCursorWithPoint:point];
    
    // 设置聚焦
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point{
    self.focusCursorImageView.center=point;
    self.focusCursorImageView.transform=CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursorImageView.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursorImageView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursorImageView.alpha=0;
        
    }];
}

/**
 *  设置聚焦
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    
    AVCaptureDevice *captureDevice = self.videoInput.device;
    // 锁定配置
    [captureDevice lockForConfiguration:nil];
    
    // 设置聚焦
    if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([captureDevice isFocusPointOfInterestSupported]) {
        [captureDevice setFocusPointOfInterest:point];
    }
    
    // 设置曝光
    if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    if ([captureDevice isExposurePointOfInterestSupported]) {
        [captureDevice setExposurePointOfInterest:point];
    }
    
    // 解锁配置
    [captureDevice unlockForConfiguration];
}

/**
 *  懒加载聚焦视图
 *
 */
- (UIImageView *)focusCursorImageView
{
    if (_focusCursorImageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"focus"]];
        _focusCursorImageView = imageView;
        [self.view addSubview:_focusCursorImageView];
    }
    return _focusCursorImageView;
}
@end
