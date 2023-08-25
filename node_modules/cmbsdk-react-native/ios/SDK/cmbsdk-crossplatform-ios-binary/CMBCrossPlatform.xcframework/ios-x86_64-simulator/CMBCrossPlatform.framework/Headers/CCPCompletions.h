//
//  CCPCompletions.h
//  CognexCrossPlatform
//
//  Created by Zhivko Manchev on 15.7.21.
//

#ifndef CCPCompletions_h
#define CCPCompletions_h

typedef void (^CCPCompletion)(void);
typedef void (^CCPCompletionWithResponse)(NSString *errorCode, NSString* response);
typedef void (^CCPCompletionWithStatusAndIntValue)(BOOL status, int value);

#endif /* CCPCompletions_h */
