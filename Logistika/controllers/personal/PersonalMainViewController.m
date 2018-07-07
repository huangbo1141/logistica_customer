//
//  PersonalMainViewController.m
//  Logistika
//
//  Created by BoHuang on 4/19/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "PersonalMainViewController.h"
#import "CGlobal.h"
#import "PhotoUploadViewController.h"
#import "SelectItemViewController.h"
#import "SelectPackageViewController.h"
#import "Logistika-Swift.h"
#import "OrderHistoryViewController.h"

@interface PersonalMainViewController ()

@end

@implementation PersonalMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = COLOR_SECONDARY_THIRD;
    
    self.btnContinue.hidden = true;
    // Do any additional setup after loading the view.
    
    [self.txtCholocate addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
   
}
-(void)textFieldDidChange:(UITextField*)textField{
    if (textField == self.txtCholocate) {
        NSString* pp = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(pp.length > 0){
            self.btnContinue.hidden = false;
        }else{
            self.btnContinue.hidden = true;
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [CGlobal clearData];
    
    [self.topBarView updateCaption];
    
    EnvVar* env = [CGlobal sharedId].env;
    env.quote = false;
}
- (IBAction)menu1:(id)sender {
//    UIStoryboard *ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
//    PhotoUploadViewController* vc = [ms instantiateViewControllerWithIdentifier:@"PhotoUploadViewController"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        vc.limit =  g_limitCnt;
//        g_ORDER_TYPE = g_CAMERA_OPTION;
//        [self.navigationController pushViewController:vc animated:true];
//    });
    
    UIStoryboard *ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
    PhotoViewController* vc = [ms instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
        vc.limit =  g_limitCnt;
        g_ORDER_TYPE = g_CAMERA_OPTION;
        [self.navigationController pushViewController:vc animated:true];
    });
}
- (IBAction)menu2:(id)sender {
    UIStoryboard *ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
    SelectItemViewController* vc = [ms instantiateViewControllerWithIdentifier:@"SelectItemViewController"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        g_ORDER_TYPE = g_ITEM_OPTION;
        [self.navigationController pushViewController:vc animated:true];
    });
}
- (IBAction)menu3:(id)sender {
    if(self.txtCholocate.text.length>0){
        UIStoryboard *ms = [UIStoryboard storyboardWithName:@"Personal" bundle:nil];
        SelectPackageViewController* vc = [ms instantiateViewControllerWithIdentifier:@"SelectPackageViewController"];
        vc.string = self.txtCholocate.text;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            g_ORDER_TYPE = g_PACKAGE_OPTION;
            [self.navigationController pushViewController:vc animated:true];
        });
    }
    
    
}
- (IBAction)reveal2:(UIButton*)sender {
    if(sender.tag == 2){
        // bottom one
        self.layer1.hidden = false;
        self.layer2.hidden = !self.layer2.hidden;
        
        if(self.layer2.hidden == true){
            [_txtCholocate becomeFirstResponder];
        }
    }else if(sender.tag == 1){
        
        self.layer2.hidden = false;
        self.layer1.hidden = !self.layer1.hidden;
        
        UIStoryboard* ms = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
        OrderHistoryViewController*vc = [ms instantiateViewControllerWithIdentifier:@"OrderHistoryViewController"] ;

        dispatch_async(dispatch_get_main_queue(), ^{
            vc.param1 = 1;
            self.navigationController.navigationBar.hidden = true;
            self.navigationController.viewControllers = @[vc];
        });
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
