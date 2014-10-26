//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 21/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPImagePickerComponent.h"
#import "KZPTimelineViewController.h"
#import "KZPPresenterComponent.h"

void __attribute__((overloadable)) KZPAdjust(NSString *name, void (^block)(UIImage *)) {
  [KZPImagePickerComponent addImagePickerWithName:name block:block];
}

static const void *kAdjusterLifetimeKey = &kAdjusterLifetimeKey;

@interface KZPImagePickerComponent () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, weak) KZPPresenterComponent *presenterComponent;
@property(nonatomic, copy) void (^changeBlock)(UIImage *);
@end

@implementation KZPImagePickerComponent
+ (void)addImagePickerWithName:(NSString *)name block:(void (^)(UIImage *))block
{
  [[KZPImagePickerComponent alloc] initWithName:name block:block];
}

- (id)initWithName:(NSString *)name block:(void (^)(UIImage *))block
{
  self = [super init];
  if (!self) {
    return nil;
  }

  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];

  KZPPresenterComponent *presenterComponent = [[KZPPresenterComponent alloc] initWithImage:nil type:@"UIImage"];
  presenterComponent.frame = CGRectMake(0, 0, timelineViewController.maxWidthForSnapshotView, timelineViewController.maxWidthForSnapshotView);
  presenterComponent.backgroundColor = UIColor.blackColor;

  UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
  [button sizeToFit];
  button.center = presenterComponent.center;
  [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
  [presenterComponent addSubview:button];

  [timelineViewController addView:presenterComponent];
  self.presenterComponent = presenterComponent;
  self.changeBlock = block;
  objc_setAssociatedObject(presenterComponent, kAdjusterLifetimeKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  return self;
}

- (void)buttonPressed:(UIButton *)button
{
  [self showPickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showPickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
  UIImagePickerController *controller = [UIImagePickerController new];
  controller.modalPresentationStyle = UIModalPresentationCurrentContext;
  controller.sourceType = sourceType;
  controller.delegate = self;

  KZPTimelineViewController *timelineViewController = [KZPTimelineViewController sharedInstance];
  [timelineViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  self.presenterComponent.image = image;
  [picker dismissViewControllerAnimated:YES completion:nil];
  self.changeBlock(image);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:nil];
}


+ (void)reset
{

}

@end