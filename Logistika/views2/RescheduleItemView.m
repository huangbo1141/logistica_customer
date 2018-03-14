//
//  RescheduleItemView.m
//  Logistika
//
//  Created by BoHuang on 4/27/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "RescheduleItemView.h"
#import "ReviewCameraTableViewCell.h"
#import "ReviewItemTableViewCell.h"
#import "ReviewPackageTableViewCell.h"
#import "NetworkParser.h"
#import "TopBarView.h"
#import "AppDelegate.h"

@implementation RescheduleItemView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)firstProcess:(int)mode{
    UIDatePicker* date = [[UIDatePicker alloc] init];
    date.date = [NSDate date];
    date.datePickerMode = UIDatePickerModeDateAndTime;
    self.txtNewDate.inputView = date;
    self.datePicker = date;
    
    [date addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    date.tag = 200;
    
    self.dateModel = [[DateModel alloc] initWithDictionary:nil];
    
    switch (mode) {
        case 1:
        {
            // cancel mode
            self.viewNewDate.hidden = true;
            [self.btnAction setTitle:@"Cancel Pick up" forState:UIControlStateNormal];
            break;
        }
            
        default:{
            break;
        }
    }
    self.mode = mode;
}
- (IBAction)toggleShow:(id)sender {
    BOOL hidden =  self.viewContent.hidden;
    self.viewContent.hidden = !hidden;
    if (!hidden) {
        self.imgDrop.image = [UIImage imageNamed:@"down.png"];
    }else{
        self.imgDrop.image = [UIImage imageNamed:@"up.png"];
    }
}

- (IBAction)clickAction:(id)sender {
    switch (self.mode) {
        case 1:
        {
            // cancel
            [CGlobal showIndicator:self.vc];
            NetworkParser* manager = [NetworkParser sharedManager];
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            params[@"id"] = self.data.orderId;
            
            [manager ontemplateGeneralRequest2:params BasePath:BASE_URL_ORDER Path:@"cancel_order" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
                if (error == nil) {
                    if (dict!=nil && dict[@"result"] != nil) {
                        //
                        if([dict[@"result"] intValue] == 400){
                            NSString* message = @"Fail";
                            [CGlobal AlertMessage:message Title:nil];
                        }else if ([dict[@"result"] intValue] == 200){
                            NSString* message = @"Success";
                            [CGlobal AlertMessage:message Title:nil];
                            
                            // change page
                            AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                            [delegate goHome:self.vc];
                            return;
                        }
                    }
                    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegate goHome:self.vc];
                    return;
                }else{
                    NSLog(@"Error");
                }
                [CGlobal stopIndicator:self.vc];
            } method:@"POST"];
            return;
        }
        default:{
            NSString* val = self.txtNewDate.text;
            if (val!=nil && [val length] > 0) {
                [CGlobal showIndicator:self.vc];
                NetworkParser* manager = [NetworkParser sharedManager];
                NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
                params[@"id"] = self.data.orderId;
                params[@"date"] = self.dateModel.date;
                params[@"time"] = self.dateModel.time;
                
                [manager ontemplateGeneralRequest2:params BasePath:BASE_URL_ORDER Path:@"reschedule" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
                    if (error == nil) {
                        if (dict!=nil && dict[@"result"] != nil) {
                            //
                            if([dict[@"result"] intValue] == 400){
                                NSString* message = @"Fail";
                                [CGlobal AlertMessage:message Title:nil];
                            }else if ([dict[@"result"] intValue] == 200){
                                NSString* message = @"Success";
                                [CGlobal AlertMessage:message Title:nil];
                                
                                // change page
                                AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                [delegate goHome:self.vc];
                                return;
                            }
                        }
                        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        [delegate goHome:self.vc];
                        return;
                    }else{
                        NSLog(@"Error");
                    }
                    [CGlobal stopIndicator:self.vc];
                } method:@"POST"];
            }else{
                [CGlobal AlertMessage:@"Choose Date" Title:nil];
            }
            return;
        }
    }
    
}

