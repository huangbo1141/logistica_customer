//
//  StatViewController.m
//  Logistika
//
//  Created by BoHuang on 9/13/17.
//  Copyright © 2017 BoHuang. All rights reserved.
//

#import "StatViewController.h"
#import "CGlobal.h"
#import "AppDelegate.h"
#import "NetworkParser.h"

@interface StatViewController ()

@end

@implementation StatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect sc = [UIScreen mainScreen].bounds;
    CGFloat width = sc.size.width;
    CGFloat height = sc.size.height - 120-96-20;
    
    NSArray* views = @[_view1,_view2,_view3];
    for (int i=0; i<views.count; i++) {
        UIView* view = views[i];
        [self.scrollView addSubview:view];
        view.frame = CGRectMake(width*i,0, width, height);
        
    }
    self.scrollView.showsHorizontalScrollIndicator = false;
    self.scrollView.showsVerticalScrollIndicator = false;
    self.scrollView.pagingEnabled = true;
    self.scrollView.contentSize = CGSizeMake(width*views.count, height);
    self.pageIndicator.tintColor = [UIColor redColor];
    self.pageIndicator.pageIndicatorTintColor =COLOR_PRIMARY;
    self.pageIndicator.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageIndicator.numberOfPages = views.count;
    
    self.scrollView.delegate = self;
    
    self.view1.backgroundColor = [UIColor clearColor];
    self.view2.backgroundColor = [UIColor clearColor];
    self.view3.backgroundColor = [UIColor clearColor];
    
    UIImage* image = [UIImage imageNamed:@"swipe2.jpg"];
    NSArray* colors = [StatViewController getRGBAsFromImage:image atX:100 andY:100 count:5];
    if (colors.count > 0) {
        self.view.backgroundColor = colors[0];
    }
    self.view.backgroundColor = COLOR_SECONDARY_PRIMARY;
    self.lblLabel.textColor = COLOR_PRIMARY;
    self.btnStart.hidden = true;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    CGRect sc = [UIScreen mainScreen].bounds;
    CGFloat width = sc.size.width;
    CGFloat height = sc.size.height - 120-96;
    
    NSInteger pageIndex = offset.x/width;
    if (pageIndex>=0 && pageIndex<3) {
        _pageIndicator.currentPage = pageIndex;    
    }
    if (_pageIndicator.currentPage == 2) {
        _btnStart.hidden = false;
    }
}
+ (NSArray*)getRGBAsFromImage:(UIImage*)image atX:(int)x andY:(int)y count:(int)count
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
    for (int i = 0 ; i < count ; ++i)
    {
        CGFloat alpha = ((CGFloat) rawData[byteIndex + 3] ) / 255.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / alpha;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / alpha;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / alpha;
        byteIndex += bytesPerPixel;
        
        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }
    
    free(rawData);
    
    return result;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionStart:(id)sender {
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    
    NetworkParser* manager = [NetworkParser sharedManager];
    [CGlobal showIndicator:self];
    [manager ontemplateGeneralRequest2:data BasePath:BASE_DATA_URL Path:@"get_cities" withCompletionBlock:^(NSDictionary *dict, NSError *error) {
        if (error == nil) {
            if (dict!=nil && dict[@"result"] != nil) {
                if ([dict[@"result"] intValue] == 200) {
                    LoginResponse* data = [[LoginResponse alloc] initWithDictionary:dict];
                    if (data.cities.count > 0) {
                        g_cityModels = data.cities;
                        
                        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        [delegate defaultLogin];
                    }else{
                        [CGlobal AlertMessage:@"Fail" Title:nil];
                    }
                    
                }else{
                    [CGlobal AlertMessage:@"Fail" Title:nil];
                }
            }
        }else{
            NSLog(@"Error");
        }
        [CGlobal stopIndicator:self];
    } method:@"POST"];


}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
