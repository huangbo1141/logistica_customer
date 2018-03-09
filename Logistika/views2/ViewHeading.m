//
//  ViewHeading.m
//  Logistika
//
//  Created by BoHuang on 6/15/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "ViewHeading.h"

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
@end