-(void)setModelData:(OrderRescheduleModel*)model VC:(UIViewController*)vc{
    if (model.addressModel.desAddress!=nil) {
        _lblPickAddress.text = model.addressModel.sourceAddress;
        _lblPickCity.text = model.addressModel.sourceCity;
        _lblPickState.text = model.addressModel.sourceState;
        _lblPickPincode.text = model.addressModel.sourcePinCode;
        _lblPickPhone.text = model.addressModel.sourcePhonoe;
        _lblPickLandMark.text = model.addressModel.sourceLandMark;
        _lblPickInst.text = model.addressModel.sourceInstruction;
        _lblPickName.text = model.addressModel.sourceName;
        
        _lblDestAddress.text = model.addressModel.desAddress;
        _lblDestCity.text = model.addressModel.desCity;
        _lblDestState.text = model.addressModel.desState;
        _lblDestPincode.text = model.addressModel.desPinCode;
        _lblDestPhone.text = model.addressModel.desPhone;
        _lblDestLandMark.text = model.addressModel.desLandMark;
        _lblDestInst.text = model.addressModel.desInstruction;
        _lblDestName.text = model.addressModel.desName;
    }
//    _lblDestPhone.hidden = true;
    
    self.lblServiceLevel.text = [NSString stringWithFormat:@"%@, %@%@, %@",model.serviceModel.name,symbol_dollar,model.serviceModel.price,model.serviceModel.time_in];
    UIFont* font = [UIFont boldSystemFontOfSize:_lblServiceLevel.font.pointSize];
    _lblServiceLevel.font = font;
    self.lblPaymentMethod.text = [NSString stringWithFormat:@"%@",model.payment];
    
    self.txtCurrentDate.text = [NSString stringWithFormat:@"%@ %@",model.dateModel.date,model.dateModel.time];
    
    
    self.dateModel = [[DateModel alloc] initWithDictionary:nil];
    [self showItemLists:model];
    self.txtNewDate.text = @"";
    
    self.lblTracking.text = model.trackId;
    self.lblOrderNumber.text = model.orderId;
    self.data = model;

    [self hideAddressFields];
}
-(void)hideAddressFields{
//    _lblPickAddress.hidden = true;
    _lblPickCity.hidden = true;
    _lblPickState.hidden = true;
    _lblPickPincode.hidden = true;
    
    //    _lblDestAddress.hidden = true;
    _lblDestCity.hidden = true;
    _lblDestState.hidden = true;
    _lblDestPincode.hidden = true;
    
    _lblPickAddress.numberOfLines = 0;
    _lblDestAddress.numberOfLines = 0;
}
-(void)timeChanged:(UIDatePicker*)picker{
    int tag = (int)picker.tag;
    switch (tag) {
        case 200:
        {
            NSDate* myDate = picker.date;
            
            if ([CGlobal compareWithToday:myDate DateStr:nil mode:2] == NSOrderedDescending) {
                [CGlobal AlertMessage:@"Pickup Date should not be in the past" Title:nil];
                return;
            }
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd-MM-yyyy hh:mm a"];
            NSString *prettyVersion = [dateFormat stringFromDate:myDate];
            _txtNewDate.text = prettyVersion;
            
            [dateFormat setDateFormat:@"dd-MM-yyyy"];
            prettyVersion = [dateFormat stringFromDate:myDate];
            self.dateModel.date = prettyVersion;
            
            [dateFormat setDateFormat:@"hh:mm a"];
            prettyVersion = [dateFormat stringFromDate:myDate];
            self.dateModel.time = prettyVersion;
            break;
        }
            
        default:
            break;
    }
}
-(void)showItemLists:(OrderRescheduleModel*)model{
    self.orderModel = model.orderModel;
    if (model.orderModel.product_type == g_CAMERA_OPTION) {
        
        self.viewHeader_CAMERA.hidden = false;
        self.viewHeader_ITEM.hidden = true;
        self.viewHeader_PACKAGE.hidden = true;
        
        UINib* nib = [UINib nibWithNibName:@"ReviewCameraTableViewCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        self.cellHeight = 40;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }else if(model.orderModel.product_type == g_ITEM_OPTION){
        self.viewHeader_CAMERA.hidden = true;
        self.viewHeader_ITEM.hidden = false;
        self.viewHeader_PACKAGE.hidden = true;
        
        UINib* nib = [UINib nibWithNibName:@"ReviewItemTableViewCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
        self.cellHeight = 40;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }else if(model.orderModel.product_type == g_PACKAGE_OPTION){
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
- (IBAction)clickArrow:(id)sender {
    [self toggleShow:sender];
}
@end
