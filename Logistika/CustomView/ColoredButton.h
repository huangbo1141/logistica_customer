//
//  ColoredButton.h
//  intuitive
//
//  Created by BoHuang on 4/17/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface ColoredButton : UIButton
@property (nonatomic) IBInspectable NSInteger backMode;
@property (nonatomic) IBInspectable CGFloat cornerRadious;
@end
