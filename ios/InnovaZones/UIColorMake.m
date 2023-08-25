//
//  UIColorMake.m
//  CareonTel
//
//  Created by Selvin Durai on 02/11/16.
//  Copyright © 2016 ConcertCare. All rights reserved.
//

#import "UIColorMake.h"

@implementation UIColorMake

+ (UIColor *)ColorFromString:(NSString *)ColorString {
    @try {
        ColorString = [ColorString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"# "]];
        if(ColorString != nil && [ColorString length] == 6) {
            unsigned int r, g, b;
            NSString *rString = [ColorString substringWithRange: NSMakeRange(0, 2)];
            NSString *gString = [ColorString substringWithRange: NSMakeRange(2, 2)];
            NSString *bString = [ColorString substringWithRange: NSMakeRange(4, 2)];
            
            [[NSScanner scannerWithString:rString] scanHexInt:&r];
            [[NSScanner scannerWithString:gString] scanHexInt:&g];
            [[NSScanner scannerWithString:bString] scanHexInt:&b];
            return [UIColor colorWithRed:((float) r / 255.0f)  green:((float) g / 255.0f)  blue:((float) b / 255.0f)  alpha:1.0f];
        }
    }@catch (NSException *ex) {
        
    }
    return [UIColor clearColor];
}
@end
