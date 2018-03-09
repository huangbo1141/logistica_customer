//
//  OrderTableViewCell.m
//  Logistika
//
//  Created by BoHuang on 8/9/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "OrderTableViewCell.h"

@implementation OrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setData:(NSMutableDictionary *)data{
    [super setData:data];
    OrderHisModel* model = self.model;
    if (model.viewContentHidden) {
        [self.orderItemView firstProcess:0 Data:self.model VC:self.vc];
        
    }else{
        [self.orderItemView firstProcess:0 Data:self.model VC:self.vc];
        if (model.cellSizeCalculated == false) {
            [self.orderItemView setModelData:model VC:self.vc];
        }else{
            [self.orderItemView setModelData:self.model VC:self.vc];
        }
        
        
    }
    self.orderItemView.viewContent.hidden = model.viewContentHidden;
    if (model.viewContentHidden) {
        self.orderItemView.imgDrop.image = [UIImage imageNamed:@"down.png"];
    }else{
        self.orderItemView.imgDrop.image = [UIImage imageNamed:@"up.png"];
    }
}
@end
