//
//  PickupLocationViewController.m
//  Logistika
//
//  Created by BoHuang on 7/25/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "PickupLocationViewController.h"
#import "CellGeneral.h"
#import "CGlobal.h"
#import "NetworkParser.h"
#import "GooglePlaceResult.h"
#import "EftGoogleAddressComponent.h"
#import "Predictions.h"


#import "AddressData.h"
#import "Terms.h"
#import "AFNetworking.h"
#import "AutomCompletePlaces.h"

@import GooglePlaces;

@interface PickupLocationViewController ()
@property (nonatomic,assign) CLLocationCoordinate2D userPosition;
@property (nonatomic,copy) NSString* mLat;
@property (nonatomic,copy) NSString* mLng;

@property (nonatomic,copy) NSString* location;
@property (nonatomic,copy) NSString* street;
@property (nonatomic,copy) NSString* state;
@property (nonatomic,copy) NSString* city;
@property (nonatomic,copy) NSString* area;
@property (nonatomic,copy) NSString* pinCode;
@property (nonatomic,strong) NSArray* addresses;

@property (nonatomic,strong) GMSMarker* userMarker;

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSMutableArray *items_predction;

@property (nonatomic,strong) Predictions *mPrediction;
@property (nonatomic,assign) CGFloat cellcontent_width1;
@property (nonatomic,strong) UIFont *cellcontent_font1;

@property (nonatomic,strong) AddressData *addressData;

@end

@implementation PickupLocationViewController

