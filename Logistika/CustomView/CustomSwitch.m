//
//  CustomSwitch.m
//  Logistika
//
//  Created by q on 3/7/18.
//  Copyright © 2018 BoHuang. All rights reserved.
//

#import "CustomSwitch.h"
#import "CGlobal.h"

@implementation CustomSwitch

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
            break;
        }
        default:
        {
            //    self.swPackage.tintColor = COLOR_PRIMARY;
            //    self.swPackage.backgroundColor = [UIColor redColor];
            self.onTintColor = [UIColor whiteColor]; //[UIColor yellowColor];
            self.thumbTintColor = COLOR_PRIMARY;
            break;
        }
    }
    _backMode = backMode;
}
@end
