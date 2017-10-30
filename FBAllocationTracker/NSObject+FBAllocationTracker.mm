/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#if __has_feature(objc_arc)
#error This file must be compiled with MRR. Use -fno-objc-arc flag.
#endif

#import "NSObject+FBAllocationTracker.h"

#import "FBAllocationTrackerDefines.h"
#import "FBAllocationTrackerHelpers.h"

#if _INTERNAL_FBAT_ENABLED

#include <map>
#include <string>
using namespace std;

@implementation NSObject (FBAllocationTracker)

+ (id)fb_originalAlloc
{
  // Placeholder for original alloc
  return nil;
}

- (void)fb_originalDealloc
{
  // Placeholder for original dealloc
}

+ (id)fb_newAlloc
{
  id object = [self fb_originalAlloc];
    
    const char *clsname = object_getClassName(object);
    string className = clsname;
    size_t len = className.length();
    
    static map<string, bool> s_map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_map[string("_")] = YES;
        s_map[string("UI")] = YES;
        s_map[string("NS")] = YES;
        s_map[string("CF")] = YES;
        s_map[string("CA")] = YES;
        s_map[string("CPLRU")] = YES;
        s_map[string("CSI")] = YES;
        s_map[string("CT")] = YES;
        s_map[string("CUI")] = YES;
        s_map[string("BKS")] = YES;
        s_map[string("BS")] = YES;
        s_map[string("MC")] = YES;
        s_map[string("GEO")] = YES;
        s_map[string("GX")] = YES;
        s_map[string("WK")] = YES;
        s_map[string("AV")] = YES;
        s_map[string("AF")] = YES;
        s_map[string("BLY")] = YES;
        s_map[string("CL")] = YES;
        s_map[string("DD")] = YES;
        s_map[string("AMap")] = YES;
//        s_map[string("FB")] = YES;
    });
    
    BOOL isSystemClass = NO;
    for (NSInteger idx = 1; idx <= 5 && idx <= len; ++idx) {
        string prefix = className.substr(0, idx);
        auto found_it = s_map.find(prefix);
        if (found_it != s_map.end()) {
            isSystemClass = YES;
            break;
        }
    }
    if (isSystemClass == NO) {
        FB::AllocationTracker::incrementAllocations(object);
    }
  return object;
}

- (void)fb_newDealloc
{
  FB::AllocationTracker::incrementDeallocations(self);
  [self fb_originalDealloc];
}

@end

#endif // _INTERNAL_FBAT_ENABLED
