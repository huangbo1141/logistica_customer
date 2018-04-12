//
//  OrderItemView.h
//  Logistika
//
//  Created by BoHuang on 4/27/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "OrderBaseView.h"
#import "OrderModel.h"
#import "DateModel.h"
#import "OrderHisModel.h"

@interface OrderItemView : OrderBaseView<UITableViewDelegate,UITableViewDataSource>
//@property (weak, nonatomic) IBOutlet UITextField *txtCurrentDate;
//@property (weak, nonatomic) IBOutlet UITextField *txtNewDate;
@property (weak, nonatomic) IBOutlet UIStackView *stackRoot;

@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_TH;

@property (weak, nonatomic) IBOutlet UIView *viewHeader;

@property (weak, nonatomic) IBOutlet UIView *viewHeader_CAMERA;
@property (weak, nonatomic) IBOutlet UIView *viewHeader_ITEM;
@property (weak, nonatomic) IBOutlet UIView *viewHeader_PACKAGE;

//@property (weak, nonatomic) IBOutlet UIButton *btnAction;

@property (weak, nonatomic) IBOutlet UITableView *tableView_items;

@property (weak, nonatomic) IBOutlet UILabel *lblPickName;
@property (weak, nonatomic) IBOutlet UILabel *lblPickAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblPickCity;
@property (weak, nonatomic) IBOutlet UILabel *lblPickState;
@property (weak, nonatomic) IBOutlet UILabel *lblPickPincode;
@property (weak, nonatomic) IBOutlet UILabel *lblPickPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPickLandMark;
@property (weak, nonatomic) IBOutlet UILabel *lblPickInst;

@property (weak, nonatomic) IBOutlet UILabel *lblDestAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblDestCity;
@property (weak, nonatomic) IBOutlet UILabel *lblDestState;
@property (weak, nonatomic) IBOutlet UILabel *lblDestPincode;
@property (weak, nonatomic) IBOutlet UILabel *lblDestPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblDestLandMark;
@property (weak, nonatomic) IBOutlet UILabel *lblDestInst;
@property (weak, nonatomic) IBOutlet UILabel *lblDestName;

@property (weak, nonatomic) IBOutlet UILabel *lblPickDate;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceLevel;
@property (weak, nonatomic) IBOutlet UILabel *lblPaymentMethod;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
//@property (weak, nonatomic) IBOutlet UIView *viewNewDate;

@property (weak, nonatomic) IBOutlet UILabel *lblTracking;
@property (weak, nonatomic) IBOutlet UILabel *lblOrderNumber;

-(void)setModelData:(OrderHisModel*)model VC:(UIViewController*)vc;
-(void)firstProcess:(int)mode Data:(OrderHisModel*)model VC:(UIViewController*)vc;
@property (assign, nonatomic) int mode;
@property (assign, nonatomic) CGFloat cellHeight;
@property (strong, nonatomic) OrderModel* orderModel;
@property (strong, nonatomic) OrderHisModel* data;

@property (strong, nonatomic) DateModel* dateModel;



@property (assign, nonatomic) BOOL modelSet;

@property (weak, nonatomic) IBOutlet UIImageView *imgDrop;

@property (weak, nonatomic) IBOutlet UIImageView *imgStep;
@property (weak, nonatomic) IBOutlet UIImageView *imgPos;

@property (weak, nonatomic) IBOutlet UIButton *btnPos;

@property (nonatomic,strong) NSMutableDictionary* height_dict;
@property (nonatomic,assign) CGFloat totalHeight;

@end



