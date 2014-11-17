//
//  HYZTableViewController.h
//  HYZCoreData
//
//  Created by hanyazhou on 14-11-18.
//  Copyright (c) 2014年 韩亚周. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYZSqlite.h"

@interface HYZTableViewController : UITableViewController<UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray      *messageArray;

@end
