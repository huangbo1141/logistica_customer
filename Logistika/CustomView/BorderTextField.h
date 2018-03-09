//
//  BorderTextField.h
//  Logistika
//
//  Created by BoHuang on 6/22/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BorderTextField : UITextField<UITextFieldDelegate>

@property (nonatomic) IBInspectable NSInteger backMode;
@property (nonatomic,strong) CALayer*bottomLine;

@property (nonatomic,assign) int validateMode;
@property (nonatomic,assign) int validateLength;

-(void)addBotomLayer:(CGRect)param;
-(BOOL)isValid;
-(NSString*)getValidString;
-(void)checkString;
@end
