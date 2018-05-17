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
    __weak typeof(self) weakSelf = self;
    pickerView.clickReturn = ^(NSInteger tag, NSString *timeStr) {
        [weakSelf packUp];  // 收起页面

        if (0 == tag) { //  取消
            NSLog(@"cancel");
        } else { //  确认
            
            NSLog(@"%@",timeStr);
        }
    };
    [self.view addSubview:pickerView];
}

#pragma mark - 动画

/**
 展开日期选择picker
 */

- (IBAction)expand:(id)sender {
    self.pickerView.hidden = NO;
    [self showSpringAnimationWithDuration:0.3 animations:^{
        self.pickerView.alpha = 1.f;
    } completion:^{
        
    }];
}


/**
 收起日期选择picker
 */
- (void)packUp {
    [self showSpringAnimationWithDuration:0.3 animations:^{
        self.pickerView.alpha = 0.f;
    } completion:^{
        self.pickerView.hidden = YES;
    }];
}

// 动画
- (void)showSpringAnimationWithDuration:(CGFloat)duration
                             animations:(void (^)(void))animations
                             completion:(void (^)(void))completion{
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:.8 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        if (animations) {
            animations();
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
