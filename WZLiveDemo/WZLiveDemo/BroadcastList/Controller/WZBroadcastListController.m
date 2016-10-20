//
//  WZBroadcastListController.m
//  WZLiveDemo
//
//  Created by songbiwen on 2016/10/20.
//  Copyright © 2016年 songbiwen. All rights reserved.
//

#import "WZBroadcastListController.h"
#import "WZLiveItem.h"
#import "WZLiveCell.h"
#import "WZLiveViewController.h"


@interface WZBroadcastListController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@end


@implementation WZBroadcastListController

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取数据
    [self fetchBroadcastListData];
}

/** 获取数据 */
- (void)fetchBroadcastListData {
    
    NSString *urlStr = @"http://116.211.167.106/api/live/aggregation?uid=133825214&interest=1";
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    mgr.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
    [mgr GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            _dataSource = [WZLiveItem mj_objectArrayWithKeyValuesArray:responseObject[@"lives"]];
            
            WZLog(@"%@",_dataSource);
            [self.tableView reloadData];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        WZLog(@"%@",error);
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WZLiveCell *cell = [WZLiveCell cellOfTableView:tableView];
    
    cell.liveItem = _dataSource[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WZLiveViewController *liveVc = [[WZLiveViewController alloc] init];
    liveVc.liveItem = _dataSource[indexPath.row];
    
    [self.navigationController pushViewController:liveVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 430;
}

@end
