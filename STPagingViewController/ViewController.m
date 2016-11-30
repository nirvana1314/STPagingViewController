//
//  ViewController.m
//  STPagingViewController
//
//  Created by lisongtao on 2016/11/30.
//  Copyright © 2016年 lst. All rights reserved.
//

#import "ViewController.h"
#import "STPagingViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (IBAction)click:(id)sender {
    STPagingViewController *vc = [STPagingViewController new];
    NSArray *arr = @[
                     @"http://www.qq.com",
                     @"http://m.autohome.com.cn/culture/201611/894584-14.html#pvareaid=2028165",
                     @"http://m.autohome.com.cn/news/201611/896211.html#pvareaid=2028166",
                     @"http://www.apple.com",
                     @"http://m.autohome.com.cn/advice/201611/896178.html#pvareaid=2028158",
                     ];
    [vc setDataSourceArr:arr CurrentIndex:0];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
