//
//  Created by merowing on 22/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPPlayground.h"
#import "RSSwizzle.h"
#import "SFDynamicCodeInjection.h"

NSString *const KZPPlaygroundDidChangeImplementationNotification = @"KZPPlaygroundDidChangeImplementationNotification";

@interface NSObject (KZPOverride)
@end

@implementation NSObject (KZPOverride)
#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnresolvedMessage"
+ (void)load
{
  SEL selectorToSwizzle = @selector(performInjectionWithClass:);
  RSSwizzleInstanceMethod(SFDynamicCodeInjection.class,
    selectorToSwizzle,
    RSSWReturnType(void),
    RSSWArguments(Class aClass),
    RSSWReplacement({
      RSSWCallOriginal(aClass);
    [[NSNotificationCenter defaultCenter] postNotificationName:KZPPlaygroundDidChangeImplementationNotification object:nil];
  }), 0, NULL);

}
#pragma clang diagnostic pop

@end

@interface KZPPlayground ()
@property(nonatomic, weak, readwrite) UIView *worksheetView;
@property(nonatomic, weak, readwrite) UIViewController *viewController;
@end

@implementation KZPPlayground
@synthesize transientObjects = _transientObjects;

- (NSMutableDictionary *)transientObjects
{
  return (_transientObjects = _transientObjects ?: [NSMutableDictionary new]);
}

- (void)run
{

}

- (void)updateOnClassInjection
{

}

@end