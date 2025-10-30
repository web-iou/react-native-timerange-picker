#import "TimerangePickerView.h"

#import <react/renderer/components/TimerangePickerViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/TimerangePickerViewSpec/EventEmitters.h>
#import <react/renderer/components/TimerangePickerViewSpec/Props.h>
#import <react/renderer/components/TimerangePickerViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface TimerangePickerView () <RCTTimerangePickerViewViewProtocol, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *separatorLabel;

@property (nonatomic, assign) NSInteger startHour;
@property (nonatomic, assign) NSInteger startMinute;
@property (nonatomic, assign) NSInteger endHour;
@property (nonatomic, assign) NSInteger endMinute;

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *confirmText;
@property (nonatomic, strong) NSString *cancelTextString;
@property (nonatomic, strong) NSString *separatorTextString;
@property (nonatomic, strong) UIColor *backgroundColorValue;
@property (nonatomic, strong) UIColor *confirmButtonColorValue;
@property (nonatomic, strong) UIColor *cancelButtonColorValue;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
//@property (nonatomic, strong) UIColor *unSelectedTextColor;

@end

@implementation TimerangePickerView {
    UIView * _view;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<TimerangePickerViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps = std::make_shared<const TimerangePickerViewProps>();
    _props = defaultProps;

    _view = [[UIView alloc] init];
    self.contentView = _view;
    
    // 初始化默认值
    _startHour = 9;
    _startMinute = 0;
    _endHour = 10;
    _endMinute = 0;
    _isVisible = NO;
    _isAnimating = NO;
    _titleText = @"选择时间段";
    _confirmText = @"确定";
    _cancelTextString = @"取消";
    _separatorTextString = @"至";
    _backgroundColorValue = [UIColor whiteColor];
    _confirmButtonColorValue = [UIColor colorWithRed:0.2 green:0.78 blue:0.35 alpha:1.0];
    _cancelButtonColorValue = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    _selectedTextColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1.0];
    [self setupPickerView];
  }

  return self;
}

