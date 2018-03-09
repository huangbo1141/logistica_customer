//
//  ColoredView.m
//  intuitive
//
//  Created by BoHuang on 4/17/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "ColoredView.h"
#import "CGlobal.h"

@implementation ColoredView

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
        case 7:{
            // d3d3d3
            UIColor* clr = [CGlobal colorWithHexString:@"d3d3d3" Alpha:1.0f];
            self.backgroundColor = clr;
            break;
        }
        case 6:{
            // card view white
            UIView* shadowView = self;
            shadowView.backgroundColor= [CGlobal colorWithHexString:@"ffffff" Alpha:1.0f];
            [shadowView.layer setCornerRadius:5.0f];
            [shadowView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [shadowView.layer setBorderWidth:0.1f];
            [shadowView.layer setShadowColor:[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor];
            [shadowView.layer setShadowOpacity:1.0];
            [shadowView.layer setShadowRadius:5.0];
            [shadowView.layer setShadowOffset:CGSizeMake(0.0f, 2.0f)];
            break;
        }
        case 5:{
            // head part
            UIView* shadowView = self;
            shadowView.backgroundColor= [CGlobal colorWithHexString:@"eeeeee" Alpha:1.0f];
            [shadowView.layer setCornerRadius:0.0f];
            [shadowView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
            [shadowView.layer setBorderWidth:0.0f];
            [shadowView.layer setShadowColor:[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor];
            [shadowView.layer setShadowOpacity:1.0];
            [shadowView.layer setShadowRadius:5.0];
            [shadowView.layer setShadowOffset:CGSizeMake(0.0f, 2.0f)];
            break;
        }
        case 4:{
            self.backgroundColor = [UIColor blueColor];
            break;
        }
        case 3:{
            // highlight menu view
            self.backgroundColor = [UIColor darkGrayColor];
            break;
        }
        case 2:{
            // white view
            self.backgroundColor = [CGlobal colorWithHexString:@"ffffff" Alpha:1.0f];
            break;
        }
        case 1:{
            // blue tone view
            self.backgroundColor = COLOR_PRIMARY;
            break;
        }
        default:
        {
            self.backgroundColor = [UIColor clearColor];
            break;
        }
    }
    _backMode = backMode;
}
-(void)setCornerRadious:(CGFloat)cornerRadious{
    if (cornerRadious>0) {
        self.layer.cornerRadius = cornerRadious;
        self.layer.masksToBounds = true;
    }
    _cornerRadious = cornerRadious;
}
@end
