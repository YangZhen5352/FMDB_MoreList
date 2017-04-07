//
//  UIColor+HexColor.m
//  YYHexColor
//
//  Created by 杨振 on 16/4/14.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (instancetype)shareHexColor {
    static id instance;
    static dispatch_once_t onceToKen;
    
    dispatch_once(&onceToKen, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark----------- HexColor -------------------

- (UIColor *)colorWithHex:(NSString *)hexColor
{
    return [self colorWithHex:hexColor alpha:1.0f];
}
- (UIColor *)colorWithHex:(NSString *)hexColor alpha:(float)opacity
{
    hexColor = [[hexColor
                 stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 7 characters if it includes '#'
    if ([hexColor length] < 6)
        return [UIColor blackColor];
    
    // strip # if it appears
    if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    
    // if the value isn't 6 characters at this point return
    // the color black
    if ([hexColor length] != 6)
        return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [hexColor substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [hexColor substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [hexColor substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [self colorWithIntegerRed:r green:g blue:b alpha:opacity];
}

#pragma mark----------- 红绿蓝 -------------------

- (UIColor *)colorWithIntegerRed:(NSUInteger)red
                           green:(NSUInteger)green
                            blue:(NSUInteger)blue {
    return [self colorWithIntegerRed:red green:green blue:blue alpha:1.0f];
}

- (UIColor *)colorWithIntegerRed:(NSUInteger)red
                           green:(NSUInteger)green
                            blue:(NSUInteger)blue
                           alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(red) / 255.0f
                           green:(green) / 255.0f
                            blue:(blue) / 255.0f
                           alpha:(alpha)];
}


#pragma mark----------- 纯灰色 -------------------

- (UIColor *)colorWithGray:(CGFloat)gray {
    return [self colorWithIntegerRed:gray green:gray blue:gray alpha:1.0f];
}

- (UIColor *)colorWithGray:(CGFloat)gray alpha:(CGFloat)alpha {
    return [self colorWithIntegerRed:gray green:gray blue:gray alpha:alpha];
}




@end