- (void)setupPickerView
{
    // 创建遮罩层
    _overlayView = [[UIView alloc] init];
    _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _overlayView.alpha = 0;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOverlayTap)];
    [_overlayView addGestureRecognizer:tapGesture];
    
    // 创建容器视图
    _containerView = [[UIView alloc] init];
    _containerView.backgroundColor = _backgroundColorValue;
    _containerView.layer.cornerRadius = 16;
    _containerView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    // 创建标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = _titleText;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    _titleLabel.textColor = _textColor;
    
    // 创建PickerView
    _pickerView = [[UIPickerView alloc] init];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    // 创建分隔符标签
    _separatorLabel = [[UILabel alloc] init];
    _separatorLabel.text = _separatorTextString;
    _separatorLabel.textAlignment = NSTextAlignmentCenter;
    _separatorLabel.font = [UIFont systemFontOfSize:16];
    _separatorLabel.textColor = _textColor;
    _separatorLabel.userInteractionEnabled = NO;
    
    // 创建取消按钮
    _cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_cancelButton setTitle:_cancelTextString forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    _cancelButton.backgroundColor = _cancelButtonColorValue;
    _cancelButton.layer.cornerRadius = 25;
    [_cancelButton addTarget:self action:@selector(handleCancel) forControlEvents:UIControlEventTouchUpInside];
    
    // 创建确定按钮
    _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_confirmButton setTitle:_confirmText forState:UIControlStateNormal];
    _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _confirmButton.backgroundColor = _confirmButtonColorValue;
    _confirmButton.layer.cornerRadius = 25;
    [_confirmButton addTarget:self action:@selector(handleConfirm) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加到容器
    [_containerView addSubview:_titleLabel];
    [_containerView addSubview:_pickerView];
    [_containerView addSubview:_separatorLabel];
    [_containerView addSubview:_cancelButton];
    [_containerView addSubview:_confirmButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIWindow *window = self.window;
    if (!window) return;
    
    CGRect windowBounds = window.bounds;
    
    // 布局遮罩层
    _overlayView.frame = windowBounds;
    
    // 布局容器
    CGFloat containerHeight = 450;
    _containerView.frame = CGRectMake(0, windowBounds.size.height - containerHeight, windowBounds.size.width, containerHeight);
    
    // 布局标题
    _titleLabel.frame = CGRectMake(0, 16, windowBounds.size.width, 30);
    
    // 布局PickerView
    CGFloat pickerHeight = 250;
    _pickerView.frame = CGRectMake(0, 60, windowBounds.size.width, pickerHeight);
    
    // 分隔符已经集成到 PickerView 中，不再需要单独布局
    // _separatorLabel.frame = CGRectMake(windowBounds.size.width / 2 - 20, 60 + pickerHeight / 2 - 15, 40, 30);
    _separatorLabel.hidden = YES; // 隐藏独立的分隔符标签
    
    // 获取底部安全距离
    CGFloat bottomSafeArea = 0;
    if (@available(iOS 11.0, *)) {
        bottomSafeArea = window.safeAreaInsets.bottom;
    }
    // 如果没有安全距离，使用默认值24
    CGFloat bottomPadding = bottomSafeArea > 0 ? bottomSafeArea : 24;
    
    // 布局按钮：buttonY = containerHeight - (底部安全距离||24) - 按钮高度
    CGFloat buttonHeight = 50;
    CGFloat buttonY = containerHeight - bottomPadding - buttonHeight;
    CGFloat buttonWidth = (windowBounds.size.width - 60) / 2;
    _cancelButton.frame = CGRectMake(20, buttonY, buttonWidth, buttonHeight);
    _confirmButton.frame = CGRectMake(windowBounds.size.width - buttonWidth - 20, buttonY, buttonWidth, buttonHeight);
}

- (void)showPicker
{
    // 如果正在动画中，不执行
    if (self.isAnimating) return;
    
    UIWindow *window = self.window;
    if (!window) {
        // 如果当前没有window，尝试获取keyWindow
        window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            window = [UIApplication sharedApplication].windows.firstObject;
        }
    }
    
    if (!window) return;
    
    self.isAnimating = YES;
    
    // 确保在主线程执行
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.overlayView.superview == nil) {
            [window addSubview:self.overlayView];
            [window addSubview:self.containerView];
        }
        
        // 设置初始位置
        CGRect windowBounds = window.bounds;
        self.overlayView.alpha = 0;
        self.containerView.frame = CGRectMake(0, windowBounds.size.height, windowBounds.size.width, 450);
        
        // 设置picker初始值（5列：开始小时、开始分钟、分隔符、结束小时、结束分钟）
        [self.pickerView selectRow:self.startHour inComponent:0 animated:NO];
        [self.pickerView selectRow:self.startMinute inComponent:1 animated:NO];
        [self.pickerView selectRow:0 inComponent:2 animated:NO]; // 分隔符列
        [self.pickerView selectRow:self.endHour inComponent:3 animated:NO];
        [self.pickerView selectRow:self.endMinute inComponent:4 animated:NO];
        
        // 强制布局
        [self.containerView layoutIfNeeded];
        
        // 动画显示
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.overlayView.alpha = 1;
            self.containerView.frame = CGRectMake(0, windowBounds.size.height - 450, windowBounds.size.width, 450);
            [self.containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }];
    });
}

- (void)hidePicker
{
    [self hidePickerWithCompletion:nil];
}

- (void)hidePickerWithCompletion:(void (^)(void))completion
{
    // 如果正在动画中，不重复执行
    if (self.isAnimating) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // 检查视图是否已经被移除
    if (self.overlayView.superview == nil && self.containerView.superview == nil) {
        if (completion) {
            completion();
        }
        return;
    }
    
    UIWindow *window = self.window ?: [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    if (!window) {
        if (completion) {
            completion();
        }
        return;
    }
    
    CGRect windowBounds = window.bounds;
    
    self.isAnimating = YES;
    
    // 确保在主线程执行动画
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
            self.overlayView.alpha = 0;
            self.containerView.frame = CGRectMake(0, windowBounds.size.height, windowBounds.size.width, 450);
            [self.containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
            if (finished) {
                [self.overlayView removeFromSuperview];
                [self.containerView removeFromSuperview];
            }
            // 动画完成后执行回调
            if (completion) {
                completion();
            }
        }];
    });
}

- (void)handleOverlayTap
{
    [self handleCancel];
}

- (void)handleCancel
{
    // 先执行隐藏动画，动画完成后再触发事件
    [self hidePickerWithCompletion:^{
        if (self->_eventEmitter) {
            auto eventEmitter = std::static_pointer_cast<const TimerangePickerViewEventEmitter>(self->_eventEmitter);
            TimerangePickerViewEventEmitter::OnCancel data = {};
            eventEmitter->onCancel(data);
        }
    }];
}

