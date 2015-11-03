/*
    Generated for Injection of class implementations
*/

#define INJECTION_NOIMPL
#define INJECTION_BUNDLE InjectionBundle9

#define INJECTION_ENABLED
#import "/tmp/injectionforxcode/BundleInjection.h"

#undef _instatic
#define _instatic extern

#undef _inglobal
#define _inglobal extern

#undef _inval
#define _inval( _val... ) /* = _val */

#import "BundleContents.h"

extern
#if __cplusplus
"C" {
#endif
    int injectionHook(void);
#if __cplusplus
};
#endif

@interface InjectionBundle9 : NSObject
@end
@implementation InjectionBundle9

+ (void)load {
    Class bundleInjection = NSClassFromString(@"BundleInjection");
    [bundleInjection autoLoadedNotify:0 hook:(void *)injectionHook];
}

@end

int injectionHook() {
    NSLog( @"injectionHook():" );
    [InjectionBundle9 load];
    return YES;
}



