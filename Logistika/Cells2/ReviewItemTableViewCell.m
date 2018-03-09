//
//  ReviewItemTableViewCell.m
//  Logistika
//
//  Created by BoHuang on 4/26/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "ReviewItemTableViewCell.h"

@implementation ReviewItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)initMe:(ItemModel*)model{
    self.backgroundColor = [UIColor whiteColor];
    
    
    self.lblItem.text = model.title;
    self.lblDim.text = [model getDimetion];
    self.lblQuantity.text = model.quantity;
    self.lblWeight.text = model.weight;
    
    
    self.data = model;
}
-(void)setFontSizeForReviewOrder:(CGFloat)fontsize{
    UIFont* font = [UIFont systemFontOfSize:fontsize];
    [self.lblDim setFont:font];
    [self.lblQuantity setFont:font];
    [self.lblWeight setFont:font];
    [self.lblItem setFont:font];
}
@end
