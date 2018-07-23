//
//  RisenPhotoViewController.m
//  RisenImageDemo
//
//  Created by Risen on 2018/7/18.
//  Copyright © 2018年 Risen. All rights reserved.
//

#import "RisenPhotoViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "myPhotoCell.h"
#import "PhotoFunctionView.h"
#import "NavView.h"
/*
 颜色
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define SelfView_W [[UIScreen mainScreen] bounds].size.width
#define SelfView_H [[UIScreen mainScreen] bounds].size.height
#define phoneScale [UIScreen mainScreen].bounds.size.width/720.0

//手机系统版本
#define phoneVersion [[UIDevice currentDevice] systemVersion]


#define navView_H 64

#define TabBar_H 49

@interface RisenPhotoViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIButton *finishBtn;
//显示照片
@property(nonatomic,strong)UICollectionView *ado_collectionView;
//所有照片组的数组（内部是所有相册的组）
@property (nonatomic, strong) NSMutableArray *photoGroupArr;

//所有照片组内的url数组（内部是最大的相册的照片url，这个相册一般名字是 所有照片或All Photos）
@property (nonatomic, strong) NSMutableArray *allPhotoArr;

//所选择的图片数组
@property (nonatomic, strong) NSMutableArray *chooseArray;

//所选择的图片所在cell的序列号数组
@property (nonatomic, strong) NSMutableArray *chooseCellArray;

@property (nonatomic, strong) NSMutableArray *choosePhotoArr;


@property (nonatomic, strong) PHCachingImageManager *imageManager;
@end

@implementation RisenPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeNav];
    
    self.view.backgroundColor = UIColorFromRGB(0xffffff);
    
    [self.view addSubview:[self finishButton]];
    [self.view addSubview:[self ado_collectionView]];
    [self getAllPhotos];

    // Do any additional setup after loading the view.
}
#pragma mark GetAllPhotos
- (void)getAllPhotos {
    
    if ([phoneVersion integerValue] >= 8) {
        //高版本使用PhotoKit框架
        [self getHeightVersionAllPhotos];
    
    }else {
        //低版本使用ALAssetsLibrary框架
        [self getLowVersionAllPhotos];
    }
    
    
}
#pragma mark 高版本使用PhotoKit框架
- (void)getHeightVersionAllPhotos {
    
    [PhotoFunctionView getHeightVersionAllPhotos:^(PHFetchResult *allPhotos) {
        
        _imageManager = [[PHCachingImageManager alloc]init];
        
        if (!_allPhotoArr) {
            _allPhotoArr = [[NSMutableArray alloc]init];
        }
        
        for (NSInteger i = 0; i < allPhotos.count; i++) {
            
            PHAsset *asset = allPhotos[i];
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [_allPhotoArr addObject:asset];
            }
            
            NSString *cellId = [NSString stringWithFormat:@"cell%ld", (long)i];
            [self.ado_collectionView registerClass:[myPhotoCell class] forCellWithReuseIdentifier:cellId];
            
        }
        [self.ado_collectionView reloadData];
    }];
}

#pragma mark 低版本使用ALAssetsLibrary框架
- (void)getLowVersionAllPhotos {
    
    [PhotoFunctionView getLowVersionAllPhotos:^(ALAssetsGroup *group) {
        if (!_photoGroupArr) {
            _photoGroupArr = [[NSMutableArray alloc]init];
        }
        
        if (group!=nil) {
            [_photoGroupArr addObject:group];
        }
        else{
            ALAssetsGroup* allPhotoGroup = _photoGroupArr[_photoGroupArr.count-1];
            
            if (!_allPhotoArr) {
                _allPhotoArr = [[NSMutableArray alloc]init];
            }
            
            //获取相册分组里面的照片内容
            [allPhotoGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result&&[[result valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto]) {
                    
                    //照片内容url加入数组
                    [_allPhotoArr addObject:result.defaultRepresentation.url];
                }
                else{
                    //刷新显示
                    if (_allPhotoArr.count) {
                        for (NSInteger i = 0; i<_allPhotoArr.count; i++) {
                            NSString *cellId = [NSString stringWithFormat:@"cell%ld", (long)i];
                            [self.ado_collectionView registerClass:[myPhotoCell class] forCellWithReuseIdentifier:cellId];
                        }
                        [self.ado_collectionView reloadData];
                    }
                }
            }];
        }
    }];
}
-(UICollectionView*)ado_collectionView{
    if (!_ado_collectionView) {
        UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc]init];
        [layout setItemSize:CGSizeMake((SelfView_W-50)/4, (SelfView_W-50)/4)];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _ado_collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, navView_H, SelfView_W, SelfView_H-TabBar_H-navView_H) collectionViewLayout:layout];
        _ado_collectionView.backgroundColor = [UIColor whiteColor];
        _ado_collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _ado_collectionView.dataSource = self;
        _ado_collectionView.delegate = self;
        [self.ado_collectionView registerClass:[myPhotoCell class] forCellWithReuseIdentifier:@"cellId"];
    }
    return _ado_collectionView;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _allPhotoArr.count;
}
-(__kindof UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (_allPhotoArr.count) {
        NSString *cellId = [NSString stringWithFormat:@"cell%ld", (long)indexPath.row];
        myPhotoCell *cell = (myPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
        
        if ([phoneVersion integerValue] >= 8) {
            PHAsset *asset = _allPhotoArr[_allPhotoArr.count - indexPath.item - 1];
            cell.progressView.hidden = YES;
            cell.representedAssetIdentifier = asset.localIdentifier;
            CGFloat scale = [UIScreen mainScreen].scale;
            CGSize cellSize = cell.frame.size;
            CGSize AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
            
            [_imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeDefault
                                        options:nil
                                  resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          cell.photoView.image = result;
                                      }
                                  }];
            
        } else {
            if (!cell.photoView.image) {
                cell.progressView.hidden = YES;
                NSURL *url = self.allPhotoArr[self.allPhotoArr.count - indexPath.row - 1];
                ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
                [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
                    cell.photoView.image = image;
                } failureBlock:^(NSError *error) {
                    NSLog(@"error=%@", error);
                }];
            }
        }
        cell.signImageButton.tag = indexPath.row;
        [cell.signImageButton addTarget:self action:@selector(ChangeCheckImage:) forControlEvents: UIControlEventTouchUpInside];
        return cell;
    } else {
        myPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
        cell.signImageButton.tag = indexPath.row;
        [cell.signImageButton addTarget:self action:@selector(ChangeCheckImage:) forControlEvents: UIControlEventTouchUpInside];
        
        return cell;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark FinishButton
-(UIButton *)finishButton
{
    if (!_finishBtn) {
        UIButton *finishBut = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBut.frame = CGRectMake(0, SelfView_H-TabBar_H, SelfView_W, TabBar_H);
        finishBut.backgroundColor = UIColorFromRGB(0xf9f9f9);
        finishBut.layer.borderWidth = 0.5;
        finishBut.layer.borderColor = UIColorFromRGB(0xe8e8e8).CGColor;
        [finishBut addTarget:self action:@selector(finishChoosePhotos:) forControlEvents:UIControlEventTouchUpInside];
        _finishBtn = finishBut;
        [self finishColorAndTextChange:_choosePhotoArr.count];
    }
    return _finishBtn;
}

-(void)finishChoosePhotos:(UIButton *)finishbtn{
    
    NSString *finishStr = [NSString stringWithFormat:@"0/%ld 完成", (long)_selectPhotoOfMax];
    if (![finishbtn.titleLabel.text isEqualToString:finishStr]&&_chooseArray.count) {
        [PhotoFunctionView finishChoosePhotos:^(NSMutableArray *myChoosePhotoArr) {
            _selectPhotosBack(myChoosePhotoArr);
            [self btnClickBack];
        } chooseArray:_chooseArray];
    }
}
-(void)ChangeCheckImage:(UIButton*)sender{
    NSInteger index =sender.tag;
    NSLog(@"index=%ld",index);
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
    
    
    if (!_chooseArray) {
        _chooseArray = [[NSMutableArray alloc]init];
    }
    if (!_chooseCellArray) {
        _chooseCellArray = [[NSMutableArray alloc]init];
    }
    
    myPhotoCell *cell = (myPhotoCell *)[self.ado_collectionView cellForItemAtIndexPath:indexPath];
    
    if ([phoneVersion integerValue] >= 8) {
        PHAsset *asset = _allPhotoArr[_allPhotoArr.count-indexPath.row-1];
        
        [PhotoFunctionView getChoosePicPHImageManager:^(double progress) {
            
            cell.progressView.hidden = NO;
            cell.progressFloat = progress;
            
        } manager:^(UIImage *result) {
            // Hide the progress view now the request has completed.
            
            cell.progressView.hidden = YES;
            
            // Check if the request was successful.
            if (!result) {
                return;
            } else {
                
                if (cell.chooseStatus == NO) {
                    if((_chooseArray.count+_choosePhotoArr.count)< _selectPhotoOfMax)
                    {
                        [_chooseArray addObject:result];
                        [_chooseCellArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                        [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                        
                        UIImageView *signImage = [[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.size.width-22-5, 5, 22, 22)];
                        signImage.layer.cornerRadius = 22/2;
                        signImage.image = WPhoto_Btn_Selected;
                        signImage.layer.masksToBounds = YES;
                        [cell addSubview:signImage];
                        
                        [PhotoFunctionView shakeToShow:signImage];
                        
                        cell.chooseStatus = YES;
                    }else{
                        UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"提示!" message:[NSString stringWithFormat:@"最多支持选择%ld张!",_selectPhotoOfMax] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                        [alert  show];
                        
                    }
                    
                } else{
                    for (NSInteger i = 2; i<cell.subviews.count; i++) {
                        [cell.subviews[i] removeFromSuperview];
                    }
                    for (NSInteger j = 0; j<_chooseCellArray.count; j++) {
                        
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:[_chooseCellArray[j] integerValue] inSection:0];
                        
                        if (indexPath.row == ip.row) {
                            [_chooseArray removeObjectAtIndex:j];
                        }
                    }
                    [_chooseArray removeObject:result];
                    [_chooseCellArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                    [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                    
                    cell.chooseStatus = NO;
                }
            }
        } asset:asset viewSize:self.view.bounds.size];
        
    } else {
        if (cell.chooseStatus == NO) {
            if ((_chooseArray.count+_choosePhotoArr.count) < _selectPhotoOfMax) {
                [_chooseArray addObject:_allPhotoArr[_allPhotoArr.count-indexPath.row-1]];
                [_chooseCellArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
                [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
                
                UIImageView *signImage = [[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.size.width-22-5, 5, 22, 22)];
                signImage.layer.cornerRadius = 22/2;
                signImage.image = WPhoto_Btn_Selected;
                signImage.layer.masksToBounds = YES;
                [cell addSubview:signImage];
                
                [PhotoFunctionView shakeToShow:signImage];
                
                cell.chooseStatus = YES;
            }else{
                UIAlertView * alert =[[UIAlertView alloc]initWithTitle:@"提示!" message:[NSString stringWithFormat:@"最多支持选择%ld张!",_selectPhotoOfMax] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert  show];
                
            }
        } else{
            for (NSInteger i = 2; i<cell.subviews.count; i++) {
                [cell.subviews[i] removeFromSuperview];
            }
            [_chooseArray removeObject:_allPhotoArr[_allPhotoArr.count-indexPath.row-1]];
            [_chooseCellArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
            cell.chooseStatus = NO;
        }
    }
    
    
}
#pragma mark createNav
-(void)makeNav {
    NavView *navVC = [[NavView alloc] init];
    navVC.frame = self.view.bounds;
    [navVC setNavViewBack:^{
        [self btnClickBack];
    }];
    [navVC setQuitChooseBack:^{
        [self quitChoose];
    }];
    [self.view addSubview:navVC];
}

#pragma mark 取消全部选择
-(void)quitChoose{
    if (_ado_collectionView&&_chooseArray&&_chooseCellArray) {
        if (_chooseArray.count&&_chooseCellArray.count) {
            
            for (NSInteger i = 0; i<_chooseCellArray.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_chooseCellArray[i] integerValue] inSection:0];
                myPhotoCell *cell = (myPhotoCell *)[_ado_collectionView cellForItemAtIndexPath:indexPath];
                
                for (NSInteger j = 2; j<cell.subviews.count; j++) {
                    [cell.subviews[j] removeFromSuperview];
                }
                cell.chooseStatus = NO;
            }
            [_chooseArray removeAllObjects];
            [_chooseCellArray removeAllObjects];
            
            [self finishColorAndTextChange:_chooseArray.count+_choosePhotoArr.count];
        }
    }
}

-(void)finishColorAndTextChange:(NSInteger)choosePhotoCount
{
    [_finishBtn setTitle:[NSString stringWithFormat:@"%lu/%ld 完成", choosePhotoCount,(long)_selectPhotoOfMax] forState:UIControlStateNormal];
    NSString *finishStr = [NSString stringWithFormat:@"0/%ld 完成", (long)_selectPhotoOfMax];
    if ([_finishBtn.titleLabel.text isEqualToString:finishStr]&&!_chooseArray.count) {
        [_finishBtn setTitleColor:UIColorFromRGB(0xbbbbbb) forState:UIControlStateNormal];
    }
    else {
        [_finishBtn setTitleColor:UIColorFromRGB(0xcc3366) forState:UIControlStateNormal];
    }
}

#pragma mark 返回
-(void)btnClickBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showAlertView
{
    UIAlertView *alertVC = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"请将'设置->隐私->照片->'设置为允许." delegate:self cancelButtonTitle:nil otherButtonTitles:@"好", nil];
    [alertVC show];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