#define GoogleDirectionAPI @"AIzaSyCmvC_H5S08MvkO-ixoQTpJQGXdu5qyVWg"
//&types=(cities)
#define kGoogleAutoCompleteAPI @"https://maps.googleapis.com/maps/api/place/autocomplete/json?language=en&key=%@&input=%@"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topbar_lbl_chooselocation.font = [UIFont systemFontOfSize:18.0f weight:UIFontWeightHeavy];
    self.topBar.backgroundColor = COLOR_PRIMARY;
    self.view.backgroundColor = COLOR_PRIMARY;
    _autocompleteTable.backgroundColor = [UIColor clearColor];
    _autocompleteTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Do any additional setup after loading the view.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _cellcontent_width1 = screenRect.size.width - 16;
    _cellcontent_font1 = [UIFont systemFontOfSize:15];
    
    [_autocompleteTable registerNib:[UINib nibWithNibName:@"CellGeneral" bundle:nil] forCellReuseIdentifier:@"CellGeneral"];
    
    
    
    _autocompleteTable.hidden = true;
    
    [_autocompleteTable setDelegate:self];
    [_autocompleteTable setDataSource:self];
    
    double lat = 35.89093;
    double lng = -106.326907;
    if (g_lastLocation !=nil) {
        lat = g_lastLocation.coordinate.latitude;
        lng = g_lastLocation.coordinate.longitude;
    }
    self.userPosition = CLLocationCoordinate2DMake(lat, lng);
    
    self.mapView.delegate = self;
    
    [_edt_location addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_cityBounds.count==0 || g_mode == c_CORPERATION) {
            self.mapView.camera = [[GMSCameraPosition alloc] initWithTarget:self.userPosition zoom:gms_camera_zoom bearing:0 viewingAngle:0];
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self centerPointProcess];
            });
        }else{
            GMSMutablePath* path = [GMSMutablePath path];
            for (int i=0; i<g_cityBounds.count; i++) {
                NSValue *value = g_cityBounds[i];
                CGPoint point = [value CGPointValue];
                [path addCoordinate:CLLocationCoordinate2DMake(point.x, point.y)];
                
            }
            GMSCoordinateBounds* bound = [[GMSCoordinateBounds alloc] initWithPath:path];
            
            [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bound withPadding:10]];
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self centerPointProcess];
            });
        }
        
        
    });
    
    self.pageIndex = 0;
}
- (IBAction)tapBAck:(id)sender {
    if(self.pageIndex == 1){
        self.pageIndex = 0;
        [self updatePage];
    }else{
        [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (IBAction)tapTopBarSearch:(id)sender {
    self.pageIndex = 1;
    
    [self updatePage];
}
-(void)updatePage{
    if (self.pageIndex == 0) {
        self.topbar_imgsearch.hidden = false;
        self.topbar_lbl_location.hidden = false;
        self.topbar_lbl_chooselocation.hidden = true;
        self.topbar_btn_search.hidden = false;
        
        self.viewMap1.hidden = false;
        self.viewPick2.hidden = true;
    }else{
        self.topbar_imgsearch.hidden = true;
        self.topbar_lbl_location.hidden = true;
        self.topbar_lbl_chooselocation.hidden = false;
        self.topbar_btn_search.hidden = true;
        
        self.viewMap1.hidden = true;
        self.viewPick2.hidden = false;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.title = @"Choose Location";
    self.navigationController.navigationBar.hidden = true;
    [self updatePage];
}
#pragma -mark textFields
-(void)textFieldDidChange:(UITextField*)textField{
    if (textField == _edt_location) {
        NSString *str = textField.text;
        if ([str length]>0) {
            [self getAutoCompletePlaces:str];
            _autocompleteTable.hidden = false;
            self.btnClose.hidden = false;
            
        }else{
            _autocompleteTable.hidden = true;
            self.btnClose.hidden = true;
            
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated{
//    if ([self.location length]>0) {
//        [self processDone];
//    }
    [super viewWillDisappear:animated];
}
- (IBAction)clickDone:(id)sender {
    if ([self.location length]>0) {
        //[self.navigationController popViewControllerAnimated:true];
        [self processDone];
        [self dismissViewControllerAnimated:true completion:nil];
    }
}
-(void)processDone{
    if ([self.area length]>0) {
        //ok
    }else{
        self.area = self.city;
    }
    NSDictionary* data = @{@"type":self.type
                           ,@"location":[NSString stringWithFormat:@"%@,%@,%@",self.street, self.area,self.state]
                           ,@"lat":_mLat
                           ,@"lng":_mLng
                           ,@"pincode":self.pinCode
                           ,@"state":self.state
                           ,@"city":self.city
                           ,@"area":self.area
                           ,@"address":self.location
                           
                           //,@"landmark":_txtPickLandMark.text
                           //,@"phone":_txtPickPhone.text
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:GLOBALNOTIFICATION_ADDRESSPICKUP object:data];
    
    
}
- (IBAction)clickCross:(id)sender {
    self.edt_location.text = @"";
    self.autocompleteTable.hidden = true;
    self.btnClose.hidden = true;
}

#pragma mark - tableview
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CellGeneral *cell = [tableView dequeueReusableCellWithIdentifier:@"CellGeneral" forIndexPath:indexPath];
    
    [cell.lbl_content setFont:[UIFont systemFontOfSize:12]];
    cell.lbl_content.text = _items[indexPath.row];
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _autocompleteTable) {
        return _items.count;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [CGlobal heightForView:_items[indexPath.row] Font:_cellcontent_font1 Width:_cellcontent_width1];
    
    return height+8;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _mPrediction = _items_predction[indexPath.row];
    _edt_location.text = _items[indexPath.row];
    
    _btnClose.hidden = false;
    
    
    [_autocompleteTable deselectRowAtIndexPath:indexPath animated:YES];
    
    _autocompleteTable.hidden = true;
//    [_scrollView setScrollEnabled:true];
//    [_autocompleteTable setScrollEnabled:false];
    
    AddressData* addressData = [[AddressData alloc] init];
    addressData.address = _mPrediction.predictionsDescription;
    NSArray*array = _mPrediction.terms;
    addressData.city = ((Terms*)array[0]).value;
    addressData.country =((Terms*) [array lastObject]).value;
    
//    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
//    WNACountry*country = [delegate.dbManager getCountryFromName:addressData.country];
//    addressData.pos = CLLocationCoordinate2DMake([country.latitude doubleValue], [country.longitude doubleValue]);
    addressData.type = 1;
    addressData.placeId = _mPrediction.placeId;
    _addressData = addressData;
    
    [self test:_mPrediction.placeId];
    
    
    return;
    
}
-(void)test:(NSString*)placeID{
    GMSPlacesClient* client = [GMSPlacesClient sharedClient];
    //self.lblLocation.text = @"Please Wait...";
    [client lookUpPlaceID:placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        CLLocationCoordinate2D coordinate =  result.coordinate;
        if (g_mode == c_CORPERATION) {
//            self.lblLocation.text = @"Please Wait...";
            self.mLat = [NSString stringWithFormat:@"%.4f",coordinate.latitude];
            self.mLng = [NSString stringWithFormat:@"%.4f",coordinate.longitude];
            [self getLocationFromCoordinate:coordinate whichView:1];
        }else{
            if ([CGlobal isPointInPolygon:coordinate ArrayList:g_cityBounds]) {
//                self.lblLocation.text = @"Please Wait...";
                self.mLat = [NSString stringWithFormat:@"%.4f",coordinate.latitude];
                self.mLng = [NSString stringWithFormat:@"%.4f",coordinate.longitude];
                [self getLocationFromCoordinate:coordinate whichView:1];
            }else{
                [CGlobal AlertMessage:@"Sorry we do not operate in the location you selected." Title:nil];
                self.lblLocation.text = @"location";
                self.edt_location.text = @"";
            }
        }
    }];
}
-(void)getAutoCompletePlaces:(NSString *)searchKey{
    
    NSString *serverurl = [[NSString stringWithFormat:kGoogleAutoCompleteAPI,GoogleDirectionAPI,[CGlobal urlencode:searchKey]] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    //    NSString* serverurl = [CGlobal urlencode:serverurl1];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([[serverurl lowercaseString] hasPrefix:@"https://"]) {
        manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
        [manager.securityPolicy setValidatesDomainName:NO];
    }
    
    
    
    [manager GET:serverurl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *JSON = responseObject;
        
        _items = [NSMutableArray array];
        _items_predction = [NSMutableArray array];
        
        // success
        AutomCompletePlaces *places = [AutomCompletePlaces modelObjectWithDictionary:JSON];
        
        for (Predictions *pred in places.predictions) {
            
            [_items addObject:pred.predictionsDescription];
            
            [_items_predction addObject:pred];
            
        }
        
        if ([_items count] == 0) {
            _autocompleteTable.hidden = true;
            
            [_autocompleteTable setScrollEnabled:true];
        }
        [_autocompleteTable reloadData];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    // nothing
    NSLog(@"didTapAtCoordinatedidTapAtCoordinatedidTapAtCoordinate");
    NSLog(@"111111111222221111111112222211111111122222");
}
-(void)centerPointProcess{
    GMSProjection* projection = self.mapView.projection;
    CGFloat heightStatus = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat heightTopbar = 55;
    CGSize screen = [UIScreen mainScreen].bounds.size;
    CGPoint pt = CGPointMake(screen.width/2.0f, (screen.height - heightStatus - heightTopbar)/2.0f);
    CLLocationCoordinate2D centerCoordinate =  [projection coordinateForPoint:pt];
    [self processForTapAtCoordinate:centerCoordinate];
    
}
-(void)processForTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    if (g_mode == c_CORPERATION) {
//        self.lblLocation.text = @"Please Wait...";
        self.mLat = [NSString stringWithFormat:@"%.4f",coordinate.latitude];
        self.mLng = [NSString stringWithFormat:@"%.4f",coordinate.longitude];
        [self getLocationFromCoordinate:coordinate whichView:0];
    }else{
        if ([CGlobal isPointInPolygon:coordinate ArrayList:g_cityBounds]) {
//            self.lblLocation.text = @"Please Wait...";
            self.mLat = [NSString stringWithFormat:@"%.4f",coordinate.latitude];
            self.mLng = [NSString stringWithFormat:@"%.4f",coordinate.longitude];
            [self getLocationFromCoordinate:coordinate whichView:0];
        }else{
            [CGlobal AlertMessage:@"Sorry we do not operate in the location you selected." Title:nil];
            //            self.lblLocation.text = @"location";
            //            self.edt_location.text = @"";
        }
        
    }
}

-(void)getLocationFromCoordinate:(CLLocationCoordinate2D)coordinate whichView:(int)index{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    data[@"latlng"] = [NSString stringWithFormat:@"%@,%@",self.mLat,self.mLng];
    data[@"sensor"] = @"true";
    data[@"language"] = @"US";
    
    NSString* path = @"http://maps.googleapis.com/maps/api/geocode/json";
    NetworkParser* manager = [NetworkParser sharedManager];
//    [CGlobal showIndicator:self];
    [manager ontemplateGeneralRequestWithRawUrl:data Path:path withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        GooglePlaceResult* resp = [[GooglePlaceResult alloc] initWithDictionary:dict];
        if (resp.results.count > 0) {
            GooglePlace*place = resp.results[0];
            NSString* postCode = @"";
            NSString* state1 = @"";
            NSString* state2 = @"";
            NSString* city = @"";
            NSString* area1 = @"";
            NSString* area2 = @"";
            NSString* street = @"";
            NSString* establishment = @"";
            NSString* premise = @"";
            
            for (int i=0; i<place.address_components.count; i++) {
                EftGoogleAddressComponent*comp = place.address_components[i];
                NSUInteger foundIndex = NSNotFound;
                foundIndex = [comp.types indexOfObject:@"postal_code"];
                if (foundIndex!=NSNotFound) {
                    postCode = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"administrative_area_level_2"];
                if (foundIndex != NSNotFound) {
                    state2 = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"administrative_area_level_1"];
                if (foundIndex != NSNotFound) {
                    state1 = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"locality"];
                if (foundIndex != NSNotFound) {
                    city = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"sublocality_level_2"];
                if (foundIndex != NSNotFound) {
                    area2 = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"sublocality_level_1"];
                if (foundIndex != NSNotFound) {
                    area1 = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"route"];
                if (foundIndex != NSNotFound) {
                    street = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"establishment"];
                if (foundIndex != NSNotFound) {
                    establishment = comp.long_name;
                }
                foundIndex = [comp.types indexOfObject:@"premise"];
                if (foundIndex != NSNotFound) {
                    premise = comp.long_name;
                }
            }
            
            NSString* area = @"";
            NSString* location = place.formatted_address;
            if (street == nil || [street length] == 0) {
                street = establishment;
            }
            if (street == nil || [street length] == 0) {
                street = premise;
            }
            
            if ((area1 == nil || [area1 length] == 0)&&(area2 == nil || [area2 length] == 0)) {
                area = city;
            }else{
                area = [NSString stringWithFormat:@"%@ %@",area1,area2];
            }
            if ([location length] == 0 || [street length] == 0 || [area length] == 0 || [city length] == 0 || ([state1 length] == 0 && [state2 length] == 0) || [postCode length] == 0) {
                self.lblLocation.text = @"Choose Correct Location,Can not get location info";
                [CGlobal AlertMessage:@"Choose Correct Location,Can not get location info" Title:nil];
            }else{
                self.location = location;
                self.street = street;
                self.pinCode = postCode;
                self.state = [NSString stringWithFormat:@"%@ %@",state1,state2];
                self.city = city;
                self.area = area;
                
//                GMSMarker* marker = [[GMSMarker alloc] init];
//                marker.title = @"Location";
//                marker.snippet = @"";
//                marker.userData = @{@"type":@"2"};
//                marker.position = coordinate;
//                marker.icon = [CGlobal getImageForMap:@"dropoff_location.png"];
//                marker.map = self.mapView;
//
//                self.userMarker.map = nil;
//                self.userMarker = nil;
//                self.userMarker = marker;
                
//                self.mapView.camera = [[GMSCameraPosition alloc] initWithTarget:marker.position zoom:gms_camera_zoom bearing:0 viewingAngle:0];
                if (index == 0) {
                    self.topbar_lbl_location.text = location;
                }else{
                    self.lblLocation.text = location;
                    _edt_location.text = location;
                }
                
//                self.lblLocation.text = location;
//                _edt_location.text = location;
            }
            
            self.btnClose.hidden = false;
            [CGlobal stopIndicator:self];
        }else{
//            [CGlobal AlertMessage:@"Fail" Title:nil];
        }
        
    }];
}

-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    NSLog(@"idleAtCameraPosition");
    [self centerPointProcess];
}
-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    NSLog(@"didChangeCameraPosition");
}
@end


