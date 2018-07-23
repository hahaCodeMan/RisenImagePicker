//
//  ViewController.m
//  RisenImageDemo
//
//  Created by Risen on 2018/7/17.
//  Copyright © 2018年 Risen. All rights reserved.
//
#import "ViewController.h"
#import "RisenPhotoViewController.h"
#define phoneScale [UIScreen mainScreen].bounds.size.width/720.0

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSMutableArray *_photosArr;
     UIButton *_addBut;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
    _addBut = [UIButton buttonWithType:UIButtonTypeCustom];
    _addBut.frame = CGRectMake((self.view.frame.size.width-160*phoneScale)/2, self.view.frame.size.height-(60+160)*phoneScale, 160*phoneScale, 160*phoneScale);
    _addBut.layer.cornerRadius = 160*phoneScale/2;
    _addBut.layer.masksToBounds = YES;
    [_addBut setImage:[UIImage imageNamed:@"1.2.1-CreateNew"] forState:UIControlStateNormal];
    [_addBut addTarget:self action:@selector(addButClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addBut];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)addButClick
{
     RisenPhotoViewController* RisenPhoto = [[RisenPhotoViewController alloc] init];
    //选择图片的最大数
    RisenPhoto.selectPhotoOfMax = 8;
    [RisenPhoto setSelectPhotosBack:^(NSMutableArray *phostsArr) {
        _photosArr = phostsArr;
        [_tableView reloadData];
    }];
   [self presentViewController:RisenPhoto animated:YES completion:nil];
}
-(void)createTableView{
    _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _photosArr.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellID =[NSString stringWithFormat:@"cellId%ld",(long)indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    CGFloat photoSize = [UIScreen mainScreen].bounds.size.width -20;
    UIImageView *imageView =[[UIImageView alloc]init];
    imageView.frame = CGRectMake(10, 10, photoSize, photoSize);
   imageView.image = [[_photosArr objectAtIndex:indexPath.row] objectForKey:@"image"];
    imageView.contentMode=UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [cell addSubview:imageView];
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.width;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
