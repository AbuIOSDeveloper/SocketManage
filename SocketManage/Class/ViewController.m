//
//  ViewController.m
//  SocketManage
//
//  Created by jefferson on 2018/7/3.
//  Copyright © 2018年 jefferson. All rights reserved.
//

#import "ViewController.h"
#import "SocketManage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[SocketManage Socket] connectSocketWithParame:@"你的拼接参数(根据后台协商定义格式)"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
