//
//  HBTZImagePickerManage.m
//  HBTZImagePickerHelper
//
//  Created by 胡明波 on 2019/7/10.
//  Copyright © 2019 mingsishui. All rights reserved.
//

#import "HBTZImagePickerManage.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
//#import "UIImage+Category.h"
@interface HBTZImagePickerManage()<UIActionSheetDelegate>
{
    NSMutableArray *_selectedPhotos;//图片数组
    NSMutableArray *_selectedAssets;//图片原图
    BOOL _isSelectOriginalPhoto;//是否选择原图
}

@property (nonatomic, strong) NSMutableArray *imagesURL;
@property (nonatomic, assign) NSInteger maxCount;
@property (nonatomic, weak) UIViewController *superViewController;
@property (nonatomic,assign)HBManageSelectTakeType selectType;//类型

@property (nonatomic, assign) CGFloat compressionQuality;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) UIImagePickerController *imgPickerVC;
@end

@implementation HBTZImagePickerManage
/**打开手机图片库
 
 @param maxCount 最大张数
 @param superController superController
 @param selectType selectType
 */
- (void)showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController withSelectTakeType:(HBManageSelectTakeType )selectType withAssetsArr:(NSMutableArray *)CusSelectedAssets andPhotosArr:(NSMutableArray *)CusSelectedPhotos{
    self.maxCount = maxCount;
    self.superViewController = superController;
    self.selectType = selectType;
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    if (CusSelectedAssets.count>0) {
        _selectedAssets = CusSelectedAssets;
    }
    if (CusSelectedPhotos.count>0) {
        _selectedPhotos = CusSelectedPhotos;
    }
    
    if (selectType==HBManageSelectTakePhotoType||selectType==HBManageSelectTakeShootingVideoType) {
        //拍照 视频或图片
        [self takePhoto];
    }else{
        //选择手机图片或视频
        [self pushTZImagePickerController];
    }
    
    
}
/**
 选取手机图片
 */
- (void)pushTZImagePickerController
{
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxCount delegate:self];
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    //imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    if (self.selectType==HBManageSelectTakeImagePickerType) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    if (self.selectType==HBManageSelectTakeImagePickerType) {
        //选择图片
        imagePickerVc.allowTakeVideo = YES;   // 在内部显示拍视频按
    }
    imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
    // imagePickerVc.photoWidth = 800;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    /*
     [imagePickerVc setAssetCellDidSetModelBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
     cell.contentView.clipsToBounds = YES;
     cell.contentView.layer.cornerRadius = cell.contentView.tz_width * 0.5;
     }];
     */
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    if (self.selectType==HBManageSelectTakeImagePickerType) {
        //选择图片
        //是否可以选择视频
        imagePickerVc.allowPickingVideo = NO;
        //允许选择图片
        imagePickerVc.allowPickingImage = YES;
        //允许选择原图
        imagePickerVc.allowPickingOriginalPhoto = YES;
    }else{
        //是否可以选择视频
        imagePickerVc.allowPickingVideo = YES;
        //允许选择图片
        imagePickerVc.allowPickingImage = NO;
        //允许选择原图
        imagePickerVc.allowPickingOriginalPhoto = NO;
    }
    
    
    
    //允许选择gif
    imagePickerVc.allowPickingGif = NO;
    // 是否可以多选视频
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = NO;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    
    // 自定义导航栏上的返回按钮
    /*
     [imagePickerVc setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
     [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
     [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 20)];
     }];
     imagePickerVc.delegate = self;
     */
    
    // Deprecated, Use statusBarStyle
    // imagePickerVc.isStatusBarDefault = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = YES;
    
    //    // 自定义gif播放方案
    //    [[TZImagePickerConfig sharedInstance] setGifImagePlayBlock:^(TZPhotoPreviewView *view, UIImageView *imageView, NSData *gifData, NSDictionary *info) {
    //        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    //        FLAnimatedImageView *animatedImageView;
    //        for (UIView *subview in imageView.subviews) {
    //            if ([subview isKindOfClass:[FLAnimatedImageView class]]) {
    //                animatedImageView = (FLAnimatedImageView *)subview;
    //                animatedImageView.frame = imageView.bounds;
    //                animatedImageView.animatedImage = nil;
    //            }
    //        }
    //        if (!animatedImageView) {
    //            animatedImageView = [[FLAnimatedImageView alloc] initWithFrame:imageView.bounds];
    //            animatedImageView.runLoopMode = NSDefaultRunLoopMode;
    //            [imageView addSubview:animatedImageView];
    //        }
    //        animatedImageView.animatedImage = animatedImage;
    //    }];
    
    // 设置首选语言 / Set preferred language
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
    // 设置languageBundle以使用其它语言 / Set languageBundle to use other language
    // imagePickerVc.languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"tz-ru" ofType:@"lproj"]];
#pragma mark - 到这里为止
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    [self.superViewController presentViewController:imagePickerVc animated:YES completion:nil];
}

/**
 拍照
 */
