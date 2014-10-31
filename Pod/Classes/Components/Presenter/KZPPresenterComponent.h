//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//


@import Foundation;
@import UIKit;
@import QuartzCore;

#import "KZPComponent.h"

extern UIImage* __attribute__((overloadable)) KZPShowInternal(CALayer *layer);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(UIView *view);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(UIBezierPath *path);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(CGPathRef path);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(CGImageRef image);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(UIImage *image);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(NSString *format, va_list args);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(NSArray *array);

extern UIImage* __attribute__((overloadable)) KZPShowInternal(id obj);

extern void KZPShow(id obj, ...);

@protocol KZPPresenterDebugProtocol <NSObject>
//! preffered
- (UIImage *)kzp_debugImage;

//! will use if object provides any of [CALayer, UIView, UIBezierPath, UIImage, NSString]
@optional
- (id)debugQuickLookObject;
@end

@interface KZPPresenterComponent : UIView <KZPComponent>

@property(nonatomic, strong) id component;

- (instancetype)initWithComponent:(id)component;

@end