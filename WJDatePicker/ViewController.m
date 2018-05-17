//
//  ViewController.m
//  WJDatePicker
//
//  Created by Adward on 2018/5/17.
//  Copyright © 2018年 Adward. All rights reserved.
//

#import "ViewController.h"
#import "WJDatePicker.h"

@interface ViewController ()
@property (nonatomic, strong) WJDatePicker *pickerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    WJDatePicker *pickerView = [[WJDatePicker alloc] initWithType:DatePickerType_YYYYMM];
    self.pickerView = pickerView;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    
    pickerView.minimunDate = [formatter dateFromString:@"2000-01"];
    pickerView.maximumDate = [formatter dateFromString:@"2018-05"];
    pickerView.timeStr = @"2015-07";
    pickerView.clickReturn = ^(NSInteger tag, NSString *timeStr) {
        if (0 == tag) { //  取消
            NSLog(@"cancel");
        } else { //  确认
            
            NSLog(@"%@",timeStr);
        }
    };
    [self.view addSubview:pickerView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