- (void)takePhoto{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takePhoto];
                });
            }
        }];
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        //拍照或者拍视频
        [self pushvideoAndImagePickerController];
        //        //拍照
        //        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        //        [ipc setSourceType:UIImagePickerControllerSourceTypeCamera];
        //        ipc.delegate = self;
        //        ipc.allowsEditing = YES;
        //        if ([[[UIDevice
        //               currentDevice] systemVersion] floatValue] >= 8.0)
        //        {
        //            ipc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        //        }
        //
        //        [self.superViewController presentViewController:ipc animated:YES completion:nil];
    }
}
// 调用相机
- (void)pushvideoAndImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = [locations firstObject];
    } failureBlock:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.location = nil;
    }];
    
    
    UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
    imagePickerVc.delegate = self;
    self.imgPickerVC = imagePickerVc;
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVc.sourceType = sourceType;
        NSMutableArray *mediaTypes = [NSMutableArray array];
        if (self.selectType==HBManageSelectTakeShootingVideoType) {//拍视频
            [mediaTypes addObject:(NSString *)kUTTypeMovie];
            imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
        }
        if (self.selectType==HBManageSelectTakePhotoType) {//拍图片
            [mediaTypes addObject:(NSString *)kUTTypeImage];
            imagePickerVc.allowsEditing = YES;
            if ([[[UIDevice
                   currentDevice] systemVersion] floatValue] >= 8.0)
            {
                imagePickerVc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            }
        }
        if (mediaTypes.count) {
            imagePickerVc.mediaTypes = mediaTypes;
        }
        [self.superViewController presentViewController:imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
#pragma mark -- UIImagePickerControllerDelegate
//选择图片回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"如果这里有回调，请告诉我一下");
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeImage])
    {
        //[self.superViewController showLoadingInWindowWithMessage:@"处理中..."];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(PHAsset *asset, NSError *error){
            //            [tzImagePickerVc hideProgressHUD];
            if (error) {
                NSLog(@"图片保存失败 %@",error);
            } else {
                //TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                
                //                [_selectedAssets addObject:asset];
                //                [_selectedPhotos addObject:image];
                //                NSData *data = [[NSData alloc]init];
                //                if (_delegate&&[_delegate respondsToSelector:@selector(cusSelectTZImagePickerSelectedPhotos:withSelectedAssets:andIsOriginalPoto: andBlockData: withSelectTakeType:)]) {
                //                    [_delegate cusSelectTZImagePickerSelectedPhotos:_selectedPhotos withSelectedAssets:_selectedAssets andIsOriginalPoto:self. andBlockData:data withSelectTakeType:self.selectType];
                //                }
                
                //                if (self.allowCropSwitch.isOn) { // 允许裁剪,去裁剪
                //                    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                //                        [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                //                    }];
                //                    imagePicker.allowPickingImage = YES;
                //                    imagePicker.needCircleCrop = self.needCircleCropSwitch.isOn;
                //                    imagePicker.circleCropRadius = 100;
                //                    [self.superViewController presentViewController:imagePicker animated:YES completion:nil];
                //                } else {
                //                    [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                //                }
            }
        }];
        //    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //
        //                [self.superViewController.view showLoadingInWindowWithMessage:@"处理中..."];
        //            });
        //            // 原图/编辑后的图片
        //            // UIImagePickerControllerOriginalImage/UIImagePickerControllerEditedImage
        //            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //            // 1. 处理图片
        //            image = [self imageProcessing:image];
        //            // 2. 写入缓存
        //            NSString *filePath = [self imageDataWriteToFile:image];
        //            // 3. 加入数组、返回数组、重置数组
        //            [self.imagesURL addObject:filePath];
        ////            if (self.delegate&&[self.delegate respondsToSelector:@selector(cusSelectTZImagePickerImgArr:)]) {
        ////                [self.delegate cusSelectTZImagePickerImgArr:self.imagesURL];
        ////            }
        //            self.imagesURL = nil;
        //
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //
        //                [self.superViewController.view dissmissWindowHud];
        //            });
        //        });
        //        [self.superViewController dismissViewControllerAnimated:YES completion:nil];
    }else if([picker.mediaTypes containsObject:(NSString *)kUTTypeMovie]){
        //视频
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        //[self.superViewController showLoadingInWindowWithMessage:@"处理中..."];
        if (videoUrl) {
            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:self.location completion:^(PHAsset *asset, NSError *error) {
                //                [tzImagePickerVc hideProgressHUD];
                if (!error) {
                    TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
                    [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                        if (!isDegraded && photo) {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
                        }
                    }];
                }
            }];
        }
    }
}
- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
        __weak typeof(self) weakSelf = self;
        [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
            NSData *data = [NSData dataWithContentsOfFile:outputPath];
            NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
            // Export completed, send video here, send by outputPath or NSData
            // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
            //拿到data 开始回调
            [weakSelf requestDataBlock:data andOutPutPath:outputPath];
        } failure:^(NSString *errorMessage, NSError *error) {
            NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self.superViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TZImagePickerControllerDelegate
/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 你也可以设置autoDismiss属性为NO，选择器就不会自己dismis了
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    //返回图片处理
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    NSData *data = [[NSData alloc]init];
    if (_delegate&&[_delegate respondsToSelector:@selector(selectTZImagePickerSelectedPhotos:withSelectedAssets:andIsOriginalPoto: andBlockData: outPutPath: withSelectTakeType:)]) {
        [_delegate selectTZImagePickerSelectedPhotos:_selectedPhotos withSelectedAssets:_selectedAssets andIsOriginalPoto:isSelectOriginalPhoto andBlockData:data outPutPath:@"" withSelectTakeType:self.selectType];
    }
    //    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        for (int i = 0; i<photos.count; i++)
    //        {
    //            UIImage *image = photos[i];
    //            // 1. 处理图片
    //            image = [self imageProcessing:image];
    //            // 2. 写入缓存
    //            NSString *filePath = [self imageDataWriteToFile:image];
    //            // 3. 加入数组、返回数组、重置数组
    //            [self.imagesURL addObject:filePath];
    ////            if (self.delegate&&[self.delegate respondsToSelector:@selector(cusSelectTZImagePickerImgArr:)]) {
    ////                [self.delegate cusSelectTZImagePickerImgArr:self.imagesURL];
    ////            }
    //            self.imagesURL = nil;
    //        }
    //    });
}