- (void)handleConfirm
{
    NSString *startTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)_startHour, (long)_startMinute];
    NSString *endTime = [NSString stringWithFormat:@"%02ld:%02ld", (long)_endHour, (long)_endMinute];
    
    // 先执行隐藏动画，动画完成后再触发事件
    [self hidePickerWithCompletion:^{
        if (self->_eventEmitter) {
            auto eventEmitter = std::static_pointer_cast<const TimerangePickerViewEventEmitter>(self->_eventEmitter);
            TimerangePickerViewEventEmitter::OnConfirm data = {
                .value = {
                    std::string([startTime UTF8String]),
                    std::string([endTime UTF8String])
                }
            };
            eventEmitter->onConfirm(data);
        }
    }];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5; // 开始小时、开始分钟、分隔符、结束小时、结束分钟
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 2) {
        return 1; // 分隔符列只有一行
    } else if (component == 0 || component == 3) {
        return 24; // 小时：0-23
    } else {
        return 60; // 分钟：0-59
    }
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
    }
    
    // 分隔符列（第3列，索引为2）
    if (component == 2) {
        label.text = _separatorTextString;
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        label.textColor = _textColor;
        label.textAlignment = NSTextAlignmentLeft;
        label.userInteractionEnabled = NO; // 禁用用户交互
        return label;
    }
    
    // 根据组件和行号设置不同的样式
    if (component == 0 || component == 3) {
        // 小时列
        label.text = [NSString stringWithFormat:@"%02ld", (long)row];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
    } else {
        // 分钟列
        label.text = [NSString stringWithFormat:@"%02ld", (long)row];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
    }
    
    // 选中行的样式
    NSInteger selectedRow = [pickerView selectedRowInComponent:component];
    if (row == selectedRow) {
        label.textColor = _selectedTextColor;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    } else {
        label.font = [UIFont systemFontOfSize:14];
    }
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // 更新选中的值
    switch (component) {
        case 0:
            _startHour = row;
            break;
        case 1:
            _startMinute = row;
            break;
        case 2:
            // 分隔符列，不处理
            return;
        case 3:
            _endHour = row;
            break;
        case 4:
            _endMinute = row;
            break;
    }
    
    // 检查并调整结束时间：确保结束时间不早于开始时间
    [self validateAndAdjustEndTime:pickerView changedComponent:component];
    
    // 重新加载该组件以更新样式
    [pickerView reloadComponent:component];
}

