//
//  BorderTextField.m
//  Logistika
//
//  Created by BoHuang on 6/22/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "BorderTextField.h"
#import "CGlobal.h"
@implementation BorderTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        //[self customInit];
    }
    return self;
}
-(void)setBackMode:(NSInteger)backMode{
    switch (backMode) {
        
        case 1:{
            // only bottom border
            if (_bottomLine==nil) {
                CALayer *border = [CALayer layer];
                CGFloat borderWidth = g_txtBorderWidth;
                border.borderColor = [UIColor darkGrayColor].CGColor;
                CGRect frame =CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
                border.frame = frame;
                border.borderWidth = borderWidth;
                [self.layer addSublayer:border];
                self.layer.masksToBounds = YES;
                
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
                self.leftView = paddingView;
                self.leftViewMode = UITextFieldViewModeAlways;
                
                _bottomLine = border;
                
                self.delegate = self;
            }
            
            break;
        }
        default:
        {
            break;
        }
    }
    _backMode = backMode;
}

-(void)addBotomLayer:(CGRect)param{
    if (_bottomLine!=nil) {
        [_bottomLine removeFromSuperlayer];
        _bottomLine = nil;
    }
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = g_txtBorderWidth;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    CGRect frame =CGRectMake(0, param.size.height - borderWidth, param.size.width, param.size.height);
    border.frame = frame;
    border.borderWidth = borderWidth;
    [self.layer addSublayer:border];
    self.layer.masksToBounds = YES;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    
    _bottomLine = border;
    
    self.delegate = self;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (_bottomLine != nil) {
        CALayer *border = _bottomLine;
        border.borderColor = COLOR_PRIMARY.CGColor;
        border.borderWidth = g_txtBorderWidth;
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (_bottomLine != nil) {
        CALayer *border = _bottomLine;
        border.borderColor = [UIColor darkGrayColor].CGColor;
        border.borderWidth = g_txtBorderWidth;
    }
}
-(void)checkString{
    switch (self.validateMode) {
        case 2:{
            NSString* tmp = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (tmp.length>0) {
                // go ahead
            }else{
                self.text = @"+91";
            }
            break;
        }
        default:{
            break;
        }
            
    }
}
-(NSString*)getValidString{
    switch (self.validateMode) {
        case 2:
        {
            NSString* tmp = self.text;
            if (self.text.length>5) {
                if([self.text containsString:@"+91"]){
                    tmp = [self.text stringByReplacingOccurrencesOfString:@"+91" withString:@""];
                }
                tmp = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            return tmp;
        }
        default:{
            
        }
    }
    return self.text;
}
-(BOOL)isValid{
    switch (self.validateMode) {
        case 2:
        {
            NSString* ppp = [self.text stringByReplacingOccurrencesOfString:@"+91" withString:@""];
            ppp = [ppp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (ppp.length == self.validateLength) {
                return true;
            }
        }
        default:{
            break;
        }
    }
    return false;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (self.validateMode) {
        case 2:{
            if (textField.text.length <= 3) {
                if (range.location < 3) {
                    return NO;
                }
            }
            break;
        }
        default:{
            break;
        }
            
    }
    return YES;
}
@end
