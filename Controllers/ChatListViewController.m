//
//  ChatListViewController.m
//  885logistics
//
//  Created by Blues on 17/1/11.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ChatListViewController.h"
#import "NewsViewController.h"
#import "ChatViewController.h"
#import "SearchViewController.h"


@interface ChatListViewController (){

}
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *searchBt;
@property (nonatomic, strong) UIView *footer;

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navtitle_new"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18.f],NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self createNavItems];
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE)]];
    self.conversationListTableView.tableFooterView = self.footer;
    self.conversationListTableView.tableHeaderView = self.header;
    
}

- (void)createNavItems {
    
    UIImage *img = [[UIImage imageNamed:@"news1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(toggleNewsController)];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)toggleNewsController {
    
    NewsViewController *news = [[NewsViewController alloc] init];
    [news addPopItem];
    news.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:news animated:YES];
}

//重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    ChatViewController *chat = [[ChatViewController alloc]init];
    chat.conversationType = ConversationType_PRIVATE;
    chat.targetId = model.targetId;
    chat.title = model.conversationTitle;
    chat.moreDetail = @"more";
    chat.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chat animated:YES];
}

#pragma mark - getter
- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(10, 0, kScreenSize.width - 10.f, 1)];
        _footer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _footer;
}

- (UIView *)header {

    if (!_header) {
        
        _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 50.f)];
        _header.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _searchBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, kScreenSize.width - 20.f, 34.f)];
        [_searchBt setTitle:@"搜索好友姓名" forState:UIControlStateNormal];
        _searchBt.layer.masksToBounds = YES;
        _searchBt.layer.cornerRadius = 1.5f;
        _searchBt.backgroundColor = [UIColor whiteColor];
        [_searchBt setImage:[UIImage imageNamed:@"search_12x12"] forState:UIControlStateNormal];
        _searchBt.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_searchBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_searchBt addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_searchBt setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_header addSubview:_searchBt];
    }
    return _header;
}


- (void)searchClicked:(UIButton *)sender {

    SearchViewController *search = [[SearchViewController alloc] init];
    search.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:search animated:YES];
}













- (UIView *)emptyConversationView {
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
