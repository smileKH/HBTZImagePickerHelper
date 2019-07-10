//
//  ViewController.m
//  HBTZImagePickerHelper
//
//  Created by 胡明波 on 2019/7/10.
//  Copyright © 2019 mingsishui. All rights reserved.
//

#import "ViewController.h"
#import "HBTZImagePickerManage.h"
@interface ViewController ()<HBTZImagePickerManageDelegate>
/**
 封装的获取图片工具类
 1. 初始化一个helper (需设置block回调已选择图片的路径数组);
 2. 调用showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController;
 3. 调用结束后，刷新界面;
 */
@property (nonatomic, strong) HBTZImagePickerManage *helper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clickBtn.frame = CGRectMake(100, 100, 100, 100);
    [clickBtn setTitle:@"点击我" forState:UIControlStateNormal];
    [clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clickBtn setBackgroundColor:[UIColor redColor]];
    [clickBtn addTarget:self action:@selector(clickSelectPhotos:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clickBtn];
}
#pragma mark ==========选择图片-视频-拍照图片-拍照视频==========
-(void)clickSelectPhotos:(UIButton *)button{
    //使用
    /*
     HBManageSelectTakePhotoType,//选择拍照得到图片
     HBManageSelectTakeShootingVideoType,//选择拍照视频
     HBManageSelectTakeVideoType,//直接选择视频
     HBManageSelectTakeImagePickerType//直接获取图片
     */
    [self.helper showImagePickerControllerWithMaxCount:9 WithViewController:self withSelectTakeType:HBManageSelectTakeImagePickerType withAssetsArr:nil andPhotosArr:nil];
}
#pragma mark ==========选择图片数组回调==========
-(void)selectTZImagePickerSelectedPhotos:(NSMutableArray *)selectedPhotos withSelectedAssets:(NSMutableArray *)selectAssets andIsOriginalPoto:(BOOL)isSelectOriginalPhoto andBlockData:(NSData *)data outPutPath:(NSString *)outPutPath withSelectTakeType:(HBManageSelectTakeType )selectType{
    //发布你的东西
    NSLog(@"选择图片成功~~~~~~~~~~~~~~");
}
- (HBTZImagePickerManage *)helper
{
    if (!_helper) {
        _helper = [[HBTZImagePickerManage alloc] init];
        _helper.delegate = self;
    }
    return _helper;
}

@end
