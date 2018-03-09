//
//  OrderBaseView.h
//  Logistika
//
//  Created by BoHuang on 6/21/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderBaseView : UIView
@property (strong, nonatomic) UIViewController* vc;

-(void)orderTracking:(NSString*)orderId Employee:(NSString*)employeeId;
@end
