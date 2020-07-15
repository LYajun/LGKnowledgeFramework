//
//  YJViewController.m
//  LGKnowledgeFramework
//
//  Created by lyj on 09/18/2019.
//  Copyright (c) 2019 lyj. All rights reserved.
//

#import "YJViewController.h"
#import <Masonry/Masonry.h>
#import "KlgViewController.h"
#import <LGKnowledgeFramework/LGKnowledgeFramework.h>
#import <YJExtensions/YJExtensions.h>
#import <LGAlertHUD/LGAlertHUD.h>
#import "YJDynamicSegment.h"
#import <YJExtensions/YJExtensions.h>

@interface YJTextField : UITextField
@property (nonatomic, strong) UIToolbar *customAccessoryView;
@end
@implementation YJTextField
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.inputAccessoryView = self.customAccessoryView;
    }
    return self;
}
- (UIToolbar *)customAccessoryView{
    if (!_customAccessoryView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _customAccessoryView = [[UIToolbar alloc]initWithFrame:(CGRect){0,0,width,40}];
        _customAccessoryView.barTintColor = [UIColor whiteColor];
        UIBarButtonItem *clear = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStyleDone target:self action:@selector(clearAction)];
        UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *finish = [[UIBarButtonItem alloc]initWithTitle:@"收起" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        [_customAccessoryView setItems:@[clear,space,finish]];
        
    }
    return _customAccessoryView;
}
- (void)clearAction{
    self.text = @"";
}
- (void)done{
    [self resignFirstResponder];
}
@end

@interface YJViewController ()<UITableViewDelegate,UITableViewDataSource,YJDynamicSegmentDelegate>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray *dataArr;
@property (nonatomic,strong) UISegmentedControl *segControll;
@property (nonatomic,strong) UILabel *serverTitleLab;
@property (nonatomic,strong) YJTextField *textField;
@property (nonatomic,strong) YJDynamicSegment *segment;
@property (nonatomic,strong) NSArray *studyLevelArr;
@property (nonatomic,assign) NSInteger currentIndex;
@end

@implementation YJViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.dataArr = @[@"英语单词",@"英语词组",@"英语专有名词",@"英语句法",@"英语常用表达",@"ESP"];
    
    [self.view addSubview:self.serverTitleLab];
    [self.serverTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.equalTo(self.serverTitleLab.mas_bottom).offset(5);
       make.centerX.equalTo(self.view);
       make.left.equalTo(self.view).offset(20);
       make.height.mas_equalTo(30);
    }];
    [self.textField yj_clipLayerWithRadius:15 width:1 color:[UIColor orangeColor]];
    self.textField.text =  @"http://60.190.136.238:18318";
    
    [self.view addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textField.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [self.segment yj_clipLayerWithRadius:0 width:1 color:[UIColor lightGrayColor]];
    self.segment.titles = @[@"小学(初级)",@"初中(初级)",@"高中(中级)",@"中职(初级)",@"高职(中级)",@"大外(高级)",@"英专(高级)",@"研究生(高级)",@"雅思(高级)",@"ESP"];
    self.studyLevelArr = @[@"A",@"B",@"C",@"D",@"E",@"F",@"H",@"J",@"K",@""];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segment.mas_bottom).offset(30);
        make.centerX.left.bottom.equalTo(self.view);
    }];
}
- (void)testType:(UISegmentedControl *)sender {
    LGKnowledgeManager.defaultManager.testLevel = sender.selectedSegmentIndex;
}
- (void)yj_dynamicSegment:(YJDynamicSegment *)dynamicSegment didSelectItemAtIndex:(NSInteger)index{
    self.currentIndex = index;
    if (index == self.studyLevelArr.count - 1) {
        self.dataArr = @[@"ESP"];
    }else{
        self.dataArr = @[@"英语单词",@"英语词组",@"英语专有名词",@"英语句法",@"英语常用表达"];
    }
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.textField.text.length == 0) {
        [LGAlert showInfoWithStatus:@"配置地址不能为空"];
    }else{
        NSString *versionCode = [self.studyLevelArr objectAtIndex:self.currentIndex];
        KlgViewController *klgVC = [[KlgViewController alloc] init];
        klgVC.TypeName = self.dataArr[indexPath.row];
        klgVC.klgUrl = self.textField.text;
        klgVC.versionCode = versionCode;
        [self.navigationController pushViewController:klgVC animated:YES];
    }
}
- (UILabel *)serverTitleLab{
    if (!_serverTitleLab) {
        _serverTitleLab = [UILabel new];
        _serverTitleLab.text = @"系统ID\"A00\"的配置地址:";
        _serverTitleLab.textColor = [UIColor lightGrayColor];
    }
    return _serverTitleLab;
}
- (YJTextField *)textField{
    if (!_textField) {
        _textField = [[YJTextField alloc] initWithFrame:CGRectZero];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.placeholder = @"请输入配置地址...";
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.tintColor = [UIColor lightGrayColor];
        
    }
    return _textField;
}
- (UISegmentedControl *)segControll{
    if (!_segControll) {
        _segControll = [[UISegmentedControl alloc] initWithItems:@[@"默认",@"初级",@"中级",@"高级"]];
         _segControll.selectedSegmentIndex = 0;
        _segControll.tintColor = [UIColor orangeColor];
        [_segControll addTarget:self action:@selector(testType:) forControlEvents:UIControlEventValueChanged];
        [_segControll yj_iOS13Style];
    }
    return _segControll;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 44;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}
- (YJDynamicSegment *)segment{
    if (!_segment) {
        _segment = [YJDynamicSegment new];
        _segment.pageItems = 4;
        _segment.normalColor = [UIColor yj_colorWithHex:0x8c8c8c];
        _segment.selectColor = [UIColor yj_colorWithHex:0x45bcfa];
        _segment.delegate = self;
    }
    return _segment;
}
@end
