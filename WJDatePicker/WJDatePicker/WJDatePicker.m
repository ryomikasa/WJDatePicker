//
//  WJDatePicker.m
//  WJDatePicker
//
//  Created by Adward on 2018/5/17.
//  Copyright © 2018年 Adward. All rights reserved.
//

#import "WJDatePicker.h"

#define IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define  kTabbarHeight         (IS_iPhoneX ? (49.f+34.f) : 49.f)
#define kScreenWidth                ([UIScreen mainScreen].bounds.size.width)   //屏幕宽度
#define kScreenHeight               ([UIScreen mainScreen].bounds.size.height)  //屏幕高度


#define DATEPICKERHEIGHT (200)
#define BTNHEIGHT (42)
#define BASETAG (3000)

@interface WJDatePicker()
// 时间选择器
@property (nonatomic, strong) UIDatePicker *datePicker;
//年月选择器
@property (nonatomic, strong) UIPickerView *pickerView;
// 取消按钮
@property (nonatomic, strong) UIButton *cancelBtn;
// 确认按钮
@property (nonatomic, strong) UIButton *confirmBtn;
//年月数据源
@property (nonatomic, copy) NSArray *yearsArr;
@property (nonatomic, copy) NSArray *monthsArr;

@end

@implementation WJDatePicker

-(void)dealloc
{
    self.yearsArr = nil;
    self.monthsArr = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSInteger height = DATEPICKERHEIGHT + BTNHEIGHT;
        self.frame = CGRectMake(0, kScreenHeight - height - kTabbarHeight, kScreenWidth, height);
        self.backgroundColor = [UIColor whiteColor];
        [self creatMainView];
    }
    return self;
}

- (instancetype)initWithType:(DatePickerType)type
{
    self = [super init];
    if (self) {
        self.hidden = YES;
        self.pickerType = type;
        NSInteger height = DATEPICKERHEIGHT + BTNHEIGHT;
        self.frame = CGRectMake(0, kScreenHeight - height - kTabbarHeight, kScreenWidth, height);
        self.backgroundColor = [UIColor whiteColor];
        [self creatMainView];
    }
    return self;
}

#pragma mark - 创建主视图
- (void)creatMainView{
    
    UIView *view = nil;
    // 日期选择器
    if (self.pickerType == DatePickerType_YYYYMMDD) {
        [self createDatePicker];
        view = self.datePicker;
    }else if (self.pickerType == DatePickerType_YYYYMM){
        [self createPicker];
        view = self.pickerView;
    }
    
    
    // 取消按钮
    _cancelBtn = [self buttonWithTitle:@"取消" index:0];
    
    _cancelBtn.frame = CGRectMake(0, view.frame.origin.y-BTNHEIGHT, kScreenWidth/2.0, BTNHEIGHT);
    
    // 确认按钮
    _confirmBtn = [self buttonWithTitle:@"确定" index:1];

    _confirmBtn.frame = CGRectMake(kScreenWidth/2.0, view.frame.origin.y-BTNHEIGHT, kScreenWidth/2.0, BTNHEIGHT);
    
    // 分割线
    UIView *line = [self createSeparateLine];

    line.frame = CGRectMake(0, CGRectGetMaxY(_confirmBtn.frame), kScreenWidth, 1);
}

- (UIView *)createSeparateLine
{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:line];
    return line;
}

- (UIButton *)buttonWithTitle:(NSString *)title index:(NSInteger)index {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.tag = BASETAG + index;
    [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger edgeInset = kScreenWidth/2.0 - 15 - (BTNHEIGHT * 2);
    if (0 == index) {
        // 取消
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -edgeInset, 0, 0)];
    } else {
        // 确认
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -edgeInset)];
    }
    [self addSubview:btn];
    return btn;
}
#pragma mark - public setter

-(void)setMaximumDate:(NSDate *)maximumDate
{
    _maximumDate = maximumDate;
    if (self.pickerType == DatePickerType_YYYYMMDD) {
        self.datePicker.maximumDate = maximumDate;
    }else if (self.pickerType == DatePickerType_YYYYMM) {
        [self configDateYearRange];
    }
}

