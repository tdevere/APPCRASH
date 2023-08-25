//
//  CMBUtility.h
//  cmbSDK
//
//  Created by Zhivko Manchev on 2/17/21.
//  Copyright © 2021 Cognex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMBUtility : NSObject

// XML Utility
+ (NSString *)xmlStringFromData:(NSData *)xmlData prettyPrint:(BOOL)prettyPrint;

@end

NS_ASSUME_NONNULL_END
