//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


@import Foundation;
@import UIKit;

//! only generates rounded values
extern void __attribute__((overloadable)) KZPAdjust(NSString *name, int from, int to, void (^block)(int));

extern void __attribute__((overloadable)) KZPAdjust(NSString *name, float from, float to, void (^block)(float));

#define KZPAdjustValue(name, from, to) __block typeof(from) name = from; KZPAdjust(@#name, from, to, ^(typeof(from) value) { name = value; })

@interface KZPValueAdjustComponent : NSObject
+ (void)addValueAdjustWithName:(NSString *)name fromValue:(CGFloat)from toValue:(CGFloat)to withBlock:(CGFloat (^)(CGFloat))block;
@end