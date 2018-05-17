//
//  WJDatePicker.h
//  WJDatePicker
//
//  Created by Adward on 2018/5/17.
//  Copyright © 2018年 Adward. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 type
 
 - DatePickerType_YYYYMMDD: 显示年月日（用的系统的datePicker）
 - DatePickerType_YYYYMM: 显示年月（自定义picker）
 */
typedef NS_ENUM(NSUInteger,DatePickerType) {
    DatePickerType_YYYYMMDD,
    DatePickerType_YYYYMM
};

// 点击取消或确认的回调方法
typedef void(^DatePickerClickReturnBlock)(NSInteger tag, NSString *timeStr);


@interface WJDatePicker : UIView


/**
 日期选择器选择的时间
 */
@property (nonatomic, strong) NSString *timeStr;

@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *minimunDate;

@property (nonatomic, assign) DatePickerType pickerType;
/**
 点击取消或确认的回调方法
 */
@property (nonatomic, copy) DatePickerClickReturnBlock clickReturn;

- (instancetype)initWithType:(DatePickerType)type;

- (NSString *)minYear;
- (NSString *)maxYear;
- (NSString *)minMonth;
- (NSString *)maxMonth;



@end
