//
//  ViewController.m
//  SQScrollView
//
//  Created by sohu on 14-2-26.
//  Copyright (c) 2014年 LinjunHou. All rights reserved.
//

#import "ViewController.h"
#import "MyCusViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:[[MyCusViewController alloc] initWithAssetsArray:@[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg",@"8.jpg",@"9.jpg"] andCurAsset:@"1.jpg"] animated:YES];
}

@end
