//
//  UIColor+HexColor.h
//  YYHexColor
//
//  Created by 杨振 on 16/4/14.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import <UIKit/UIKit.h>

// Hex_Color
#define YYColorHex(hexColor) [[UIColor shareHexColor] colorWithHex:hexColor]
#define YYColorHexAlpha(hexColor, opacity) [[UIColor shareHexColor] \
colorWithHex:hexColor alpha:opacity]

// RGB_Color
#define YYColorRGB(r, g, b) [[UIColor shareHexColor] colorWithIntegerRed:r green:g blue:b alpha:1.0f]
#define YYColorRGBA(r, g, b, a) [[UIColor shareHexColor] colorWithIntegerRed:r green:g blue:b alpha:a]

// Gray_Color
#define YYColorGray(g) [[UIColor shareHexColor] colorWithGray:g]
#define YYColorGrayAlpha(g, a) [[UIColor shareHexColor] \
colorWithGray:g alpha:a]

@interface UIColor (HexColor)

+ (instancetype)shareHexColor;

// Hex_Color
- (UIColor *)colorWithHex:(NSString *)hexColor;
- (UIColor *)colorWithHex:(NSString *)hexColor alpha:(float)opacity;

// RGB_Color
- (UIColor *)colorWithIntegerRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue;
- (UIColor *)colorWithIntegerRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue alpha:(CGFloat)alpha;

// Gray_Color
- (UIColor *)colorWithGray:(CGFloat)gray;
- (UIColor *)colorWithGray:(CGFloat)gray alpha:(CGFloat)alpha;



@end