- (void)validateAndAdjustEndTime:(UIPickerView *)pickerView changedComponent:(NSInteger)changedComponent
{
    // 计算开始时间和结束时间的总分钟数
    NSInteger startTotalMinutes = _startHour * 60 + _startMinute;
    NSInteger endTotalMinutes = _endHour * 60 + _endMinute;
    
    // 如果修改的是开始时间（component 0 或 1），需要重新加载结束时间列以更新禁用状态
    if (changedComponent == 0 || changedComponent == 1) {
        [pickerView reloadComponent:3];
        [pickerView reloadComponent:4];
    }
    
    // 如果结束时间早于或等于开始时间，需要调整
    if (endTotalMinutes <= startTotalMinutes) {
        // 结束时间 = 开始时间 + 1分钟（最小间隔）
        NSInteger newEndTotalMinutes = startTotalMinutes + 1;
        
        // 确保不超过23:59
        if (newEndTotalMinutes >= 24 * 60) {
            newEndTotalMinutes = 23 * 60 + 59; // 23:59
            
            // 如果开始时间已经是23:59，则不调整（保持当前状态）
            if (startTotalMinutes >= newEndTotalMinutes) {
                return;
            }
        }
        
        _endHour = newEndTotalMinutes / 60;
        _endMinute = newEndTotalMinutes % 60;
        
        // 更新PickerView的选中状态
        [pickerView selectRow:_endHour inComponent:3 animated:YES];
        [pickerView selectRow:_endMinute inComponent:4 animated:YES];
        
        // 重新加载结束时间的列
        [pickerView reloadComponent:3];
        [pickerView reloadComponent:4];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat totalWidth = pickerView.frame.size.width;
    
    if (component == 2) {
        // 分隔符列，占10%的宽度
        return totalWidth * 0.10;
    } else {
        // 分钟列，占21%的宽度
        return totalWidth * 0.225;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 48;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<TimerangePickerViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<TimerangePickerViewProps const>(props);

    // 处理visible属性
    if (oldViewProps.visible != newViewProps.visible) {
        _isVisible = newViewProps.visible;
        if (_isVisible) {
            [self showPicker];
        } else {
            [self hidePicker];
        }
    }
    
    // 处理title属性
    if (oldViewProps.title != newViewProps.title) {
        _titleText = [NSString stringWithUTF8String:newViewProps.title.c_str()];
        _titleLabel.text = _titleText;
    }
    
    // 处理confirmText属性
    if (oldViewProps.confirmText != newViewProps.confirmText) {
        _confirmText = [NSString stringWithUTF8String:newViewProps.confirmText.c_str()];
        [_confirmButton setTitle:_confirmText forState:UIControlStateNormal];
    }
    
    // 处理cancelText属性
    if (oldViewProps.cancelText != newViewProps.cancelText) {
        _cancelTextString = [NSString stringWithUTF8String:newViewProps.cancelText.c_str()];
        [_cancelButton setTitle:_cancelTextString forState:UIControlStateNormal];
    }
    
    // 处理separatorText属性
    if (oldViewProps.separatorText != newViewProps.separatorText) {
        _separatorTextString = [NSString stringWithUTF8String:newViewProps.separatorText.c_str()];
        _separatorLabel.text = _separatorTextString;
        // 重新加载分隔符列（第2列）
        [_pickerView reloadComponent:2];
    }
    
    // 处理backgroundColor属性
    if (oldViewProps.backgroundColor != newViewProps.backgroundColor) {
        UIColor *bgColor = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.backgroundColor.c_str()]];
        if (bgColor) {
            _backgroundColorValue = bgColor;
            _containerView.backgroundColor = bgColor;
        }
    }
    
    
    // 处理selectedColor属性（选中项文字颜色）
    if (oldViewProps.selectedColor != newViewProps.selectedColor) {
        UIColor *selectedColor = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.selectedColor.c_str()]];
        if (selectedColor) {
            _selectedTextColor = selectedColor;
            // 重新加载所有PickerView列以应用新的选中颜色
            [_pickerView reloadAllComponents];
        }
    }
    
    // 处理confirmButtonColor属性
    if (oldViewProps.confirmButtonColor != newViewProps.confirmButtonColor) {
        UIColor *btnColor = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.confirmButtonColor.c_str()]];
        if (btnColor) {
            _confirmButtonColorValue = btnColor;
            _confirmButton.backgroundColor = btnColor;
        }
    }
    
    // 处理cancelButtonColor属性
    if (oldViewProps.cancelButtonColor != newViewProps.cancelButtonColor) {
        UIColor *btnColor = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.cancelButtonColor.c_str()]];
        if (btnColor) {
            _cancelButtonColorValue = btnColor;
            _cancelButton.backgroundColor = btnColor;
        }
    }
    
    // 处理titleStyle属性
    if (oldViewProps.titleStyle.color != newViewProps.titleStyle.color ||
        oldViewProps.titleStyle.fontSize != newViewProps.titleStyle.fontSize ||
        oldViewProps.titleStyle.fontWeight != newViewProps.titleStyle.fontWeight) {
        
        CGFloat fontSize = newViewProps.titleStyle.fontSize > 0 ? newViewProps.titleStyle.fontSize : 17;
        UIFontWeight fontWeight = UIFontWeightMedium;
        
        // 将 Int32 权重转换为 UIFontWeight
        if (newViewProps.titleStyle.fontWeight > 0) {
            int weight = newViewProps.titleStyle.fontWeight;
            if (weight <= 200) fontWeight = UIFontWeightUltraLight;
            else if (weight <= 300) fontWeight = UIFontWeightLight;
            else if (weight <= 400) fontWeight = UIFontWeightRegular;
            else if (weight <= 500) fontWeight = UIFontWeightMedium;
            else if (weight <= 600) fontWeight = UIFontWeightSemibold;
            else if (weight <= 700) fontWeight = UIFontWeightBold;
            else if (weight <= 800) fontWeight = UIFontWeightHeavy;
            else fontWeight = UIFontWeightBlack;
        }
        
        _titleLabel.font = [UIFont systemFontOfSize:fontSize weight:fontWeight];
        
        if (!newViewProps.titleStyle.color.empty()) {
            UIColor *color = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.titleStyle.color.c_str()]];
            if (color) {
                _titleLabel.textColor = color;
            }
        }
    }
    
    // 处理confirmTextStyle属性
    if (oldViewProps.confirmTextStyle.color != newViewProps.confirmTextStyle.color ||
        oldViewProps.confirmTextStyle.fontSize != newViewProps.confirmTextStyle.fontSize ||
        oldViewProps.confirmTextStyle.fontWeight != newViewProps.confirmTextStyle.fontWeight) {
        
        CGFloat fontSize = newViewProps.confirmTextStyle.fontSize > 0 ? newViewProps.confirmTextStyle.fontSize : 16;
        UIFontWeight fontWeight = UIFontWeightMedium;
        
        if (newViewProps.confirmTextStyle.fontWeight > 0) {
            int weight = newViewProps.confirmTextStyle.fontWeight;
            if (weight <= 200) fontWeight = UIFontWeightUltraLight;
            else if (weight <= 300) fontWeight = UIFontWeightLight;
            else if (weight <= 400) fontWeight = UIFontWeightRegular;
            else if (weight <= 500) fontWeight = UIFontWeightMedium;
            else if (weight <= 600) fontWeight = UIFontWeightSemibold;
            else if (weight <= 700) fontWeight = UIFontWeightBold;
            else if (weight <= 800) fontWeight = UIFontWeightHeavy;
            else fontWeight = UIFontWeightBlack;
        }
        
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:fontWeight];
        
        if (!newViewProps.confirmTextStyle.color.empty()) {
            UIColor *color = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.confirmTextStyle.color.c_str()]];
            if (color) {
                [_confirmButton setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
    
    // 处理cancelTextStyle属性
    if (oldViewProps.cancelTextStyle.color != newViewProps.cancelTextStyle.color ||
        oldViewProps.cancelTextStyle.fontSize != newViewProps.cancelTextStyle.fontSize ||
        oldViewProps.cancelTextStyle.fontWeight != newViewProps.cancelTextStyle.fontWeight) {
        
        CGFloat fontSize = newViewProps.cancelTextStyle.fontSize > 0 ? newViewProps.cancelTextStyle.fontSize : 16;
        UIFontWeight fontWeight = UIFontWeightRegular;
        
        if (newViewProps.cancelTextStyle.fontWeight > 0) {
            int weight = newViewProps.cancelTextStyle.fontWeight;
            if (weight <= 200) fontWeight = UIFontWeightUltraLight;
            else if (weight <= 300) fontWeight = UIFontWeightLight;
            else if (weight <= 400) fontWeight = UIFontWeightRegular;
            else if (weight <= 500) fontWeight = UIFontWeightMedium;
            else if (weight <= 600) fontWeight = UIFontWeightSemibold;
            else if (weight <= 700) fontWeight = UIFontWeightBold;
            else if (weight <= 800) fontWeight = UIFontWeightHeavy;
            else fontWeight = UIFontWeightBlack;
        }
        
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:fontWeight];
        
        if (!newViewProps.cancelTextStyle.color.empty()) {
            UIColor *color = [self hexStringToColor:[NSString stringWithUTF8String:newViewProps.cancelTextStyle.color.c_str()]];
            if (color) {
                [_cancelButton setTitleColor:color forState:UIControlStateNormal];
            }
        }
    }
    
    // 处理value属性（受控组件）
    if (oldViewProps.value.start != newViewProps.value.start ||
        oldViewProps.value.end != newViewProps.value.end) {
        
        // 解析start时间（格式：HH:MM）
        if (!newViewProps.value.start.empty()) {
            NSString *startTime = [NSString stringWithUTF8String:newViewProps.value.start.c_str()];
            NSArray *startComponents = [startTime componentsSeparatedByString:@":"];
            if (startComponents.count == 2) {
                _startHour = [startComponents[0] integerValue];
                _startMinute = [startComponents[1] integerValue];
            }
        }
        
        // 解析end时间（格式：HH:MM）
        if (!newViewProps.value.end.empty()) {
            NSString *endTime = [NSString stringWithUTF8String:newViewProps.value.end.c_str()];
            NSArray *endComponents = [endTime componentsSeparatedByString:@":"];
            if (endComponents.count == 2) {
                _endHour = [endComponents[0] integerValue];
                _endMinute = [endComponents[1] integerValue];
            }
        }
        
        // 更新PickerView的选中状态
        if (_pickerView) {
            [_pickerView selectRow:_startHour inComponent:0 animated:NO];
            [_pickerView selectRow:_startMinute inComponent:1 animated:NO];
            [_pickerView selectRow:_endHour inComponent:3 animated:NO];
            [_pickerView selectRow:_endMinute inComponent:4 animated:NO];
            [_pickerView reloadAllComponents];
        }
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> TimerangePickerViewCls(void)
{
    return TimerangePickerView.class;
}

- (UIColor *)hexStringToColor:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *stringScanner = [NSScanner scannerWithString:noHashString];

    unsigned hex;
    if (![stringScanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;

    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

@end
