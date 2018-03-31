//
//  ViewHeading.m
//  Logistika
//
//  Created by BoHuang on 6/15/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "ViewHeading.h"
#import "CGlobal.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation ViewHeading

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setHeadMode:(NSInteger)headMode{
    _constraint_Height.constant = 30;
    _constraint_Leading.constant = 20;
}

-(void)setTitleTheme:(NSInteger)titleTheme{
    switch (titleTheme) {
        case 2:
            
            break;
        case 1:
            
            if (_lblTitle!=nil) {
                _lblTitle.font = [UIFont systemFontOfSize:_lblTitle.font.pointSize weight:UIFontWeightHeavy];;
                _lblTitle.textColor = COLOR_PRIMARY;
            }
            
            
            [self setBackMode:8];
            break;
            
        default:
            break;
    }
    
}
@end