-(void)setMinimunDate:(NSDate *)minimunDate
{
    _minimunDate = minimunDate;
    if (self.pickerType == DatePickerType_YYYYMMDD) {
        self.datePicker.minimumDate = minimunDate;
    }else if (self.pickerType == DatePickerType_YYYYMM) {
        [self configDateYearRange];
    }
}


-(NSString *)minYear
{
    return self.yearsArr.firstObject;
}

-(NSString *)maxYear
{
    return self.yearsArr.lastObject;
}

-(NSString *)minMonth
{
    return self.monthsArr.firstObject;
}

-(NSString *)maxMonth
{
    return self.monthsArr.lastObject;
}


#pragma mark - events

// datePicker值改变
- (void)valueTopChanged:(UIDatePicker *)datePicker{
    // 可以在这里做监听
}

- (void)setTimeStr:(NSString *)timeStr {
    _timeStr = timeStr;
    //年月日 直接设置datepicker
    if (self.pickerType == DatePickerType_YYYYMMDD)
    {
        if (_timeStr.length < 10) {
            _timeStr = [timeStr stringByAppendingString:@"-01"];
        }
        UIDatePicker *datePicker = [self datePicker];
        NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
        [dateForm setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateForm dateFromString:_timeStr];
        [datePicker setDate:date animated:NO];
    }
    //年月，用自定义的picker显示
    else if (self.pickerType == DatePickerType_YYYYMM)
    {
        if (timeStr.length != 7) {
            return;
        }
        
        [self updateMonthSourceWithDateString:timeStr];
        
        NSString *year = [timeStr substringWithRange:NSMakeRange(0, 4)];
        NSString *month = [timeStr substringWithRange:NSMakeRange(5, 2)];
        NSInteger mon = [month integerValue];
        month = [NSString stringWithFormat:@"%@",@(mon)];
        NSInteger yIndex = [self.yearsArr indexOfObject:year];
        NSInteger mIndex = [self.monthsArr indexOfObject:month];
        if (yIndex >= 0 && yIndex < self.yearsArr.count)
        {
            [self.pickerView selectRow:yIndex inComponent:0 animated:YES];
        }
        if (mIndex >= 0 && mIndex < self.monthsArr.count)
        {
            [self.pickerView selectRow:mIndex inComponent:1 animated:YES];
        }
    }
    
}

// 确认/取消按钮事件
- (void)btnAction:(UIButton *)btn {
    if (self.clickReturn) {
        if (self.pickerType == DatePickerType_YYYYMMDD)
        {
            NSDate *date = [self datePicker].date;
            NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
            [dateForm setDateFormat:@"yyyy-MM"];
            NSString *dateStr = [dateForm stringFromDate:date];
            _timeStr = dateStr;
            self.clickReturn((btn.tag - BASETAG), _timeStr);
        }
        else if (self.pickerType == DatePickerType_YYYYMM)
        {
            NSInteger yIndex = [self.pickerView selectedRowInComponent:0];
            NSString *year = self.yearsArr[yIndex];
            NSInteger mIndex = [self.pickerView selectedRowInComponent:1];
            NSString *month = self.monthsArr[mIndex];
            if (month.integerValue < 10) {
                month = [NSString stringWithFormat:@"0%@",month];
            }
            _timeStr = [NSString stringWithFormat:@"%@-%@",year,month];
            self.clickReturn((btn.tag - BASETAG), _timeStr);
        }
    }
}


#pragma mark - ##############DatePickerType_YYYYMMDD########
// 日期选择器
- (UIDatePicker *)datePicker
{
    if (_datePicker == nil) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
        datePicker.backgroundColor = [UIColor whiteColor];
        
        NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
        datePicker.locale = locale;
        [self addSubview:datePicker];
        datePicker.frame = CGRectMake(0, BTNHEIGHT, kScreenWidth, DATEPICKERHEIGHT);
        _datePicker = datePicker;
    }
    return _datePicker;
}

