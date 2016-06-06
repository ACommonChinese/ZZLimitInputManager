//
//  ZZLimitInputManager.m
//  LimitInputManagerDemo
//
//  Created by 刘威振 on 6/6/16.
//  Copyright © 2016 LiuWeiZhen. All rights reserved.
//

#import "ZZLimitInputManager.h"
#import <objc/runtime.h>
#define zz_limitManager [ZZLimitInputManager sharedInstance]

@implementation UIView (Limit)

- (NSInteger)limitMaxLength
{
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    return [number integerValue];
}

- (void)setLimitMaxLength:(NSInteger)limitMaxLength
{
    objc_setAssociatedObject(self, @selector(limitMaxLength), @(limitMaxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)limitRegx
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLimitRegx:(NSString *)limitRegx
{
    objc_setAssociatedObject(self, @selector(limitRegx), limitRegx, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UITextView (Limit)

@end

@implementation ZZLimitInputManager

static ZZLimitInputManager *g_limitInput;

+ (ZZLimitInputManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_limitInput = [[ZZLimitInputManager alloc] init];
    });
    return g_limitInput;
}

+ (void)limitInputView:(UIView<UITextInput> *)view maxLength:(NSUInteger)length
{
    NSAssert([view conformsToProtocol:@protocol(UITextInput)], @"view必须实现UITextInput协议，即view对象当是UITextField或UITextView对象");
    view.limitMaxLength = length;
    [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitLength:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitLength:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textInputViewDidChangeLimitLength:(NSNotification *)notification
{
    UIView<UITextInput> *inputView = (UIView<UITextInput> *)notification.object;
    NSString *key                  = @"text";
    NSString *text                 = [inputView valueForKey:key];
    NSInteger length               = inputView.limitMaxLength;
    if (length > 0 && text.length > length && inputView.markedTextRange == nil)
    {
        [inputView setValue:[text substringWithRange: NSMakeRange(0, length)] forKey:key];
    }
}

+ (void)limitInputView:(UIView<UITextInput> *)view regX:(NSString *)regx
{
    view.limitRegx = regx;
    [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitRegx:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitRegx:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textInputViewDidChangeLimitRegx:(NSNotification *)notification
{
    UIView<UITextInput> *inputView = (UIView<UITextInput> *)notification.object;
    NSString *regx = inputView.limitRegx;
    NSString *key  = @"text";
    NSString *text = [inputView valueForKey:key];
    if (regx && text.length > 0)
    {
        NSError *error = nil;
        NSRegularExpression *express = [NSRegularExpression regularExpressionWithPattern:regx options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange validRange = [express rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        if (validRange.location == NSNotFound)
        {
            [inputView setValue:nil forKey:key];
        }
        else
        {
            [inputView setValue:[text substringFromIndex:validRange.location] forKey:key];
        }
        /** Apis
         [express stringByReplacingMatchesInString:(nonnull NSString *) options:(NSMatchingOptions) range:(NSRange) withTemplate:(nonnull NSString *)];
         NSArray<NSTextCheckingResult *> *matchArray = [express matchesInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
         NSTextCheckingResult *result = matchArray.lastObject;
         [express firstMatchInString:(nonnull NSString *) options:(NSMatchingOptions) range:(NSRange)];
         [express rangeOfFirstMatchInString:(nonnull NSString *) options:(NSMatchingOptions) range:(NSRange)];
         */
    }
}

+ (void)limitPhoneInputView:(UIView<UITextInput> *)view
{
    [self limitInputView:view maxLength:11];
    [self limitInputView:view regX:@"[^0].*"];
}

@end
