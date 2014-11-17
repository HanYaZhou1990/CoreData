//
//  HYZTableViewController.m
//  HYZCoreData
//
//  Created by hanyazhou on 14-11-18.
//  Copyright (c) 2014年 韩亚周. All rights reserved.
//

#import "HYZTableViewController.h"

@interface HYZTableViewController ()

@end

@implementation HYZTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)addOneDataToTableView:(UIBarButtonItem *)sender{
    switch (sender.tag) {
        case 10:
        {
        [[HYZSqlite shareSqlite] insertCoreData:@{@"test":@"0",@"test1":@"1",@"test2":@"2",@"test3":@"3",@"test4":@"4",@"time":[HYZSqlite getNowTimeStamp]} tableName:@"MyTest"];
        }
            break;
        case 11:
        {
        for (MyTest *test in [[HYZSqlite shareSqlite] dataFetchRequestWithTableName:@"MyTest"]) {
            [_messageArray addObject:test.time];
            [self.tableView reloadData];
        }
        }
            break;
        case 12:
        {
//        如果test1  的值为  “1”  替换成 “5”
        [[HYZSqlite shareSqlite] updataCoreData:@"5" tableName:@"MyTest" predicateTitle:@"test1" predicate:@"1"];
        /*替换完成以后，可以再searchbar中输入 5 ，然后搜索，你会发现，修改成功了*/
        }
            break;
        case 13:
        {
//        删除test1  对应的值是  5 的所有数据
        [[HYZSqlite shareSqlite] delCoreDataWithTableName:@"MyTest" predicateTitle:@"test1" predicate:@"5"];
        }
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     首先点击加号插入一部分数据，然后用工具打开数据库，修改一下数据，这里是修改的test1的，根据自己的爱好修改，
     刷新，是读取数据库中得所有数据，并展示出来，展示的是存数据的时候的时间
     titleview的搜索框，是根据test1的值，进行搜索，点击键盘的search进行搜索，搜索出和searchbar中输入的值相同的数据
     cancle按钮，是删除的，删除test1的值为5的所有数据
     edit按钮，是将test1下的值为1的所有数据，替换成5
     可以先点加号，插入数据，然后搜索test1的值为 “1”的所有数据，然后点击edit，将所有test1的值为“1”的替换成 “5”，然后，搜索为test1为“1”的数据，应该是搜不到的，这个时候可以搜索test1为 “5”的，可以搜到所有的数据，然后点cancle，可以删除所有的数据，最后点击刷新，发现没有数据了
     */
    
    _messageArray = [NSMutableArray array];
//    输入一个数字，搜索出数据库中test1对应的某数据
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
    
//    数据库中是没有数据的，先插几条数据，再进行测试
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addOneDataToTableView:)];
    addItem.tag = 10;
    
//    如果数据库中插入过数据，可以用来刷新表
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(addOneDataToTableView:)];
    refreshItem.tag = 11;
    
    self.navigationItem.rightBarButtonItems = @[addItem,refreshItem];
    
//    用来修改test1所对应的值，如果是1，就替换成5，如果想修改别的，请自行修改相应参数
    UIBarButtonItem *changeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(addOneDataToTableView:)];
    changeItem.tag = 12;
    
//    删除test1为 “5”的所有数据
    UIBarButtonItem *delItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(addOneDataToTableView:)];
    delItem.tag = 13;
    
    self.navigationItem.leftBarButtonItems = @[changeItem,delItem];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark  -
#pragma mark  Table view data source -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_messageArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [HYZSqlite timeConversion:_messageArray[indexPath.row]];
    return cell;
}

#pragma mark -
#pragma mark Table view Delegate -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma  mark -
#pragma  mark UISearchBarDelegate -
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    /*尝试根据谓词查询表成功*/
    [_messageArray removeAllObjects];
    for (MyTest *test in [[HYZSqlite shareSqlite] dataFetchRequestWithTableName:@"MyTest" predicateTitle:@"test1" predicate:searchBar.text]) {
        [_messageArray addObject:test.time];
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning{[super didReceiveMemoryWarning];}

@end