// 创建datePicker
- (void)createDatePicker {
    UIDatePicker *datePicker = [self datePicker];
    NSDate *date =[NSDate date];
    [datePicker setDate:date animated:YES];
    [datePicker addTarget:self
                   action:@selector(valueTopChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
    [dateForm setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [dateForm stringFromDate:date];
    _timeStr = dateStr;
}

#pragma mark - ###########DatePickerType_YYYYMM#########

- (void)createPicker;
{
    //构造可选年的数组
    [self pickerView];
    [self configDateYearRange];
}

- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView = [UIPickerView new];
        _pickerView.delegate = (id<UIPickerViewDelegate>)self;
        _pickerView.dataSource = (id<UIPickerViewDataSource>) self;
        [self addSubview:_pickerView];
        _pickerView.frame = CGRectMake(0, BTNHEIGHT, kScreenWidth, DATEPICKERHEIGHT);
    }
    return _pickerView;
}

/**
 设置datePicker显示的年的取值区间
 */
- (void)configDateYearRange
{
    NSDate *max = self.maximumDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *yearMaxStr = [[formatter stringFromDate:max] substringToIndex:4];
    NSInteger yearMax = [yearMaxStr integerValue];
    
    NSDate *min = self.minimunDate;
    NSString *yearMinStr = [[formatter stringFromDate:min] substringToIndex:4];
    NSInteger yearMin = [yearMinStr integerValue];
    
    
    NSMutableArray *ret = [NSMutableArray array];
    for (NSInteger i = yearMin; i <= yearMax; i ++) {
        [ret addObject:[NSString stringWithFormat:@"%@",@(i)]];
    }
    
    self.yearsArr = ret;
}


/**
 把日期字符串转化为picker的数据源
 
 @param dateString 日期字符串
 */
- (void)updateMonthSourceWithDateString:(NSString *)dateString
{
    NSString *yearStr = [dateString substringToIndex:4];
    NSString *monthStr = nil;
    
    
    NSDate *max = self.maximumDate;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *yearMaxStr = [[formatter stringFromDate:max] substringToIndex:4];
    NSInteger yearMax = [yearMaxStr integerValue];
    
    BOOL isThisYear = [yearStr integerValue] == yearMax;
    
    if (isThisYear) {
        
        NSDate *max = self.maximumDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM"];
        monthStr = [[formatter stringFromDate:max] substringFromIndex:5];
        
        
    }else {
        monthStr = @"12";
    }
    
    NSMutableArray *months = [NSMutableArray array];
    NSInteger month = [monthStr integerValue];
    for (NSInteger i = 1; i <= month ; i ++) {
        [months addObject:[NSString stringWithFormat:@"%@",@(i)]];
    }
    
    self.monthsArr = months;
}


/**
 切换年之后要更新月的显示
 */
- (void)updateMonthArr
{
    NSMutableArray *months = [NSMutableArray array];
    if ([self.pickerView selectedRowInComponent:0] == self.yearsArr.count-1) {
        NSDate *max = self.maximumDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM"];
        NSString *monthStr = [[formatter stringFromDate:max] substringFromIndex:5];
        
        NSInteger month = [monthStr integerValue];
        for (NSInteger i = 1; i <= month ; i ++) {
            [months addObject:[NSString stringWithFormat:@"%@",@(i)]];
        }
        self.monthsArr = months;
        
    }else {
        for (NSInteger i = 1; i <= 12 ; i ++) {
            [months addObject:[NSString stringWithFormat:@"%@",@(i)]];
        }
        self.monthsArr = months;
    }
}

#pragma mark - datasource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 2;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (component == 0) {
        return self.yearsArr.count;
    }else if (component == 1) {
        return self.monthsArr.count;
    }
    return 0;
}
#pragma mark delegate

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    return kScreenWidth/2.f;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (component == 0) {
        return [NSString stringWithFormat:@"%@年",self.yearsArr[row]];;
    }else if (component == 1) {
        return [NSString stringWithFormat:@"%@月",self.monthsArr[row]];;
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (component == 0) {
        [self updateMonthArr];
        [pickerView reloadComponent:1];
    }
}



@end
