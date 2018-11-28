//
//  ViewController.m
//  SLPlateNumberInputView
//
//  Created by renegade on 2018/11/28.
//  Copyright © 2018年 Solar. All rights reserved.
//

#import "ViewController.h"
#import "SLPlateNumberInputView.h"

@interface ViewController ()<SLPlateNumberInputViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tf;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //如果有用IQKeyboard的可以用注释掉的初始化方式
//    SLPlateNumberInputView *picker = [[SLPlateNumberInputView alloc] initWithoutToolView];
    
    SLPlateNumberInputView *picker = [[SLPlateNumberInputView alloc] init];
    picker.delegate = self;
    self.tf.inputView = picker;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tf becomeFirstResponder];
}

- (void)plateNumberInputViewDidSelect:(SLPlateNumberInputView *)view inputString:(NSString *)inputString {
    self.tf.text = [self.tf.text stringByAppendingString:inputString];
    if (self.tf.text.length == 1) {
        [view changeInputType:SLPlateNumberInputTypeCharacter];
    }
}

- (void)plateNumberInputViewDidDelete:(SLPlateNumberInputView *)view {
    [self.tf deleteBackward];
    if (self.tf.text.length == 0) {
        [view changeInputType:SLPlateNumberInputTypeProvince];
    }
}

- (void)plateNumberInputViewDidConfirm {
    [self.tf resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
