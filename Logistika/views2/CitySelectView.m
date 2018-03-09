//
//  CitySelectView.m
//  Logistika
//
//  Created by BoHuang on 9/22/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "CitySelectView.h"
#import "CitySelectTableViewCell.h"
@implementation CitySelectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)setData:(NSDictionary *)data{
    [super setData:data];
    [self setupView];
    self.list_city = self.inputData[@"list"];
}
-(void)setupView{
    UINib* nib = [UINib nibWithNibName:@"CitySelectTableViewCell" bundle:nil];
    [_tableview registerNib:nib forCellReuseIdentifier:@"cell"];
    
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CitySelectTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setData:@{@"model":self.list_city[indexPath.row]}];
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list_city.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.aDelegate!=nil) {
        id model = self.list_city[indexPath.row];
        [self.aDelegate didSubmit:@{@"model":model} View:self];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180.0f;
}
@end
