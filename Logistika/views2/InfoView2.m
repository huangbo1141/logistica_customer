//
//  InfoView2.m
//  Logistika
//
//  Created by BoHuang on 6/21/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "InfoView2.h"
#import "CGlobal.h"
#import "ReviewCameraTableViewCell.h"
#import "ReviewItemTableViewCell.h"
#import "ReviewPackageTableViewCell.h"

@implementation InfoView2

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setData:(NSDictionary*)data{
    [super setData:data];
    
    
    if (g_mode != c_CORPERATION) {
        self.viewItems.hidden = false;
        self.viewDetail.hidden = true;
        if (g_ORDER_TYPE == g_CAMERA_OPTION) {
            self.orderModel = g_cameraOrderModel;
            self.viewHeader_CAMERA.hidden = false;
            self.viewHeader_ITEM.hidden = true;
            self.viewHeader_PACKAGE.hidden = true;
            
            UINib* nib = [UINib nibWithNibName:@"ReviewCameraTableViewCell" bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
            self.cellHeight = 40;
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
        }else if(g_ORDER_TYPE == g_ITEM_OPTION){
            self.orderModel = g_itemOrderModel;
            self.viewHeader_CAMERA.hidden = true;
            self.viewHeader_ITEM.hidden = false;
            self.viewHeader_PACKAGE.hidden = true;
            
            UINib* nib = [UINib nibWithNibName:@"ReviewItemTableViewCell" bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
            self.cellHeight = 40;
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
        }else if(g_ORDER_TYPE == g_PACKAGE_OPTION){
            self.orderModel = g_packageOrderModel;
            self.viewHeader_CAMERA.hidden = true;
            self.viewHeader_ITEM.hidden = true;
            self.viewHeader_PACKAGE.hidden = false;
            
            UINib* nib = [UINib nibWithNibName:@"ReviewPackageTableViewCell" bundle:nil];
            [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
            self.cellHeight = 40;
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
        }
        
        [self.tableView reloadData];

    }else{
        self.viewItems.hidden = true;
        self.viewDetail.hidden = false;
        self.lblDeliver.text = g_corporateModel.details;
        self.lblLoadType.text = [CGlobal getTruck:g_corporateModel.truck];
    }
}
-(CGFloat)getHeight{
    if (g_mode != c_CORPERATION) {
        CGFloat height = self.cellHeight * self.orderModel.itemModels.count;
        height = height + 50;
        return height;
        
    }else{
        return 100;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CGFloat height = self.cellHeight * self.orderModel.itemModels.count;
    self.constraint_TH.constant = height;
    [self.tableView setNeedsUpdateConstraints];
    [self.tableView layoutIfNeeded];
    return self.orderModel.itemModels.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.orderModel.product_type == g_CAMERA_OPTION) {
        ReviewCameraTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        NSMutableDictionary* inputData = [[NSMutableDictionary alloc] init];
        inputData[@"vc"] = self.vc;
        inputData[@"indexPath"] = indexPath;
        inputData[@"aDelegate"] = self;
        inputData[@"tableView"] = tableView;
        inputData[@"model"] = self.orderModel.itemModels[indexPath.row];
        
        
        [cell setData:inputData];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(self.orderModel.product_type == g_ITEM_OPTION){
        ReviewItemTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        [cell initMe:self.orderModel.itemModels[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.aDelegate = self;
        return cell;
    }else{
        ReviewPackageTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        [cell initMe:self.orderModel.itemModels[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.aDelegate = self;
        return cell;
    }
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellHeight;
}
@end