// 如果用户选择了一个视频且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    //    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            [self.superViewController showLoadingInWindowWithMessage:@"处理中..."];
    //        });
    //
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            [self.superViewController dissmissWindowHud];
    //        });
    //    });
    NSLog(@"打印视频的宽:%zd",asset.pixelWidth);
    NSLog(@"打印视频的搞:%zd",asset.pixelHeight);
    //[self.superViewController showLoadingInWindowWithMessage:@"处理中..."];
    __weak typeof(self) weakSelf = self;
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
        NSData *data = [NSData dataWithContentsOfFile:outputPath];
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        // Export completed, send video here, send by outputPath or NSData
        // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
        //拿到data 开始回调
        [weakSelf requestDataBlock:data andOutPutPath:outputPath];
    } failure:^(NSString *errorMessage, NSError *error) {
        NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
    }];
    
    
}
#pragma mark ==========回调了视频==========
-(void)requestDataBlock:(NSData *)data andOutPutPath:(NSString *)outPutPath{
    //[self.superViewController dissmissWindowHud];
    //返回图片处理
    if (_delegate&&[_delegate respondsToSelector:@selector(selectTZImagePickerSelectedPhotos:withSelectedAssets:andIsOriginalPoto:andBlockData: outPutPath:withSelectTakeType:)]) {
        [_delegate selectTZImagePickerSelectedPhotos:_selectedPhotos withSelectedAssets:_selectedAssets andIsOriginalPoto:NO andBlockData:data outPutPath:outPutPath withSelectTakeType:self.selectType];
    }
}
#pragma mark -- 内部方法

- (NSString *)imageDataWriteToFile:(UIImage *)image
{
    NSData *data;
    //获取图片路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath =  [NSString stringWithFormat:@"%@%@",path,[NSString stringWithFormat:@"img_%d.jpg",arc4random()]];
    if (UIImagePNGRepresentation(image) == nil)
    {
        data = UIImageJPEGRepresentation(image, self.compressionQuality);
    }
    else
    {
        // 将PNG转JPG
        [UIImageJPEGRepresentation(image, self.compressionQuality) writeToFile:filePath atomically:YES];
        UIImage *jpgImage = [UIImage imageWithContentsOfFile:filePath];
        data = UIImageJPEGRepresentation(jpgImage, self.compressionQuality);
    }
    
    [data writeToFile:filePath atomically:YES];
    return filePath;
}

/**
 处理图片
 
 @param image image
 @return return 新图片
 */
- (UIImage *)imageProcessing:(UIImage *)image
{
    UIImageOrientation imageOrientation = image.imageOrientation;
    if (imageOrientation != UIImageOrientationUp)
    {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    
    CGSize imagesize = image.size;
    //质量压缩系数
    self.compressionQuality = 1;
    
    //如果大于两倍屏宽 或者两倍屏高
    if (image.size.width > 640 || image.size.height > 568*2)
    {
        self.compressionQuality = 0.5;
        //宽大于高
        if (image.size.width > image.size.height)
        {
            imagesize.width = 320*2;
            imagesize.height = image.size.height*imagesize.width/image.size.width;
        }
        else
        {
            imagesize.height = 568*2;
            imagesize.width = image.size.width*imagesize.height/image.size.height;
        }
    }
    else
    {
        self.compressionQuality = 0.6;
    }
    
    // 对图片大小进行压缩
    UIImage *newImage = [self imageWithImage:image scaledToSize:imagesize];
    return newImage;
}
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}
#pragma mark -- 懒加载

- (NSMutableArray *)imagesURL
{
    if (!_imagesURL) {
        _imagesURL = [NSMutableArray array];
    }
    return _imagesURL;
}
@end

