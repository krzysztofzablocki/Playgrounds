//
//  Created by merowing on 22/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPPlayground.h"
#import "RSSwizzle.h"
#import "SFDynamicCodeInjection.h"
#import "KZPPlaygroundViewController.h"

NSString *const KZPPlaygroundDidChangeImplementationNotification = @"KZPPlaygroundDidChangeImplementationNotification";

@interface NSObject (KZPOverride)
@end

@implementation NSObject (KZPOverride)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma ide diagnostic ignored "UnresolvedMessage"
+ (void)load
{
  //! no swizzling via dyci allowed e.g. device
  SEL selectorToSwizzle = @selector(performInjectionWithClass:);
  if (![SFDynamicCodeInjection.class instancesRespondToSelector:selectorToSwizzle]) {
      return;
  }
  
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

@interface NSObject (InjectMe)
@end

@implementation NSObject (InjectMe)

+ (void)injected {
    [NSObject cancelPreviousPerformRequestsWithTarget:[NSObject class] selector:@selector(postInjection) object:nil];
    [[NSObject class] performSelector: @selector(postInjection) withObject: nil afterDelay: 0.0001];
    
}

+ (void)postInjection {
    [[NSNotificationCenter defaultCenter] postNotificationName:KZPPlaygroundDidChangeImplementationNotification object:nil];
}
@end

@interface KZPPlayground ()
@property(nonatomic, strong, readwrite) UIView *worksheetView;
@property(nonatomic, strong, readwrite) UIViewController *viewController;
@property(nonatomic, strong, readwrite) KZPPlaygroundViewController *playgroundViewController;
@end

@implementation KZPPlayground
@synthesize transientObjects = _transientObjects;

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self setup];
  }

  return self;
}

- (NSMutableDictionary *)transientObjects
{
  return (_transientObjects = _transientObjects ?: [NSMutableDictionary new]);
}

- (void)setup
{

}

- (void)run
{

}

- (void)updateOnClassInjection
{

}

- (void)updateOnResourceInjection:(NSString *)path {
    [[NSNotificationCenter defaultCenter] postNotificationName:KZPPlaygroundDidChangeImplementationNotification object:nil];
}

@end
