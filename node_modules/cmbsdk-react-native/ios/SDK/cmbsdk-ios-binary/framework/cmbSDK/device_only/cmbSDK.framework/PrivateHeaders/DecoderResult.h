//
//  DecoderResult.h
//  cmbSDK
//
//  Created by Zhivko Manchev on 1/5/21.
//  Copyright © 2021 Cognex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface DecoderResult : NSObject

@property (nonatomic, assign) NSTimeInterval decodeTime;
@property (nonatomic, retain) NSArray<MWResult *>*mwResults;

- (instancetype)initWithResults:(NSArray<MWResult *>*)results decodeTime:(NSTimeInterval) decodeTime;

@end

NS_ASSUME_NONNULL_END
