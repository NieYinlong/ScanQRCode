//
//  ViewController.m
//  ScanQRCode
//
//  Created by YinlongNie on 17/1/3.
//  Copyright © 2017年 Jiuzhekan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "UIView+WLFrame.h"
#import "SecViewController.h"
#define  kScreenWidth [UIScreen mainScreen].bounds.size.width
#define  kScreenHeight [UIScreen mainScreen].bounds.size.height


// 这个soundQR 带声音
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    UIImageView *lineImageView;
    BOOL upOrDown;
    int num;
    NSTimer *timer;
    CGFloat lineX;
    CGFloat lineY;
    CGFloat lineWidth;
    CGFloat lineAnimationProportion;
}
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *preView;
@end


@implementation ViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self.session startRunning];
    [self openCamera];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setNavigationBar];
    [self addsubview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.session stopRunning];
    [timer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setNavigationBar
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];// 电池栏白色
    //  // 如果设置不透明从导航条底部开始计算frame
    self.navigationController.navigationBar.translucent = UIRectEdgeNone;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"daoHangTiao"] forBarMetrics:(UIBarMetricsDefault)];
    self.navigationItem.title = @"二维码扫描";
    // 设置返回按钮为白色
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.hidden = NO;
}



- (void)addsubview{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth - kScreenHeight/2)/2, 64+40, kScreenHeight/2, kScreenHeight/2)];
    imageView.image = [UIImage imageNamed:@"scan_back_image.png"];
    [self.view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(imageView.frame)+15, kScreenWidth-30, 50)];;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.text = @"请将二维码对准扫码框！";
    [self.view addSubview:label];
    
    upOrDown = NO;
    num = 0;
    
    if (kScreenHeight == 480){
        lineX = 60;
        lineY = imageView.top + 15;
        lineWidth = imageView.width - 50;
        lineAnimationProportion = 1.5;
    }else if (kScreenHeight == 568){
        lineX = 40;
        lineY = imageView.top + 15;
        lineWidth = imageView.width - 50;
        lineAnimationProportion = 1.7;
    }else if (kScreenHeight == 667){
        lineX = 40;
        lineY = imageView.top + 15;
        lineWidth = imageView.width - 50;
        lineAnimationProportion = 2;
    }else{
        lineX = 45;
        lineY = imageView.top + 15;
        lineWidth = imageView.width - 50;
        lineAnimationProportion = 2.2;
    }
    
    lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(lineX, lineY, lineWidth, 2)];
    lineImageView.image = [UIImage imageNamed:@"scan_line_image.png"];
    [self.view addSubview:lineImageView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
}

#pragma mark Target Action
- (void)lineAnimation{
    
    if (upOrDown == NO){
        num++;
        lineImageView.frame = CGRectMake(lineX, lineY + lineAnimationProportion * num, lineWidth, 2);
        if (2 * num == 260)
        {
            upOrDown = YES;
        }
    }else{
        num--;
        lineImageView.frame = CGRectMake(lineX, lineY + lineAnimationProportion * num, lineWidth, 2);
        if (num == 0){
            upOrDown = NO;
        }
    }
}

- (void)openCamera{
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未获得授权使用摄像头" message:@"请在iOS『设置』-『隐私』-『相机』中打开" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        alert.tag = 840;
        [alert show];
        return;
    }
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]){
        [self.session addOutput:self.output];
    }
    self.output.metadataObjectTypes =  @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    self.preView = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preView.frame = CGRectMake((kScreenWidth - kScreenHeight/2)/2, 64+40, kScreenHeight/2, kScreenHeight/2);
    [self.view.layer insertSublayer:self.preView atIndex:0];
    [self.session startRunning];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if ([metadataObjects count] > 0){
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *string = metadataObject.stringValue;
      
        NSLog(@"二维码信息：%@", string);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫描出来的信息" message:string delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
        
        
        // 这里可以进行跳转或者返回
        
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); // 系统震动
        //AudioServicesPlaySystemSound(1007); // 推送的声音
        
        // 1000 - 2000之间
        AudioServicesPlaySystemSound(1010);
        
        SecViewController *VC = [SecViewController new];
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    [self.session stopRunning];
    

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
