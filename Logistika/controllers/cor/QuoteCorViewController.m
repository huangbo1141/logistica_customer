//
//  QuoteCorViewController.m
//  Logistika
//
//  Created by BoHuang on 4/27/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "QuoteCorViewController.h"
#import "NetworkParser.h"
#import "CGlobal.h"
#import "QuoteCoperationModel.h"
#import "OrderResponse.h"
#import "ViewScrollContainer.h"
#import "QuoteCorItemView.h"
#import "QuoteCoperationModel.h"
#import "DateTimeViewController.h"

@interface QuoteCorViewController ()
@property(nonatomic,strong) OrderResponse*response;
@property(nonatomic,assign) int index;
@end

@implementation QuoteCorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _index = -1;
    [self loadData];
    if (g_priceType == nil) {
        g_priceType = [[PriceType alloc] init];
    }
    
    self.viewRoot.backgroundColor = COLOR_SECONDARY_THIRD;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.topBarView.caption.text = @"Quotes";
}
-(void)addViews{
    // determine area
    _index = -1;
    CGRect bound = [[UIScreen mainScreen] bounds];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat headerHeight = self.topBarView.constraint_Height.constant;
    CGFloat topSpace = statusHeight+headerHeight + 50;
    CGRect rect = CGRectMake(0, topSpace, bound.size.width, bound.size.height - topSpace);
    
    CGFloat dx = 0;
    CGFloat dy = 0;
    CGRect newRect = CGRectInset(rect, dx, dy);
    
    for (UIView *subview in self.viewRoot.subviews)
    {
        [subview removeFromSuperview];
    }
    self.views = [[NSMutableArray alloc] init];
    
    ViewScrollContainer* scrollContainer = (ViewScrollContainer*)[[NSBundle mainBundle] loadNibNamed:@"ViewScrollContainer" owner:self options:nil][0];
    for (int i=0; i<self.response.orders.count; i++) {
        QuoteCoperationModel*model = self.response.orders[i];
        QuoteCorItemView* itemView = (QuoteCorItemView*)[[NSBundle mainBundle] loadNibNamed:@"QuoteCorItemView" owner:self options:nil][0];
        [itemView firstProcess:i Data:model VC:self];
        
        [scrollContainer addOneView:itemView];
        
        [self.views addObject:itemView];
        
//        if (i == self.response.orders.count - 1) {
//            itemView.viewSeperator.hidden = true;
//        }
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
    [manager ontemplateGeneralRequest2:params BasePath:BASE_URL Path:@"get_corporate_quote" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            // succ
            if (dict[@"result" ]!=nil) {
                if ([dict[@"result"] intValue] == 200) {
                    [self clearReschedule];
                    
                    // parse
                    OrderResponse* response = [[OrderResponse alloc] initWithDictionary_quote_cor:dict];
                    self.response = response;
                    
                    if (self.response.orders.count == 0) {
                        [CGlobal stopIndicator:self];
                        [CGlobal AlertMessage:@"No Orders" Title:nil];
                    }else{
                        [self addViews];
                        [CGlobal stopIndicator:self];
                    }
                    
                    return;
                }
            }
            
        }else{
            // error
            NSLog(@"Error");
        }
        
        [CGlobal stopIndicator:self];
        [CGlobal AlertMessage:@"No Orders" Title:nil];
    } method:@"POST"];
}
-(void)clearReschedule{
    g_quoteCoperationModels = [[NSMutableArray alloc] init];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)didSubmit:(id)obj View:(UIView *)view{
    if ([view isKindOfClass:[QuoteCorItemView class]]  ) {
        NSDictionary*dic = obj;
        NSString* action = dic[@"action"];
        NSNumber* val = dic[@"value"];
        NSNumber* mode = dic[@"mode"];
        UISwitch* sw = dic[@"sw"];
        
        for (QuoteCorItemView*view in _views) {
            
            [view.swSelect setOn:false];
        }
        if ([val intValue] == 1) {
            [sw setOn:true];
            _index = [mode intValue];
        }else{
            [sw setOn:false];
            _index = -1;
        }
        
    }
}
- (IBAction)clickAction:(id)sender {
    if (self.index>=0) {
        QuoteCoperationModel* model = self.response.orders[self.index];
        
        g_quoteCoperationModel = model;
        EnvVar* env = [CGlobal sharedId].env;
        env.quote_id = model.quote_id;
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        params[@"quote_id"] = model.quote_id;
        
        NetworkParser* manager = [NetworkParser sharedManager];
        [CGlobal showIndicator:self];
        [manager ontemplateGeneralRequest2:params BasePath:BASE_URL Path:@"get_service" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
            if (error == nil) {
                if (dict!=nil && dict[@"result"] != nil) {
                    //
                    if([dict[@"result"] intValue] == 200){
                        NSArray* jsonArray = dict[@"service"];
                        NSDictionary*serviceObj = jsonArray[0];
                        g_priceType.expeditied_price = serviceObj[@"expedited_price"];
                        g_priceType.express_price = serviceObj[@"express_price"];
                        g_priceType.economy_price = serviceObj[@"economy_price"];
                        
                        g_priceType.expedited_duration = serviceObj[@"expedited_duration"];
                        g_priceType.express_duration = serviceObj[@"express_duration"];
                        g_priceType.economy_duraiton = serviceObj[@"economy_duration"];
                        
                        EnvVar* env = [CGlobal sharedId].env;
                        env.quote = true;
//                        g_ORDER_TYPE = model.orderModel.product_type;
//                        g_cameraOrderModel = model.orderModel;
                        g_quote_order_id = model.orderId;
                        g_quote_id = model.quote_id;
                        g_addressModel = model.addressModel;
                        
                        UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
                        DateTimeViewController* vc = [ms instantiateViewControllerWithIdentifier:@"DateTimeViewController"];
                        [self.navigationController pushViewController:vc animated:true];
                        [CGlobal stopIndicator:self];
                        return;
                    }
                }
            }
            [CGlobal stopIndicator:self];
        } method:@"POST"];
    }else{
        if (self.response.orders.count > 0) {
            [CGlobal AlertMessage:@"Choose a Order" Title:nil];
        }
        
    }
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
