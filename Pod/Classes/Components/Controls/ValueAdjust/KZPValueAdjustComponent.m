//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


#import "KZPValueAdjustComponent.h"
#import "KZPTimelineViewController.h"

@import ObjectiveC.runtime;

#import <objc/runtime.h>

static const void *kSliderBlockKey = &kSliderBlockKey;
static const void *kLastValuesKey = &kLastValuesKey;

extern void __attribute__((overloadable)) KZPAdjust(NSString *name, int from, int to, void (^block)(int)) {
  [KZPValueAdjustComponent addValueAdjustWithName:name fromValue:from toValue:to withBlock:^(CGFloat d) {
    int rounded = (int)roundf(d);
    block(rounded);
    return (CGFloat)rounded;
  }];
}

extern void __attribute__((overloadable)) KZPAdjust(NSString *name, float from, float to, void (^block)(float)) {
  [KZPValueAdjustComponent addValueAdjustWithName:name fromValue:(CGFloat)from toValue:(CGFloat)to withBlock:^CGFloat(CGFloat d) {
    block((float)d);
    return d;
  }];
}


@interface KZPValueAdjustComponent ()
@end

@implementation KZPValueAdjustComponent
+ (void)addValueAdjustWithName:(NSString *)name fromValue:(CGFloat)from toValue:(CGFloat)to withBlock:(CGFloat (^)(CGFloat))block
{
  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];

  UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, timelineViewController.maxWidthForSnapshotView, 44)];
  slider.minimumValue = from;
  slider.maximumValue = to;
  [slider sizeToFit];

  UILabel *nameLabel = [UILabel new];
  nameLabel.textColor = [UIColor blackColor];
  nameLabel.text = [NSString stringWithFormat:@"%@ %.2f", name, to];
  nameLabel.textAlignment = NSTextAlignmentCenter;
  [nameLabel sizeToFit];

  __weak typeof(self) weakSelf = self;
  void (^sliderBlock)(CGFloat) = ^(CGFloat value) {
    CGFloat adjustedValue = block(value);
    nameLabel.text = [NSString stringWithFormat:@"%@ %.2f", name, adjustedValue];
    weakSelf.lastValues[name] = @(adjustedValue);
  };

  objc_setAssociatedObject(slider, kSliderBlockKey, sliderBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
  [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];

  [timelineViewController addView:nameLabel];
  [timelineViewController addView:slider];

  NSNumber *previousValue = weakSelf.lastValues[name];
  float value = previousValue ? previousValue.floatValue : from;
  [slider setValue:value];
  sliderBlock(value);
}

+ (void)sliderChanged:(UISlider *)sliderChanged
{
  void(^block)(CGFloat) = objc_getAssociatedObject(sliderChanged, kSliderBlockKey);
  block(sliderChanged.value);
}

+ (NSMutableDictionary *)lastValues
{
  NSMutableDictionary *lastValues = objc_getAssociatedObject(self, kLastValuesKey);
  if (!lastValues) {
    lastValues = [NSMutableDictionary new];
    objc_setAssociatedObject(self, kLastValuesKey, lastValues, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return lastValues;
}

+ (void)reset
{
}

@end