//
//  CCPOrientationChangeHandler.h
//  cmbsdk_flutter
//
//  Created by Zhivko Manchev on 12.7.21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMBObserversDelegate
@optional - (void)interfaceChangedOrientation:(NSNotification*) notification;
@optional - (void)scanningStateChanged:(BOOL)isScanning;
@optional - (void)appChangedActiveState:(BOOL)active;
@end

@interface CCPObservers : NSObject

@property (nonatomic, weak) id <CMBObserversDelegate> delegate;

- (void)startObservingOrientationChange;
- (void)startObservingCameraTrigger;
- (void)startObservingAppState;
- (void)stopObserving;

@end

NS_ASSUME_NONNULL_END
