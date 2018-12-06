//
//  SLPlateNumberInputView.h
//
//  Created by renegade on 2018/11/27.
//  Copyright © 2018年 Solar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLPlateNumberInputView;

typedef NS_ENUM(NSInteger, SLPlateNumberInputType)
{
    SLPlateNumberInputTypeProvince,
    SLPlateNumberInputTypeCharacter
};

@protocol SLPlateNumberInputViewDelegate <NSObject>

- (void)plateNumberInputViewDidSelect:(SLPlateNumberInputView *)view inputString:(NSString *)inputString;

- (void)plateNumberInputViewDidDelete:(SLPlateNumberInputView *)view;

@optional

- (void)plateNumberInputViewDidConfirm;

@end

@interface SLPlateNumberInputView : UIView

@property (nonatomic, weak) id<SLPlateNumberInputViewDelegate> delegate;

@property (nonatomic, assign) SLPlateNumberInputType inputType;

@property (nonatomic, assign) BOOL alphabetOnly;

- (instancetype)init;

- (instancetype)initWithoutToolView;

@end
