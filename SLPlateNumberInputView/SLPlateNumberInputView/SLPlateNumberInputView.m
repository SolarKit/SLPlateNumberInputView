//
//  SLPlateNumberInputView.m
//
//  Created by renegade on 2018/11/27.
//  Copyright © 2018年 Solar. All rights reserved.
//

#import "SLPlateNumberInputView.h"

#define kViewHeight 217.0f
#define kViewPlusHeight 228.0f
#define kCellNumsPerLine 10.0f

#define kCollectionViewItemLeftPadding 7.0f
#define kCollectionViewItemRadio (4.0f/3.0f)
#define kToolViewHeight 44.0f

@interface SLPlateNumberCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UILabel *label;
@end

@implementation SLPlateNumberCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_white"]];
    [self.contentView addSubview:_background];
    
    _label = [[UILabel alloc] init];
    _label.font = [UIFont systemFontOfSize:17.0f];
    _label.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_label];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _background.frame = self.frame;
    _label.frame = self.frame;
    _background.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _label.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}
@end

@interface SLPlateNumberInputView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *toolView;

@property (nonatomic, strong) UIImageView *indicator;

@property (nonatomic, strong) UILabel *indicatorLabel;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) NSArray *provinceArray;

@property (nonatomic, strong) NSArray *characterArray;

@end

@implementation SLPlateNumberInputView {
    CGFloat _itemWidth;
    CGFloat _itemLinePadding;
    BOOL _shouldShowToolView;
    __weak SLPlateNumberCell *_currentOpearteCell;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldShowToolView = YES;
        [self initialize];
        [self setUI];
    }
    return self;
}

- (instancetype)initWithoutToolView {
    self = [super init];
    if (self) {
        [self initialize];
        [self setUI];
    }
    return self;
}

- (void)initialize {
    self.provinceArray = @[
                           @[@"京",@"沪",@"粤",@"津",@"冀",@"晋",@"辽",@"蒙",@"黑",@"吉"],
                           @[@"苏",@"浙",@"皖",@"闽",@"赣",@"鲁",@"豫",@"鄂",@"湘"],
                           @[@"川",@"贵",@"云",@"渝",@"桂",@"琼",@"藏",@"陕"],
                           @[@"甘",@"青",@"宁",@"新",@"台"]
                           ];
    self.characterArray = @[
                            @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0"],
                            @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"J",@"K"],
                            @[@"L",@"M",@"N",@"P",@"Q",@"R",@"S",@"T",@"U",@"V"],
                            @[@"W",@"X",@"Y",@"Z",@"港",@"澳",@"学",@"领"]
                            ];
    
}

- (void)setUI {
    CGFloat topPadding = 0.0f;
    CGFloat bottomPadding = 0.0f;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        bottomPadding = window.safeAreaInsets.bottom;
    }
    if (_shouldShowToolView) {
        topPadding = kToolViewHeight;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (screenWidth > 375.0) {
        self.frame = CGRectMake(0, 0, screenWidth, kViewPlusHeight + topPadding + bottomPadding);
    }else {
        self.frame = CGRectMake(0, 0, screenWidth, kViewHeight + topPadding + bottomPadding);
    }
    self.backgroundColor = [UIColor colorWithRed:0.82 green:0.84 blue:0.85 alpha:1.00];

    //toolView
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kToolViewHeight)];
    self.toolView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [confirmButton setTitle:@"完成" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.frame = CGRectMake(screenWidth - 70 , 0, 70, kToolViewHeight);
    [self.toolView addSubview:confirmButton];
    self.toolView.hidden = !_shouldShowToolView;
    [self addSubview:self.toolView];
    
    //collectionView
    CGFloat collectionViewHeight = CGRectGetHeight(self.frame) - topPadding - bottomPadding;
    CGFloat itemWidth = (screenWidth - (kCellNumsPerLine * kCollectionViewItemLeftPadding)) / kCellNumsPerLine;
    _itemWidth = CGFloatPixelRound(itemWidth);
    _itemLinePadding = CGFloatPixelRound((collectionViewHeight - 4 * _itemWidth * kCollectionViewItemRadio) / 5.0);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(_itemWidth, _itemWidth * kCollectionViewItemRadio);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = kCollectionViewItemLeftPadding - 1;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, topPadding, screenWidth, collectionViewHeight) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[SLPlateNumberCell class] forCellWithReuseIdentifier:@"SLPlateNumberCell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.canCancelContentTouches = NO;
    self.collectionView.multipleTouchEnabled = NO;
    self.collectionView.backgroundView = [UIView new];
    self.collectionView.userInteractionEnabled = NO;
    [self addSubview:self.collectionView];
    
    //indicator
    self.indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"key_indicator"]];
    self.indicator.frame = CGRectMake(0, 0, _itemWidth+37, 3*_itemWidth);
    self.indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, CGRectGetWidth(self.indicator.frame), 30)];
    self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.indicatorLabel.font = [UIFont systemFontOfSize:27.0f];
    self.indicatorLabel.center = CGPointMake(CGRectGetWidth(self.indicator.frame)/2.0, self.indicatorLabel.center.y);
    [self.indicator addSubview:self.indicatorLabel];
    self.indicator.hidden = YES;
    [self addSubview:self.indicator];
    
    //deleteButton
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 2 * _itemWidth - kCollectionViewItemLeftPadding, self.frame.size.height - (_itemWidth * kCollectionViewItemRadio) - _itemLinePadding - bottomPadding - 1, 2 * _itemWidth, _itemWidth * kCollectionViewItemRadio)];
    self.deleteButton.layer.cornerRadius = 4.0f;
    self.deleteButton.layer.masksToBounds = YES;
    [self.deleteButton setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.68 green:0.70 blue:0.74 alpha:1.00] size:CGSizeMake(4, 4)] forState:UIControlStateNormal];
    [self.deleteButton setBackgroundImage:[self imageWithColor:[UIColor whiteColor] size:CGSizeMake(4, 4)] forState:UIControlStateHighlighted];
    [self.deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
}

