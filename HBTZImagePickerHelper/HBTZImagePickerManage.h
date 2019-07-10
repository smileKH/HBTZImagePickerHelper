//
//  HBTZImagePickerManage.h
//  HBTZImagePickerHelper
//
//  Created by 胡明波 on 2019/7/10.
//  Copyright © 2019 mingsishui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TZImagePickerController.h>
//声明管理类型
typedef NS_ENUM(NSInteger,HBManageSelectTakeType) {
    HBManageSelectTakePhotoType,//选择拍照得到图片
    HBManageSelectTakeShootingVideoType,//选择拍照视频
    HBManageSelectTakeVideoType,//直接选择视频
    HBManageSelectTakeImagePickerType//直接获取图片
};
@protocol HBTZImagePickerManageDelegate <NSObject>

///选择图片回调
-(void)selectTZImagePickerSelectedPhotos:(NSMutableArray *)selectedPhotos withSelectedAssets:(NSMutableArray *)selectAssets andIsOriginalPoto:(BOOL)isSelectOriginalPhoto andBlockData:(NSData *)data outPutPath:(NSString *)outPutPath withSelectTakeType:(HBManageSelectTakeType )selectType;
@end
@interface HBTZImagePickerManage : NSObject<UINavigationControllerDelegate,  UIImagePickerControllerDelegate, TZImagePickerControllerDelegate>
@property (nonatomic, weak)id<HBTZImagePickerManageDelegate>delegate;

/**打开手机图片库
 
 @param maxCount 最大张数
 @param superController superController
 @param selectType selectType
 */
- (void)showImagePickerControllerWithMaxCount:(NSInteger )maxCount WithViewController: (UIViewController *)superController withSelectTakeType:(HBManageSelectTakeType )selectType withAssetsArr:(NSMutableArray *)CusSelectedAssets andPhotosArr:(NSMutableArray *)CusSelectedPhotos;
@end

