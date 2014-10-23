//
//  Created by merowing on 22/10/14.
//
//
//


#import "KZPPlayground.h"

NSString *const KZPPlaygroundDidChangeImplementationNotification = @"KZPPlaygroundDidChangeImplementationNotification";
@interface KZPPlayground ()
@property(nonatomic, weak, readwrite) UIView *worksheetView;
@property(nonatomic, weak, readwrite) UIViewController *viewController;
@end

@implementation KZPPlayground

- (void)run
{

}

- (void)updateOnClassInjection
{
  [[NSNotificationCenter defaultCenter] postNotificationName:KZPPlaygroundDidChangeImplementationNotification object:self];
}
@end