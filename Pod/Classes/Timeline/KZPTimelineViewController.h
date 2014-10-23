//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 19/10/14.
//
//
//


@import Foundation;
@import UIKit;

#import "KZPPlaygroundViewController.h"

@interface KZPTimelineViewController : UIViewController
+ (KZPTimelineViewController *)sharedInstance;

- (void)playgroundDidRun;

- (CGFloat)maxWidthForSnapshotView;

- (void)reset;

- (void)addView:(UIView *)view;
@end