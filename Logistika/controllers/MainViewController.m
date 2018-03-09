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

@interface MainViewController ()
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_segment addTarget:self action:@selector(onChange:) forControlEvents:UIControlEventValueChanged];
    
    [_btnSignIn addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnSignUp addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnGuest addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnTracking addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    
    [_btnCall addTarget:self action:@selector(clickView:) forControlEvents:UIControlEventTouchUpInside];
    
    _btnSignIn.tag = 200;
    _btnSignUp.tag = 201;
    _btnGuest.tag = 202;
    _btnTracking.tag = 203;
    _btnCall.tag = 204;
    
    self.segment.tintColor = COLOR_PRIMARY;
    
    self.view.drawerView.mode = 0;
    
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
//    dispatch_async(dispatch_get_main_queue(), ^{
////        cityView.imgView.backgroundColor = [UIColor redColor];
////        cityView.imgView.image = [UIImage imageNamed:@"background.png"];
//    });
    
}
-(void)clickView:(UIView*)sender{
    int tag = (int)sender.tag;
    switch (tag) {
        case 200:
        {
            // sign in
            UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController*vc = [ms instantiateViewControllerWithIdentifier:@"LoginViewController"] ;
            vc.segIndex = self.segment.selectedSegmentIndex;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationController.navigationBar.hidden = false;
                [self.navigationController pushViewController:vc animated:true];
            });
            break;
        }
        case 201:
        {
            // sign up
            UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SignupViewController*vc = [ms instantiateViewControllerWithIdentifier:@"SignupViewController"] ;
            vc.segIndex = self.segment.selectedSegmentIndex;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationController.navigationBar.hidden = false;
                [self.navigationController pushViewController:vc animated:true];
            });
            break;
        }
        case 202:
        {
            // guest
            EnvVar*env = [CGlobal sharedId].env;
            env.lastLogin = 0;
            g_mode = c_GUEST;
            env.mode = c_GUEST;
            env.user_id = @"0";
            env.corporate_user_id = @"0";
            
            // LoginProcess
            UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
            PersonalMainViewController*vc = [ms instantiateViewControllerWithIdentifier:@"PersonalMainViewController"] ;
            MyNavViewController* nav = [[MyNavViewController alloc] initWithRootViewController:vc];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                delegate.window.rootViewController = nav;
            });
            break;
        }
        case 203:
        {
            // tracking
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                                      message: @"Input Tracking Number"
                                                                               preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"Tracking Number";
                textField.textColor = [UIColor blueColor];
                textField.borderStyle = UITextBorderStyleLine;
            }];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                NSArray * textfields = alertController.textFields;
                UITextField * namefield = textfields[0];
                NSString* number = namefield.text;
                if ([number length]>0) {
                    if (self.segment.selectedSegmentIndex == 0) {
                        [self tracking:number];
                    }else{
                        [self tracking_corporate:number];
                    }
                    
                }
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case 204:
        {
            // call
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:12125551212"]];
            break;
        }
        default:
            break;
    }
}
-(void)tracking_corporate:(NSString*)number{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    params[@"id"] = number;
    
    NetworkParser* manager = [NetworkParser sharedManager];
    [CGlobal showIndicator:self];
    [manager ontemplateGeneralRequest2:params BasePath:BASE_URL_ORDER Path:@"corporate_tracking" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            if (dict!=nil) {
                if (dict[@"result"]!=nil && [dict[@"result"] intValue] == 400) {
                    NSString*msg = [[NSBundle mainBundle] localizedStringForKey:@"msg_track" value:@"" table:nil];
                    [CGlobal AlertMessage:msg Title:nil];
                }else{
                    OrderResponse* response = [[OrderResponse alloc] initWithDictionary_his_cor:dict];
                    UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
                    
                    TrackingCorViewController*vc = [ms instantiateViewControllerWithIdentifier:@"TrackingCorViewController"] ;
                    vc.response = response;
                    vc.trackID = number;
                    vc.data = response.orders[0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController pushViewController:vc animated:true];
                    });
                }
                
                
            }
        }else{
            NSLog(@"Error");
        }
        [CGlobal stopIndicator:self];
    } method:@"POST"];
}
-(void)tracking:(NSString*)number{

    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    params[@"id"] = number;
    
    NetworkParser* manager = [NetworkParser sharedManager];
    [CGlobal showIndicator:self];
    [manager ontemplateGeneralRequest2:params BasePath:BASE_URL_ORDER Path:@"tracking" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            if (dict!=nil) {
                if (dict[@"result"]!=nil && [dict[@"result"] intValue] == 400) {
                    NSString*msg = [[NSBundle mainBundle] localizedStringForKey:@"msg_track" value:@"" table:nil];
                    [CGlobal AlertMessage:msg Title:nil];
                }else{
                    OrderResponse* response = [[OrderResponse alloc] initWithDictionary_his:dict];
                    UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
                    
                    TrackingViewController*vc = [ms instantiateViewControllerWithIdentifier:@"TrackingViewController"] ;
                    vc.response = response;
                    vc.trackID = number;
                    vc.inputData = response.orders[0];
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        self.navigationController.navigationBar.hidden = true;
//                        self.navigationController.viewControllers = @[vc];
                        [self.navigationController pushViewController:vc animated:true];
                    });
                }
                
                
            }
        }else{
            NSLog(@"Error");
        }
        [CGlobal stopIndicator:self];
    } method:@"POST"];
}
-(void)onChange:(UISegmentedControl*)seg{
    NSInteger index = seg.selectedSegmentIndex;
    if (index == 0) {
        _btnGuest.hidden = false;
        
    }else{
        _btnGuest.hidden = true;
    }
    
    self.view.drawerView.mode = index;
}
-(void)onLeftItemTouched:(UIBarButtonItem*)sender{
    if (self.view.drawerLayout!=nil) {
        self.view.drawerLayout.openFromRight = NO;
        [self.view.drawerLayout openDrawer];
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
    if ([view.xo isKindOfClass:[MyPopupDialog class]]) {
        g_cityBounds = [model getGeofences];
        MyPopupDialog * dlg = (MyPopupDialog*)view.xo;
        [dlg dismissPopup];
    }
}
@end
