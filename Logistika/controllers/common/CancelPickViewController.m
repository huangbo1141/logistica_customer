//
//  CancelPickViewController.m
//  Logistika
//
//  Created by BoHuang on 4/27/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "CancelPickViewController.h"
#import "NetworkParser.h"
#import "CGlobal.h"
#import "OrderRescheduleModel.h"
#import "OrderResponse.h"

#import "ViewScrollContainer.h"
#import "RescheduleItemView.h"
#import "OrderRescheduleModel.h"

@interface CancelPickViewController ()
@property(nonatomic,strong) OrderResponse*response;
@end

@implementation CancelPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    self.view.backgroundColor = [UIColor whiteColor];
    self.viewRoot.backgroundColor = COLOR_SECONDARY_THIRD;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.topBarView.caption.text = @"Cancel A Pick Up";
}
-(void)addViews{
    // determine area
    CGRect bound = [[UIScreen mainScreen] bounds];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat headerHeight = self.topBarView.constraint_Height.constant;
    CGFloat topSpace = statusHeight+headerHeight;
    CGRect rect = CGRectMake(0, topSpace, bound.size.width, bound.size.height - topSpace);
    
    CGFloat dx = 8;
    CGFloat dy = 8;
    CGRect newRect = CGRectInset(rect, dx, dy);
    
    for (UIView *subview in self.viewRoot.subviews)
    {
        [subview removeFromSuperview];
    }
    
    ViewScrollContainer* scrollContainer = (ViewScrollContainer*)[[NSBundle mainBundle] loadNibNamed:@"ViewScrollContainer" owner:self options:nil][0];
    for (int i=0; i<self.response.orders.count; i++) {
        OrderRescheduleModel*model = self.response.orders[i];
        RescheduleItemView* itemView = (ViewScrollContainer*)[[NSBundle mainBundle] loadNibNamed:@"RescheduleItemView" owner:self options:nil][0];
        [itemView firstProcess:1];
        
        [scrollContainer addOneView:itemView];
        [itemView setModelData:model VC:self];
        itemView.vc = self;
    }
    
    if (self.response.orders.count>0) {
        [self.viewRoot addSubview:scrollContainer];
        scrollContainer.frame = CGRectMake(dx, dy, newRect.size.width, newRect.size.height);
        
    }
}
-(void)loadData{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    EnvVar* env = [CGlobal sharedId].env;
    if (env.mode == c_PERSONAL) {
        params[@"user_id"] = env.user_id;
    }else if(env.mode == c_CORPERATION){
        params[@"user_id"] = env.corporate_user_id;
    }
    NetworkParser* manager = [NetworkParser sharedManager];
    [CGlobal showIndicator:self];
    [manager ontemplateGeneralRequest2:params BasePath:BASE_URL_ORDER Path:@"get_orders" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            // succ
            if (dict[@"result" ]!=nil) {
                if ([dict[@"result"] intValue] == 200) {
                    [self clearReschedule];
                    
                    // parse
                    OrderResponse* response = [[OrderResponse alloc] initWithDictionary:dict];
                    self.response = response;
                    if (self.response.orders.count > 0) {
                        [self addViews];
                    }else{
                        [CGlobal AlertMessage:@"No Orders" Title:nil];
                    }
                    
                    [CGlobal stopIndicator:self];
                    return;
                }
            }
            
        }else{
            // error
            NSLog(@"Error");
        }
        
        [CGlobal stopIndicator:self];
    } method:@"POST"];
}
-(void)clearReschedule{
    g_cancelModels = [[NSMutableArray alloc] init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
