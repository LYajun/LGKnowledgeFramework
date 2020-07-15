//
//  KlgViewController.m
//  LGKnowledge
//
//  Created by 刘亚军 on 2019/1/5.
//  Copyright © 2019年 刘亚军. All rights reserved.
//

#import "KlgViewController.h"
#import <LGKnowledgeFramework/LGKnowledgeFramework.h>
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>


@interface KlgViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (strong,nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UILabel *stateLab;
@property (nonatomic,assign) NSInteger pageIndex;
@property (nonatomic,assign) NSInteger pageSize;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation KlgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self loadDataWithPageIndex:self.pageIndex];
}
- (void)loadDataWithPageIndex:(NSInteger)pageIndex{
    if (pageIndex == 1) {
        [self indicatorViewStart];
    }
    NSString *urlStr = [NSString stringWithFormat:@"%@/DebrisPublicWeb.asmx/WS_Get_SubjectKlgByCondition?SubjectCode=C&VersionCode=%@&TypeName=%@&PageIndex=%li&PageSize=%li",self.klgUrl,self.versionCode,self.TypeName,self.pageIndex,self.pageSize];
    NSURL *requestUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.timeoutInterval = 15;
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    self.stateLab.text = @"";
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf indicatorViewStop];
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView.mj_footer endRefreshing];
            if (error) {
                weakSelf.stateLab.text = @"加载失败";
            }else{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if (json && [[json objectForKey:@"State"] integerValue] == 1) {
                    NSDictionary *dataDic = [json objectForKey:@"Data"];
                    NSArray *arr = [dataDic objectForKey:@"KlgInformatin"];
                    NSInteger totalCount = [[dataDic objectForKey:@"KlgCount"] integerValue];
                    if (weakSelf.pageIndex == 1) {
                        if (arr && arr.count < weakSelf.pageSize) {
                            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }else{
                        BOOL noMoreData = (weakSelf.pageSize * (weakSelf.pageIndex - 1) + arr.count) >= totalCount;
                        if (noMoreData) {
                             [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                        }
                    }
                    [weakSelf.dataArray addObjectsFromArray:arr];
                    [weakSelf.tableView reloadData];
                }else{
                   weakSelf.stateLab.text = @"加载失败";
                }
            }
        });
    }];
    [dataTask resume];
}
- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.TypeName;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.stateLab];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    self.pageIndex = 1;
    self.pageSize = 20;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = [dic objectForKey:@"Name"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.dataArray[indexPath.row];
    /** 服务器地址 */
    [LGKnowledgeManager defaultManager].apiUrl = self.klgUrl;

    /** 是否只开放知识点卡片 */
//    [LGKnowledgeManager defaultManager].onlyKlgCark = YES;
    /** 知识点编码 */
    [LGKnowledgeManager defaultManager].klgCode = [dic objectForKey:@"NewCode"];
    [LGKnowledgeManager defaultManager].klgErrorBlock = ^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    };
    /** 当前知识点模块控制器 */
    [[LGKnowledgeManager defaultManager] presentKnowledgeControllerBy:self];
//    [[LGKnowledgeManager defaultManager] presentKnowledgeAlertViewByController:self addStudyBlock:^{
//        NSLog(@"addStudyBlock");
//    }];
}
- (void)indicatorViewStop{
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
}
- (void)indicatorViewStart{
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (UILabel *)stateLab{
    if (!_stateLab) {
        _stateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _stateLab.textAlignment = NSTextAlignmentRight;
        _stateLab.font = [UIFont systemFontOfSize:18];
        _stateLab.textColor = [UIColor redColor];
    }
    return _stateLab;
}
- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _indicatorView;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 60;
        __weak typeof(self) weakSelf = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            weakSelf.pageIndex = 1;
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
            [weakSelf loadDataWithPageIndex:weakSelf.pageIndex];
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        [header setTitle:@"下拉进行刷新" forState:MJRefreshStateIdle];
        [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
        [header setTitle:@"加载中 ..." forState:MJRefreshStateRefreshing];
        _tableView.mj_header = header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            weakSelf.pageIndex++;
            [weakSelf loadDataWithPageIndex:weakSelf.pageIndex];
        }];
        [footer setTitle:@"上拉加载更多 ..." forState:MJRefreshStateIdle];
        [footer setTitle:@"正在拼命加载 ..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"已全部加载" forState:MJRefreshStateNoMoreData];
        footer.stateLabel.font = [UIFont systemFontOfSize:15];
        footer.stateLabel.textColor = [UIColor darkGrayColor];
        _tableView.mj_footer = footer;
    }
    return _tableView;
}
@end
