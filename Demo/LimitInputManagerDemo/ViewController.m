//
//  ViewController.m
//  LimitInputManagerDemo
//
//  Created by 刘威振 on 6/6/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import "ViewController.h"
#import "ZZLimitInputManager.h"
#import "SecondController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField_1;
@property (weak, nonatomic) IBOutlet UITextField *textField_2;
@property (weak, nonatomic) IBOutlet UITextField *textField_3;
@property (weak, nonatomic) IBOutlet UITextField *textField_4;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 限制输入10个字符长度
    [ZZLimitInputManager limitInputView:self.textField_1 maxLength:10];
    
    // 限制输入15个字符长度
    [ZZLimitInputManager limitInputView:self.textField_2 maxLength:15];
    
    // 限制不可输入首字符为0
    [ZZLimitInputManager limitInputView:self.textField_3 regX:@"[^0].*"];
    
    // 限制不可输入首字符为0, 手机号码至多11位(xib中设置数字键盘)
    [ZZLimitInputManager limitPhoneInputView:self.textField_4];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)gotoSecondController:(id)sender
{
    SecondController *controller = [[SecondController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}


@end
