//
//  MainViewController.h
//  Logistika
//
//  Created by BoHuang on 4/18/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "MyPopupDialog.h"
#import "BorderTextField.h"

@interface MainViewController : MenuViewController<ViewDialogDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnGuest;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;
@property (weak, nonatomic) IBOutlet UIButton *btnTracking;
@property (strong, nonatomic) IBOutlet BorderTextField *txtPhoneNumber;
@property (strong, nonatomic) IBOutlet UIButton *btnSubmit;
@property (copy, nonatomic) NSString* phone;

@property (strong, nonatomic) IBOutlet UILabel* lblReceiverPhone;

@end
