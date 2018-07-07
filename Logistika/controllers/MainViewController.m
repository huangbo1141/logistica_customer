//
//  MainViewController.m
//  Logistika
//
//  Created by BoHuang on 4/18/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "MainViewController.h"
#import "LeftView.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "CGlobal.h"
#import "UIView+Property.h"
#import "PersonalMainViewController.h"
#import "AppDelegate.h"
#import "MyNavViewController.h"
#import "NetworkParser.h"
#import "OrderResponse.h"
#import "TrackingViewController.h"
#import "TrackingCorViewController.h"
#import "CitySelectView.h"
#import "MyPopupDialog.h"
#import "CityModel.h"
#import "UIView+Property.h"
#import "TermViewController.h"
#import "ForgotPasswordViewController.h"
#import "ForgotUserViewController.h"
#import "AFNetworking.h"

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblLabel.textColor = COLOR_PRIMARY;
    UIFont*font = self.lblTest.font;
    NSString* fontname = font.fontName;
    NSLog(@"%@",fontname);
    
    [_btnSignIn addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];

    [_btnSignUp addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];

    [_btnCall addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    [_btnForgotPassword addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    [_btnForgotUsername addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];

    _btnSignIn.tag = 200;
    _btnSignUp.tag = 201;
    
    
    _btnCall.tag = 204;
    _btnForgotPassword.tag = 301;
    _btnForgotUsername.tag = 302;
    
    
    self.img_phone.image = [CGlobal getColoredImageFromImage:self.img_phone.image Color:[UIColor blackColor]];
    
    NSArray* fields = @[self.txtUsername,self.txtPassword];
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, 250, 30);
    for (int i=0; i<fields.count; i++) {
        if ([fields[i] isKindOfClass:[BorderTextField class]]) {
            BorderTextField*field = fields[i];
            [field addBotomLayer:frame];
        }
    }
    
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate startLocationService];
    
    
    [self initTruck];
    if (g_location_cnt == 0) {
        NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"UserInfoWindow" owner:self options:nil];
        CitySelectView* cityView = array[2];
        MyPopupDialog * dialog = [[MyPopupDialog alloc] init];
        //    cityView.frame = CGRectMake(0, 0, 300, 500);
        CGRect scRect = [UIScreen mainScreen].bounds;
        cityView.frame = scRect;
        
        [cityView setData:@{@"list":g_cityModels,@"aDelegate":self}];
        [dialog setup:cityView backgroundDismiss:false backgroundColor:[UIColor darkGrayColor]];
        dialog.backgroundColor = [CGlobal colorWithHexString:@"#aaaaaa" Alpha:0.5];
        [dialog showPopup:self.view];
    }
    
    g_location_cnt = g_location_cnt + 1;
    
    EnvVar* env = [CGlobal sharedId].env;
    _txtUsername.text= env.username;
    _txtPassword.text= env.password;
    
    self.view.backgroundColor = COLOR_PRIMARY;
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = true;
}
-(void)clickView:(UIView*)sender{
    int tag = (int)sender.tag;
    switch (tag) {
        case 302:{
            UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ForgotUserViewController*vc = [ms instantiateViewControllerWithIdentifier:@"ForgotUserViewController"] ;
            vc.segIndex = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:vc animated:true];
            });
            break;
        }
        case 301:{
            UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ForgotPasswordViewController*vc = [ms instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"] ;
            vc.segIndex = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:vc animated:true];
            });
            break;
        }
        case 200:
        {
            // sign in
            NSString* username = _txtUsername.text;
            NSString* password = _txtPassword.text;
            if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
                [CGlobal AlertMessage:@"Please Input all Info" Title:nil];
                if ([username isEqualToString:@""]) {
                    [_txtUsername becomeFirstResponder];
                }else if([password isEqualToString:@""]){
                    [_txtPassword becomeFirstResponder];
                }
                return;
            }
            if (![CGlobal isValidEmail:username]) {
                [CGlobal AlertMessage:@"Invalid Email" Title:nil];
                return;
            }
            NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
            data[@"email"] = username;
            NSData *nsdata = [password
                              dataUsingEncoding:NSUTF8StringEncoding];
            
            // Get NSString from NSData object in Base64
            NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
            
            data[@"password"] = [base64Encoded stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            data[@"user_type"] = [NSString stringWithFormat:@"%d",c_PERSONAL];
            
            
            NetworkParser* manager = [NetworkParser sharedManager];
            [CGlobal showIndicator:self];
            [manager ontemplateGeneralRequest2:data BasePath:BASE_URL Path:@"login" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
                if (error == nil) {
                    // succ
                    if (dict[@"result" ]!=nil) {
                        if ([dict[@"result"] intValue] == 400) {
                            [CGlobal AlertMessage:@"We don't recognise the User Name and Password. Please try again." Title:nil];
                            [CGlobal stopIndicator:self];
                            return;
                        }
                    }
                    EnvVar* env = [CGlobal sharedId].env;
                    TblUser* user = [[TblUser alloc] initWithDictionary:dict];
                    [user saveResponse:0 Password:_txtPassword.text];
                    
                    
                    // LoginProcess
                    UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
                    PersonalMainViewController*vc = [ms instantiateViewControllerWithIdentifier:@"PersonalMainViewController"] ;
                    MyNavViewController* nav = [[MyNavViewController alloc] initWithRootViewController:vc];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        delegate.window.rootViewController = nav;
                    });
                    
                }else{
                    // error
                    NSLog(@"Error");
                }
                
                [CGlobal stopIndicator:self];
            } method:@"POST"];
            break;
        }
        case 201:
        {
            // sign up
            UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SignupViewController*vc = [ms instantiateViewControllerWithIdentifier:@"SignupViewController"] ;
            vc.segIndex = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationController.navigationBar.hidden = false;
                [self.navigationController pushViewController:vc animated:true];
            });
            break;
        }
        case 202:
        {
            // guest
            
            break;
        }
        case 203:
        {
            
            break;
        }
        case 204:
        {
            // call
            NSMutableDictionary* questionDict = [[NSMutableDictionary alloc] init];
            
            questionDict[@"employer_id"] = @"0";
            
//            NetworkParser* manager = [NetworkParser sharedManager];
            NSString*path = @"https://mobileapi.hurryr.in/basic/get_Contact_Details";
//            [manager ontemplateGeneralRequestWithRawUrlNoCheck:data Path:url withCompletionBlock:^(NSDictionary *dict, NSError *error) {
//                @try {
//                    NSArray* array = dict;
//                    NSString*num = [NSString stringWithFormat:@"tel:%@",array[0][@"PhoneNumber"]];
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
//                } @catch (NSException *exception) {
//                    NSLog(@"catch");
//                }
//            } method:@"post"];
            
//            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//            NSString*serverurl = url;
//            if ([[serverurl lowercaseString] hasPrefix:@"https://"]) {
//                manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
//                [manager.securityPolicy setValidatesDomainName:NO];
//            }
//
////            manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/html", "text/plain", "audio/wav"]);
//            [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//
//            [manager POST:serverurl parameters:questionDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                NSString* str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//                NSLog(@"%@",str);
//            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                NSLog(@"%@",error.localizedDescription);
//            }];

            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
            
            NSString *userUpdate =[NSString stringWithFormat:@"employer_id=%@",@"0"];
            
            //create the Method "GET" or "POST"
            [urlRequest setHTTPMethod:@"POST"];
            
            //Convert the String to Data
            NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
            
            //Apply the data to the body
            [urlRequest setHTTPBody:data1];
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if(httpResponse.statusCode == 200)
                {
                    
                    @try {
                        NSError *parseError = nil;
                        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                        NSArray* array = responseDictionary;
                        NSString*num = [NSString stringWithFormat:@"tel:%@",array[0][@"PhoneNumber"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
                        });
                        
                    } @catch (NSException *exception) {
                        NSLog(@"catch");
                    }

                }
                else
                {
                    NSLog(@"Error");
                }
            }];
            [dataTask resume];
            
            break;
        }
        case 205:
        {
            
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
-(void)initTruck{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    
    NetworkParser* manager = [NetworkParser sharedManager];
    [manager ontemplateGeneralRequest2:data BasePath:BASE_DATA_URL Path:@"get_truck" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            if (dict!=nil && dict[@"result"] != nil) {
                if ([dict[@"result"] intValue] == 200) {
                    LoginResponse* data = [[LoginResponse alloc] initWithDictionary:dict];
                    if (data.truck.count > 0) {
                        g_truckModels = data.truck;
                    }
                    
                }else{
                    [CGlobal AlertMessage:@"Fail" Title:nil];
                }
            }
        }else{
            NSLog(@"Error");
        }
        
    } method:@"POST"];
}
-(void)didSubmit:(NSDictionary *)data View:(UIView *)view{
    CityModel* model = data[@"model"];
    g_city_selection = model;
    if ([view.xo isKindOfClass:[MyPopupDialog class]]) {
        g_cityBounds = [model getGeofences];
        MyPopupDialog * dlg = (MyPopupDialog*)view.xo;
        [dlg dismissPopup];
    }
}
- (IBAction)clickTerm:(id)sender {
    UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    TermViewController*vc = [ms instantiateViewControllerWithIdentifier:@"TermViewController"] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationController.navigationBar.hidden = false;
        [self.navigationController pushViewController:vc animated:true];
    });
    
}
@end
