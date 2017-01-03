//
//  SecViewController.m
//  ScanQRCode
//
//  Created by YinlongNie on 17/1/3.
//  Copyright © 2017年 Jiuzhekan. All rights reserved.
//

#import "SecViewController.h"
#import <AudioToolbox/AudioToolbox.h>
@interface SecViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation SecViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTableView];
}


#pragma mark--- 创建tableView设置代理
- (void)createTableView
{
    self.dataArray = [NSMutableArray array];
    
    for (int i = 1000; i<=2000; i++) {
        NSString *soundId = [NSString stringWithFormat:@"%d", i];
        [self.dataArray addObject:soundId];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:(UITableViewStylePlain)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIView *clearView = [[UIView alloc] init];
    self.tableView.tableFooterView = clearView;
}


#pragma mark---- 实现代理方法
// 返回分区的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

#pragma mark--返回cell的模样
#pragma mark--返回cell的模样
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyCell";
    
    // 从复用集合取出cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        // 如果复用集合为空就创建
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"声音ID: %@", self.dataArray[indexPath.row]];
    return cell;
}





#pragma mark-------选择跳转
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1000 - 2000之间
    NSString *sou = self.dataArray[indexPath.row];
    
    AudioServicesPlaySystemSound([sou intValue]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