- (void)deleteAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(plateNumberInputViewDidDelete:)]) {
        [self.delegate plateNumberInputViewDidDelete:self];
    }
}

- (void)confirmAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(plateNumberInputViewDidConfirm)]) {
        [self.delegate plateNumberInputViewDidConfirm];
    }
}

- (void)setInputType:(SLPlateNumberInputType)inputType {
    if (inputType != _inputType) {
        [self.collectionView reloadData];
    }
    _inputType = inputType;
}

- (void)setAlphabetOnly:(BOOL)alphabetOnly {
    if (alphabetOnly != _alphabetOnly) {
        [self.collectionView reloadData];
    }
    _alphabetOnly = alphabetOnly;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _currentOpearteCell = [self cellForTouches:touches];
    if ([self cellTouchShouldBegin:_currentOpearteCell]) {
        [self showIndicatorForCell:_currentOpearteCell];
        //[[UIDevice currentDevice] playInputClick];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SLPlateNumberCell *cell = [self cellForTouches:touches];
    if (cell != _currentOpearteCell) {
        _currentOpearteCell = cell;
        [self showIndicatorForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SLPlateNumberCell *cell = [self cellForTouches:touches];
    if (cell && [self cellTouchShouldBegin:cell]) {
        if ([self.delegate respondsToSelector:@selector(plateNumberInputViewDidSelect:inputString:)]) {
            [self.delegate plateNumberInputViewDidSelect:self inputString:cell.label.text];
        }
    }
    [self hideIndicator];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideIndicator];
}

- (SLPlateNumberCell *)cellForTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    if (indexPath) {
        SLPlateNumberCell *cell = (id)[self.collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (BOOL)cellTouchShouldBegin:(SLPlateNumberCell *)cell {
    if (!cell) {
        return NO;
    }
    NSString *text = cell.label.text;
    if (_alphabetOnly && text.length > 0) {
        unichar c = [text characterAtIndex:0];
        if (!isalpha(c)) {
            return NO;
        }
    }
    return YES;
}

- (void)showIndicatorForCell:(SLPlateNumberCell *)cell {
    if (!cell) {
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    _indicator.center = CGPointMake(CGRectGetMidX(rect), _indicator.center.y);
    CGRect frame = _indicator.frame;
    frame.origin.y = CGRectGetMaxY(rect) - frame.size.height;
    _indicator.frame = frame;
    _indicator.hidden = NO;
    _indicatorLabel.text = cell.label.text;
}

- (void)hideIndicator {
    _indicator.hidden = YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_inputType == SLPlateNumberInputTypeProvince) {
        return self.provinceArray.count;
    }else {
        return self.characterArray.count;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_inputType == SLPlateNumberInputTypeProvince) {
        return [self.provinceArray[section] count];
    }else {
        return [self.characterArray[section] count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SLPlateNumberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SLPlateNumberCell" forIndexPath:indexPath];
    cell.label.textColor = [UIColor blackColor];
    
    if (_inputType == SLPlateNumberInputTypeProvince) {
        cell.label.text = self.provinceArray[indexPath.section][indexPath.row];
    }else {
        cell.label.text = self.characterArray[indexPath.section][indexPath.row];
        if (![self cellTouchShouldBegin:cell]) {
            cell.label.textColor = [UIColor lightGrayColor];
        }
    }
    
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (_inputType == SLPlateNumberInputTypeProvince) {
        NSInteger nums = [self.provinceArray[section] count];
        CGFloat padding = ([UIScreen mainScreen].bounds.size.width - nums * _itemWidth - ((nums - 1) * kCollectionViewItemLeftPadding)) / 2.0;
        padding = CGFloatPixelRound(padding);
        return UIEdgeInsetsMake(_itemLinePadding, padding, 0, padding);
    }
    return UIEdgeInsetsMake(_itemLinePadding, CGFloatPixelRound(kCollectionViewItemLeftPadding/2.0), 0, CGFloatPixelRound(kCollectionViewItemLeftPadding/2.0));
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

static inline CGFloat CGFloatPixelRound(CGFloat value) {
    CGFloat scale = [UIScreen mainScreen].scale;
    return round(value * scale) / scale;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize imageSize = image.size;
    UIEdgeInsets insets = UIEdgeInsetsMake(truncf(imageSize.height-1)/2, truncf(imageSize.width-1)/2, truncf(imageSize.height-1)/2, truncf(imageSize.width-1)/2);
    return [image resizableImageWithCapInsets:insets];
}

@end
