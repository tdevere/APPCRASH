//
//  Utility.h
//  CareConnect
//
//  Created by Karthi Nalliyappan on 24/09/16.
//  Copyright © 2016 ConcertCare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utility : NSObject
+ (void)showAlert:(NSString *)Title withMessage:(NSString *)Message withCancelButtonTitle:(NSString *)CancelButtonTitle;
+ (void)showAlert:(NSString *)Title withMessage:(NSString *)Message withActions:(NSArray *)AlertActions;
+ (UIViewController*)topMostController;
+ (void)toastMessage:(NSString *)message;
@end
