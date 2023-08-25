//
//  CCPUtilities.h
//  cmbsdk_flutter
//
//  Created by Zhivko Manchev on 12.7.21.
//

#import <Foundation/Foundation.h>
#import <cmbSDK/cmbSDK.h>
#import "CCPCompletions.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPUtilities : NSObject

+ (NSString *)getResultsJSONStringFromResults:(CMBReadResults *)readResults keyResults:(NSString *)keyResults keySubResults:(NSString *)keySubResults;
+ (NSDictionary*) getDictionaryFromResult:(CMBReadResult*) readResult;

+ (void)checkCameraPermission:(CCPCompletionWithStatusAndIntValue)completion;
+ (void)requestCameraPermission:(CCPCompletionWithStatusAndIntValue)completion;

+ (UIImage * _Nullable)getImageFromSVGString:(NSString *)svg;

+ (UIInterfaceOrientation)currentInterfaceOrientation;
+ (NSString *)jsonStringFromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
