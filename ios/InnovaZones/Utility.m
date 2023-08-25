//
//  Utility.m
//  CareConnect
//
//  Created by Karthi Nalliyappan on 24/09/16.
//  Copyright © 2016 ConcertCare. All rights reserved.
//

#import "Utility.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation Utility

+ (void)showAlert:(NSString *)Title withMessage:(NSString *)Message withCancelButtonTitle:(NSString *)CancelButtonTitle {
    if ([UIAlertController class]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:Title message:Message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [[Utility topMostController] presentViewController:alert animated:YES completion:nil];
    }
}

/**
 * This method is used for showing alert
 */
+ (void)showAlert:(NSString *)Title withMessage:(NSString *)Message withActions:(NSArray *)AlertActions {
    if ([UIAlertController class]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:Title message:Message preferredStyle:UIAlertControllerStyleAlert];
        for (UIAlertAction *alertAction in AlertActions) {
            [alert addAction:alertAction];
        }
        [[Utility topMostController] presentViewController:alert animated:YES completion:nil];
    }
}

+ (UIViewController*)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

/**
 * Alert message display like a toast message.
 * @param Message - Display message
 */
+ (void)toastMessage:(NSString *)Message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:Message
                                                            preferredStyle:UIAlertControllerStyleAlert];
     [[Utility topMostController] presentViewController:alert animated:YES completion:nil];
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

/**
 * Alert message display like a toast message.
 * @param Message - Display message
 * @param DurationSeconds - Display duration in seconds
 */
+ (void)toastMessage:(NSString *)Message withDuartion:(int)DurationSeconds{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:Message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                             actionWithTitle:BUTTON_OK
                             style:UIAlertActionStyleCancel
                             handler:nil];
    [alert addAction:okAction];
    [[Utility topMostController] presentViewController:alert animated:YES completion:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DurationSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
