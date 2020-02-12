#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "E2EIosTest.h"
#import "E2EPlugin.h"

FOUNDATION_EXPORT double e2eVersionNumber;
FOUNDATION_EXPORT const unsigned char e2eVersionString[];

