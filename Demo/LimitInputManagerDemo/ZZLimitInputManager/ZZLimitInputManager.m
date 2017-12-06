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

////////////////////////////////////////////////////////////////////////
//               ZZInputViewLimitInfo 保存limit信息模型               //
////////////////////////////////////////////////////////////////////////

@interface ZZInputViewLimitInfo : NSObject

@property (nonatomic) NSInteger limitMaxLength;
@property (nonatomic, copy) NSString *limitRegx;
@property (nonatomic, copy) NSString *validText;
@end

@implementation ZZInputViewLimitInfo
@end

@interface UIView (Limit)

@property (nonatomic) ZZInputViewLimitInfo *zz_limitInfo;
@end

////////////////////////////////////////////////////////////////////////
//             UIView(Limit) 动态关联属性ZZInputViewLimitInfo         //
////////////////////////////////////////////////////////////////////////

@implementation UIView (Limit)

- (ZZInputViewLimitInfo *)zz_limitInfo {
    ZZInputViewLimitInfo *info = objc_getAssociatedObject(self, _cmd);
    if (!info) {
        [self setZz_limitInfo:[[ZZInputViewLimitInfo alloc] init]];
        info = objc_getAssociatedObject(self, _cmd);
    }
    return info;
}

- (void)setZz_limitInfo:(ZZInputViewLimitInfo *)zz_limitInfo {
    objc_setAssociatedObject(self, @selector(zz_limitInfo), zz_limitInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UITextView (Limit)

@end

////////////////////////////////////////////////////////////////////////
//                          ZZLimitInputManager                       //
////////////////////////////////////////////////////////////////////////

@implementation ZZLimitInputManager

static ZZLimitInputManager *g_limitInput;

+ (ZZLimitInputManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_limitInput = [[ZZLimitInputManager alloc] init];
    });
    return g_limitInput;
}

+ (void)limitInputView:(UIView<UITextInput> *)view maxLength:(NSUInteger)length {
    NSAssert([view conformsToProtocol:@protocol(UITextInput)], @"view必须实现UITextInput协议，即view对象当是UITextField或UITextView对象");
    view.zz_limitInfo.limitMaxLength = length;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitLength:) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitLength:) name:UITextViewTextDidChangeNotification object:nil];
    });
}

+ (void)limitInputView:(UIView<UITextInput> *)view regX:(NSString *)regx {
    view.zz_limitInfo.limitRegx = regx;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitRegx:) name:UITextFieldTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:zz_limitManager selector:@selector(textInputViewDidChangeLimitRegx:) name:UITextViewTextDidChangeNotification object:nil];
    });
}

- (void)textInputViewDidChangeLimitLength:(NSNotification *)notification {
    UIView<UITextInput> *inputView = (UIView<UITextInput> *)notification.object;
    if ([inputView isFirstResponder] == NO) return;
    NSString *key                  = @"text";
    NSString *text                 = [inputView valueForKey:key];
    NSInteger length               = inputView.zz_limitInfo.limitMaxLength;
    if (length <= 0) return;
    // NSLog(@"limit length");
    if (length > 0 && text.length > length && inputView.markedTextRange == nil) {
        NSString *validText = [text substringWithRange: NSMakeRange(0, length)];
        inputView.zz_limitInfo.validText = validText;
        [inputView setValue:validText forKey:key];
    }
}

- (void)textInputViewDidChangeLimitRegx:(NSNotification *)notification {
    UIView<UITextInput> *inputView = (UIView<UITextInput> *)notification.object;
    if ([inputView isFirstResponder] == NO) {
        return;
    }
    NSString *regx = inputView.zz_limitInfo.limitRegx;
    if (!regx) {
        return;
    }
    // NSLog(@"limit regex");
    NSString *key  = @"text";
    NSString *text = [inputView valueForKey:key];
    if (regx && text.length > 0) {
        NSError *error = nil;
        NSRegularExpression *express = [NSRegularExpression regularExpressionWithPattern:regx options:NSRegularExpressionCaseInsensitive error:&error];
        NSRange validRange = [express rangeOfFirstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
        if (validRange.location == NSNotFound) {
            NSString *validText = inputView.zz_limitInfo.validText? : nil;
            [inputView setValue:validText forKey:key];
        } else {
            NSString *validText = [text substringFromIndex:validRange.location];
            inputView.zz_limitInfo.validText = validText;
            [inputView setValue:validText forKey:key];
        }
        /** Apis
         [express stringByReplacingMatchesInString:(nonnull NSString *) options:(NSMatchingOptions) range:(NSRange) withTemplate:(nonnull NSString *)];
         NSArray<NSTextCheckingResult *> *matchArray = [express matchesInString:textField.text options:0 range:NSMakeRange(0, textField.text.length)];
         NSTextCheckingResult *result = matchArray.lastObject;
         [express firstMatchInString:(nonnull NSString *) options:(NSMatchingOptions) range:(NSRange)];
         [express rangeOfFirstMatchInString:(nonnull NSString *) options:(NSMatchingOptions) range:(NSRange)];
         */
    } else {
        inputView.zz_limitInfo.validText = nil;
        [inputView setValue:nil forKey:key];
    }
}

@end
