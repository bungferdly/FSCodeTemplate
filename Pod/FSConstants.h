//
//  FSConstants.h
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#ifndef FSConstants_h
#define FSConstants_h

#ifdef DEBUG
#define FSLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
#define FSLog(...) ((void)0)
#endif

#define FSOSVersion [[UIDevice currentDevice].systemVersion floatValue]
#define FSKindOf(obj, cls) ((cls *)([obj isKindOfClass:[cls class]] ? obj : nil))
#define FSArrayKindOf(obj, cls) ((NSArray *)(FSKindOf(FSKindOf(obj, NSArray).firstObject, cls) ? obj : nil))

#endif
