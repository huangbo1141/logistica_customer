//
//  OrderTableViewCell.m
//  Logistika
//
//  Created by BoHuang on 8/9/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "OrderTableViewCell.h"
#import "CGlobal.h"

@implementation OrderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.orderItemView.lblStat1.textColor = [UIColor whiteColor];
    self.orderItemView.lblStat2.textColor = [UIColor whiteColor];
    self.orderItemView.lblStat3.textColor = [UIColor whiteColor];
    self.orderItemView.lblStat1.numberOfLines = 2;
    self.orderItemView.lblStat2.numberOfLines = 2;
    self.orderItemView.lblStat3.numberOfLines = 2;
    
    self.orderItemView.lblOrderNumber_lbl.textColor = [CGlobal colorWithHexString:@"626262" Alpha:1.0f];
    self.orderItemView.lblOrderNumber.textColor = [CGlobal colorWithHexString:@"626262" Alpha:1.0f];
    self.orderItemView.lblTracking_lbl.textColor = [CGlobal colorWithHexString:@"626262" Alpha:1.0f];
    self.orderItemView.lblTracking.textColor = [CGlobal colorWithHexString:@"626262" Alpha:1.0f];
    self.orderItemView.lblStatus_lbl.textColor = [CGlobal colorWithHexString:@"626262" Alpha:1.0f];
    self.orderItemView.lblStatus.textColor = [CGlobal colorWithHexString:@"626262" Alpha:1.0f];
    
    CGFloat ptSize = self.orderItemView.lblStatus_lbl.font.pointSize;
    self.orderItemView.lblStatus_lbl.font = [UIFont boldSystemFontOfSize:ptSize];
    self.orderItemView.lblStatus.font = [UIFont boldSystemFontOfSize:ptSize];
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
            [self.orderItemView setModelData:model VC:self.vc];
        }
        
        
    }
    self.orderItemView.viewContent.hidden = model.viewContentHidden;
    if (model.viewContentHidden) {
        self.orderItemView.imgDrop.image = [UIImage imageNamed:@"down.png"];
    }else{
        self.orderItemView.imgDrop.image = [UIImage imageNamed:@"up.png"];
    }
    
    if([model.state intValue] == 1){
        self.orderItemView.viewSchedule.hidden = false;
        self.orderItemView.btnReschedule.hidden = false;
        self.orderItemView.btnCancel.hidden = false;
    }else{
        self.orderItemView.viewSchedule.hidden = true;
        self.orderItemView.btnReschedule.hidden = true;
        self.orderItemView.btnCancel.hidden = true;
    }
}
@end
