//
//  OrderHistoryViewController.h
//  Logistika
//
//  Created by BoHuang on 4/27/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "MenuViewController.h"
#import "MyPopupDialog.h"
@interface OrderHistoryViewController : MenuViewController<UITableViewDelegate,UITableViewDataSource,ViewDialogDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewSegBack;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UIView *viewRoot;
@property (weak, nonatomic) IBOutlet UIView *viewRoot1;
@property (weak, nonatomic) IBOutlet UIView *viewRoot2;
@property (weak, nonatomic) IBOutlet UIView *viewRoot3;

@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
@property (weak, nonatomic) IBOutlet UITableView *tableView3;
@end
