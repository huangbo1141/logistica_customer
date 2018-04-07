//
//  DateTimeViewController.m
//  Logistika
//
//  Created by BoHuang on 4/22/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "DateTimeViewController.h"
#import "CGlobal.h"
#import "NSArray+BVJSONString.h"
#import "NetworkParser.h"
#import "AppDelegate.h"
#import "ReviewOrderViewController.h"

@interface DateTimeViewController ()
@property (assign,nonatomic) int index;
@property (assign,nonatomic) BOOL chooseService;
@property (strong,nonatomic) NSDate* tempDate;

@end

@implementation DateTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chooseService = false;
    self.index = -1;
    
    self.view.backgroundColor = COLOR_SECONDARY_THIRD;
    
    NSArray* fields = @[self.txtEmailAddress];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, 200, 30);
    for (int i=0; i<fields.count; i++) {
        if ([fields[i] isKindOfClass:[BorderTextField class]]) {
            BorderTextField*field = fields[i];
            [field addBotomLayer:frame];
        }
    }
    if (g_mode == c_GUEST) {    //|| g_mode == c_CORPERATION
        
    }else{
        self.const_MAIN_TOP.constant = 20;
        self.const_EMAIL_TOP.constant = -200;
    }
    
    // Do any additional setup after loading the view.
    UIDatePicker* date = [[UIDatePicker alloc] init];
    date.date = [NSDate date];
    date.datePickerMode = UIDatePickerModeDate;
    self.txtDate.inputView = date;
    
    UIDatePicker*time = [[UIDatePicker alloc] init];
    time.date = [NSDate date];
    time.datePickerMode = UIDatePickerModeTime;
    self.txtTime.inputView = time;
    
    [date addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    date.tag = 200;
    
    [time addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    time.tag = 201;
    
    UITapGestureRecognizer* gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [_viewPrice1 addGestureRecognizer:gesture1];
    _viewPrice1.tag = 200;
    _viewPrice1.userInteractionEnabled = true;
    
    UITapGestureRecognizer* gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [_viewPrice2 addGestureRecognizer:gesture2];
    _viewPrice2.tag = 201;
    _viewPrice2.userInteractionEnabled = true;
    
    UITapGestureRecognizer* gesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [_viewPrice3 addGestureRecognizer:gesture3];
    _viewPrice3.tag = 202;
    _viewPrice3.userInteractionEnabled = true;
    
    NSDate* myDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    NSString *prettyVersion = [dateFormat stringFromDate:myDate];
    _txtDate.text = prettyVersion;
    
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *prettyVersion2 = [dateFormat stringFromDate:myDate];
    _txtTime.text = prettyVersion2;
    
    if (g_dateModel!=nil && g_dateModel.time!=nil) {
        _txtTime.text = g_dateModel.time;
    }else{
        if (g_dateModel == nil) {
            g_dateModel = [[DateModel alloc] initWithDictionary:nil];
        }
        g_dateModel.time = _txtTime.text;
    }
    if (g_dateModel!=nil && g_dateModel.date!=nil) {
        _txtDate.text = g_dateModel.date;
    }else{
        if (g_dateModel == nil) {
            g_dateModel = [[DateModel alloc] initWithDictionary:nil];
        }
        g_dateModel.date = _txtDate.text;
    }
    
    EnvVar* env = [CGlobal sharedId].env;
    if (env.mode != c_CORPERATION) {
        [self addService];
    }else{
        if(env.quote ){
            [self addService];
            [self.btnReview setTitle:@"Continue" forState:UIControlStateNormal];
        }else{
            self.viewExpress.hidden = true;
            [self.btnReview setTitle:@"Send Email" forState:UIControlStateNormal];
        }
    }
    
    if (g_serviceModel == nil) {
        g_serviceModel = [[ServiceModel alloc] init];
    }
}
- (IBAction)clickView1:(id)sender {
    [self chooseService:0];
}
- (IBAction)clickView2:(id)sender {
    [self chooseService:1];
}
- (IBAction)clickView3:(id)sender {
    [self chooseService:2];
}

-(void)addService{
    NSString* pre = [NSString stringWithFormat:@"%@%.4f",symbol_dollar, [g_priceType.expeditied_price floatValue]];
    self.lblPrice1_2.text = pre;
    self.lblPrice1_3.text = g_priceType.expedited_duration;
    
    self.lblPrice2_2.text = [NSString stringWithFormat:@"%@%.4f",symbol_dollar, [g_priceType.express_price floatValue]];
    self.lblPrice2_3.text = g_priceType.express_duration;
    
    self.lblPrice3_2.text = [NSString stringWithFormat:@"%@%.4f",symbol_dollar, [g_priceType.economy_price floatValue]];
    self.lblPrice3_3.text = g_priceType.economy_duraiton;
    
    if (g_serviceModel!=nil && g_serviceModel.name!=nil) {
        if([g_serviceModel.name isEqualToString:@"Expedited"]){
            [self chooseService:0];
        }else if([g_serviceModel.name isEqualToString:@"Express"]){
            [self chooseService:1];
        }else if([g_serviceModel.name isEqualToString:@"Economy"]){
            [self chooseService:2];
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.title = @"Date & Time";
    self.navigationController.navigationBar.hidden = false;
    _txtEmailAddress.text = eamil_guest;
}
-(void)tapView:(UITapGestureRecognizer*)gesture{
    if (gesture.view!=nil) {
        int tag = (int)gesture.view.tag;
        int index = tag - 200;
        [self chooseService:index];
    }
}
-(void)chooseService:(int)index{
    self.chooseService = true;
    NSArray* array = @[self.viewPrice1,self.viewPrice2,self.viewPrice3];
    
    NSArray* array1 = @[self.lblPrice1_1,self.lblPrice2_1,self.lblPrice3_1];
    NSArray* array2 = @[self.lblPrice1_2,self.lblPrice2_2,self.lblPrice3_2];
    NSArray* array3 = @[self.lblPrice1_3,self.lblPrice2_3,self.lblPrice3_3];
    
    
    for (int i=0; i< array1.count; i++) {
        UILabel* label = array1[i];
        label.textColor = [UIColor blackColor];
    }
    for (int i=0; i< array2.count; i++) {
        UILabel* label = array2[i];
        label.textColor = [UIColor blackColor];
    }
    for (int i=0; i< array3.count; i++) {
        UILabel* label = array3[i];
        label.textColor = [UIColor blackColor];
    }
    
    for (int i=0; i< array.count; i++) {
        UIView* view = array[i];
        view.backgroundColor = [UIColor clearColor];
    }
    UIView* view = array[index];
    view.backgroundColor = COLOR_PRIMARY;
    
    UILabel*label1 = array1[index];
    UILabel*label2 = array2[index];
    UILabel*label3 = array3[index];
    label1.textColor = [UIColor whiteColor];
    label2.textColor = [UIColor whiteColor];
    label3.textColor = [UIColor whiteColor];
    
    g_serviceModel.name = ((UILabel*)array1[index]).text;
    g_serviceModel.price = [((UILabel*)array2[index]).text stringByReplacingOccurrencesOfString:symbol_dollar withString:@""];
    g_serviceModel.time_in = ((UILabel*)array3[index]).text;
    
    
    self.index = index;
    
    [self showEstmiatedDate];
}
-(void)timeChanged:(UIDatePicker*)picker{
    int tag = (int)picker.tag;
    switch (tag) {
        case 200:
        {
            NSDate* myDate = picker.date;
            
            if ([CGlobal compareWithToday:myDate DateStr:nil mode:0] == NSOrderedDescending) {
                [CGlobal AlertMessage:@"Pickup date should not be in the past" Title:nil];
                return;
            }
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd-MM-yyyy"];
            NSString *prettyVersion = [dateFormat stringFromDate:myDate];
            _txtDate.text = prettyVersion;
            
            g_dateModel.date = prettyVersion;
            
            self.tempDate = myDate;
            
            [self showEstmiatedDate];
            break;
        }
        case 201:{
            NSDate* myDate = picker.date;
            if (self.tempDate == nil) {
                self.tempDate = [NSDate date];
            }
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd"];
            NSString *datestr = [dateFormat stringFromDate: self.tempDate];
            
            if ([CGlobal compareWithToday:myDate DateStr:datestr mode:1] == NSOrderedDescending) {
                [CGlobal AlertMessage:@"Pickup time should not be in the past" Title:nil];
                return;
            }
            
            dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"hh:mm a"];
            NSString *prettyVersion = [dateFormat stringFromDate:myDate];
            _txtTime.text = prettyVersion;
            
            g_dateModel.time = prettyVersion;
            
            [self showEstmiatedDate];
            break;
        }
            
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    eamil_guest = _txtEmailAddress.text;
}
- (IBAction)clickContinue:(id)sender {
    
    UIDatePicker* picker = self.txtTime.inputView;
    NSDate* myDate = picker.date;
    if (self.tempDate == nil) {
        self.tempDate = [NSDate date];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *datestr = [dateFormat stringFromDate: self.tempDate];
    
    if ([CGlobal compareWithToday:myDate DateStr:datestr mode:1] == NSOrderedDescending) {
        [CGlobal AlertMessage:@"Pickup time should not be in the past" Title:nil];
        return;
    }
    
    EnvVar* env = [CGlobal sharedId].env;
    if (env.mode != c_CORPERATION || env.quote ) {
        
        if (self.index>=0) {
            
            if (g_mode == c_GUEST) {
                NSString* email = _txtEmailAddress.text;
                if(![CGlobal isValidEmail:email]){
                    [CGlobal AlertMessage:@"Check Email" Title:nil];
                    return;
                }
                
                /// Capturing guest email, Used in Payment viewcontroller
                g_guestEmail = email;
            }
            UIStoryboard *ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
            ReviewOrderViewController* vc = [ms instantiateViewControllerWithIdentifier:@"ReviewOrderViewController"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:vc animated:true];
            });
        }else{
            [CGlobal AlertMessage:@"Choose Service" Title:nil];
        }
    }else{
        [self order_corporate];
    }
}
-(void)order_corporate{
    EnvVar* env = [CGlobal sharedId].env;
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    params[@"id"] = env.cor_order_id;
    params[@"user_id"] = env.corporate_user_id;
    params[@"name"] = g_corporateModel.name;
    params[@"address"] = g_corporateModel.address;
    params[@"phone"] = g_corporateModel.phone;
    params[@"description"] = g_corporateModel.details;
    params[@"truck"] = g_corporateModel.truck;
    params[@"date"] = g_dateModel.date;
    params[@"time"] = g_dateModel.time;
    
    NSDictionary*jsonMap = @{@"s_address":g_addressModel.sourceAddress
                             ,@"s_area":g_addressModel.sourceArea
                             ,@"s_city":g_addressModel.sourceCity
                             ,@"s_state":g_addressModel.sourceState
                             ,@"s_pincode":g_addressModel.sourcePinCode
                             ,@"s_phone":[NSString stringWithFormat:@"%@:%@",g_addressModel.sourcePhonoe,g_addressModel.sourceName]
                             ,@"s_landmark":g_addressModel.sourceLandMark
                             ,@"s_instruction":g_addressModel.sourceInstruction
                             ,@"s_lat":[[NSNumber numberWithDouble:g_addressModel.sourceLat] stringValue]
                             ,@"s_lng":[[NSNumber numberWithDouble:g_addressModel.sourceLng] stringValue]
                             ,@"d_address":g_addressModel.desAddress
                             ,@"d_area":g_addressModel.desArea
                             ,@"d_city":g_addressModel.desCity
                             ,@"d_state":g_addressModel.desState
                             ,@"d_pincode":g_addressModel.desPinCode
                             ,@"d_landmark":g_addressModel.desLandMark
                             ,@"d_instruction":g_addressModel.desInstruction
                             ,@"d_lat":[[NSNumber numberWithDouble:g_addressModel.desLat] stringValue]
                             ,@"d_lng":[[NSNumber numberWithDouble:g_addressModel.desLng] stringValue]
                             ,@"d_phone":g_addressModel.desPhone
                             ,@"d_name":g_addressModel.desName
                             };
    
    NSArray*addressArray = @[jsonMap];
    params[@"orderaddress"] = [addressArray bv_jsonStringWithPrettyPrint:true];
    
    NetworkParser* manager = [NetworkParser sharedManager];
    [CGlobal showIndicator:self];
    [manager ontemplateGeneralRequest2:params BasePath:BASE_URL_ORDER Path:@"order_corporate" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            if (dict!=nil && dict[@"result"] != nil) {
                //
                if([dict[@"result"] intValue] == 400){
                    NSString* message = [[NSBundle mainBundle] localizedStringForKey:@"quote_message" value:@"" table:nil];
                    [CGlobal AlertMessage:message Title:nil];
                }else if ([dict[@"result"] intValue] == 200){
                    NSString* order_id = dict[@"order_id"];
                    NSString* content = [[NSBundle mainBundle] localizedStringForKey:@"email_corporation" value:@"" table:nil];
                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:content delegate:self cancelButtonTitle:nil otherButtonTitles:@"I Agree", nil];
                    alert.tag = 200;
                    [alert show];
                    g_page_type = @"";
                }
            }
        }else{
            NSLog(@"Error");
        }
        [CGlobal stopIndicator:self];
    } method:@"POST"];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    int tag = (int)alertView.tag;
    if (tag == 200) {
        if (buttonIndex == 0) {
            g_page_type = @"";
            // go home
            AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [delegate goHome:self];
        }
    }
}
-(void) showEstmiatedDate
{
    if (self.index<0 || [self.txtTime.text length] ==0 || [self.txtDate.text length] == 0) {
        return;
    }
    //hh:mm a
    NSString* hour_str = [_txtTime.text substringFrom:0 to:2];
    NSString* min_str = [_txtTime.text substringFrom:3 to:5];
    NSString* am_str = [[_txtTime.text substringFrom:6 to:8] lowercaseString];
    
    int currentTime = [hour_str intValue];
    int selectedMinute = [min_str intValue];
    if ([am_str isEqualToString:@"pm"]) {
        currentTime = currentTime + 12;
    }
    
    int differentTime = 0;
    switch (self.index)
    {
        case 0: differentTime = 8; break;
        case 1: differentTime = 16; break;
        case 2: differentTime = 24; break;
            
    }
    int i = 0;
    if(currentTime >= 19 )
    {
        i = 1;
        currentTime = 6;
        
    }else if(currentTime < 6)
    {
        currentTime = 6;
        
    }
    while (currentTime + differentTime > 19)
    {
        differentTime = currentTime + differentTime - 19 -1;
        if(differentTime == 0 && selectedMinute == 0){
            currentTime = 20;
            break;
        }else{
            currentTime = 6;
        }
        i++;
    }
    if(i == 0)
    {
//        txtEstimated.setText(TimeHelper.getDate(year, selectedMonth, selectedDate) + " " + TimeHelper.getTime(currentTime + differentTime, selectedMinute)); //getString(R.string.estimated_time) + " " +
        self.lblEstimatedPickup.text = [NSString stringWithFormat:@"%@ %02d:%02d %@",_txtDate.text,currentTime+differentTime,selectedMinute,currentTime+differentTime<12?@"AM":@"PM"];
    }else
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        
        NSDate* date = [dateFormat dateFromString:self.txtDate.text];
        date = [date dateByAddingTimeInterval:24*60*60*i];
        
        self.lblEstimatedPickup.text = [NSString stringWithFormat:@"%@ %02d:%02d %@",[dateFormat stringFromDate:date],6+differentTime,selectedMinute,6+differentTime<12?@"AM":@"PM"];
//        Calendar calendar = Calendar.getInstance();
//        calendar.set(year, selectedMonth, selectedDate + i );
//        txtEstimated.setText(TimeHelper.getDate(calendar.get(Calendar.YEAR), calendar.get(Calendar.MONTH), calendar.get(Calendar.DAY_OF_MONTH)) + " " + TimeHelper.getTime(6 + differentTime, selectedMinute));
//        //getString(R.string.estimated_time) + " " +
        
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
