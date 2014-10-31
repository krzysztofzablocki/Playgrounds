//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 20/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPPresenterComponent.h"
#import "KZPTimelineViewController.h"
#import "KZPSnapshotView.h"
#import "KZPPresenterInfoViewController.h"

UIImage* __attribute__((overloadable)) KZPShowInternal(CALayer *layer);

UIImage* __attribute__((overloadable)) KZPShowInternal(UIView *view);

UIImage* __attribute__((overloadable)) KZPShowInternal(UIBezierPath *path);

UIImage* __attribute__((overloadable)) KZPShowInternal(CGPathRef path);

UIImage* __attribute__((overloadable)) KZPShowInternal(CGImageRef image);

UIImage* __attribute__((overloadable)) KZPShowInternal(UIImage *image);

UIImage* __attribute__((overloadable)) KZPShowInternal(NSString *format, va_list args);

UIImage* __attribute__((overloadable)) KZPShowInternal(NSArray *array);

UIImage* __attribute__((overloadable)) KZPShowInternal(id obj, va_list *args);

UIImage* __attribute__((overloadable)) KZPShowInternal(id obj);

static NSString *KZPShowType = nil;

void KZPShowRegisterType(NSString *format, ...) {
  if (format == nil) {
    KZPShowType = nil;
    return;
  }

  if (KZPShowType) {
    return;
  }
  
  va_list (args);
  va_start(args, format);
  KZPShowType = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
}

void KZPShowRegisterClass(id instance, Class baseClass) {
  if (![instance isMemberOfClass: baseClass]) {
    KZPShowRegisterType(@"%@:%@", NSStringFromClass([instance class]), NSStringFromClass(baseClass));
    return;
  }

  KZPShowRegisterType(NSStringFromClass(baseClass));
}

UIImage* __attribute__((overloadable)) KZPShowInternal(CALayer *layer) {
  KZPShowRegisterClass(layer, CALayer.class);

  UIGraphicsBeginImageContextWithOptions(layer.bounds.size, NO, 0);
  [layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return copied;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(UIView *view) {
  KZPShowRegisterClass(view, UIView.class);

  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return image;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(CGPathRef path) {
  KZPShowRegisterType(@"CGPathRef");

  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:path];
  [bezierPath setLineWidth:3];
  [bezierPath setLineJoinStyle:kCGLineJoinBevel];
  return KZPShowInternal(bezierPath);
}


UIImage* __attribute__((overloadable)) KZPShowInternal(UIBezierPath *path) {
  KZPShowRegisterType(@"UIBezierPath");

  CGRect rect = CGRectMake(0, 0, CGRectGetWidth(path.bounds) + path.lineWidth, CGRectGetHeight(path.bounds) + path.lineWidth);
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIGraphicsPushContext(context);
  UIGraphicsBeginImageContext(rect.size);
  UIBezierPath *copiedPath = path.copy;
  [copiedPath applyTransform:CGAffineTransformMakeTranslation(path.lineWidth * 0.5, path.lineWidth * 0.5)];
  [copiedPath stroke];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsPopContext();
  UIGraphicsEndImageContext();

  return image;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(CGImageRef image) {
  KZPShowRegisterType(@"CGImageRef");

  return [UIImage imageWithCGImage:image];
}

UIImage* __attribute__((overloadable)) KZPShowInternal(UIImage *image) {
  KZPShowRegisterType(@"UIImage");

  return image;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(NSString *format, va_list *args) {
  KZPShowRegisterType(@"NSString");

  NSString *message = nil;
  if (args) {
    message = [[NSString alloc] initWithFormat:format arguments:*args];
  } else {
    message = format;
  }

  UILabel *label = [[UILabel alloc] init];
  label.text = message;
  label.numberOfLines = 0;
  label.textColor = [UIColor blackColor];
  CGSize size = [label sizeThatFits:CGSizeMake([KZPTimelineViewController sharedInstance].maxWidthForSnapshotView, CGFLOAT_MAX)];
  label.frame = CGRectMake(0, 0, size.width, size.height);

  return KZPShowInternal((UIView*)label);
}

UIImage* __attribute__((overloadable)) KZPShowInternal(NSArray *array) {
  KZPShowRegisterType(@"NSArray");
  
  //Render max the first 100 limit
  NSInteger limit = MIN (100, [array count]);
  
  //Create a matrix of previews
  NSInteger matrixHorizontalSize = 3;
  CGFloat previewSize = [KZPTimelineViewController sharedInstance].maxWidthForSnapshotView/matrixHorizontalSize;
  NSInteger numberOfRow = ceilf(limit/(float)matrixHorizontalSize);
  CGFloat matrixWidth = previewSize * matrixHorizontalSize;
  CGFloat matrixHeight = round((matrixWidth/3)*numberOfRow);
  
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(matrixWidth, matrixHeight), NO, 0);
  
  NSUInteger counter = 0;
  for (id obj in array) {
    if (counter>limit) {
      break;
    }
    UIImage *image = KZPShowInternal(obj);
    
    CGFloat y = (floor(counter/matrixHorizontalSize)*previewSize);
    CGFloat x = (counter%matrixHorizontalSize)*previewSize;
    CGFloat height = image.size.height;
    CGFloat width = image.size.width;
    CGFloat maxSide = MAX(width, height);
    CGFloat aspectAdjustment = previewSize / maxSide;
    height *= aspectAdjustment;
    width *= aspectAdjustment;
    CGFloat originTranslationX = (previewSize-width)/2;
    CGFloat originTranslationY = (previewSize-height)/2;
    [image drawInRect:CGRectMake(originTranslationX+x, originTranslationY+y, width, height)];
    
    counter ++;
  }
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  KZPShowRegisterType(nil);
  return image;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(id obj, va_list *args) {
  
  UIImage *image = nil;
  if ([obj isKindOfClass:[CALayer class]]) {
    image = KZPShowInternal((CALayer*)obj);
  } else if ([obj isKindOfClass:[UIView class]]){
    image = KZPShowInternal((UIView*)obj);
  } else if ([obj isKindOfClass:[UIBezierPath class]]){
    image = KZPShowInternal((UIBezierPath*)obj);
  } else if ([obj isKindOfClass:[UIImage class]]){
    image = KZPShowInternal((UIImage*)obj);
  } else if ([obj isKindOfClass:[NSString class]]){
    image = KZPShowInternal((NSString*)obj, args);
  } else if ([obj isKindOfClass:[NSArray class]]){
    image = KZPShowInternal((NSArray*)obj);
  } else {
    image = KZPShowInternal([NSString stringWithFormat:@"%@",[obj description]]);
  }
  return image;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(id obj)
{
  return KZPShowInternal(obj, nil);
}

extern void KZPShow(id obj, ...) {
  if ([obj respondsToSelector:@selector(kzp_debugImage)]) {
    UIImage *image = [obj performSelector:@selector(kzp_debugImage)];
    KZPShow(image);
    return;
  }

  id showObj = nil;
  if ([obj respondsToSelector:@selector(debugQuickLookObject)]) {
      showObj = [obj debugQuickLookObject];
  } else if ([obj isKindOfClass:[NSString class]]){
    va_list(args);
    va_start(args, obj);
    showObj = [[NSString alloc] initWithFormat:obj arguments:args];
    va_end(args);
  } else {
    showObj = obj;
  }
  
  KZPPresenterComponent *presenter = [[KZPPresenterComponent alloc] initWithComponent:showObj];
  if (!presenter) {
    KZPShow(@"Error: Unable to present image with size %@", NSStringFromCGSize(presenter.frame.size));
    return;
  }
  [[KZPTimelineViewController sharedInstance] addView:presenter];
}

@interface KZPPresenterComponent () <KZPSnapshotView>
@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, copy) NSString *type;
@end

@implementation KZPPresenterComponent

- (instancetype)initWithComponent:(id)component;
{
  self = [super initWithFrame:CGRectZero];
  if (!self) {
    return nil;
  }

  self.component = component;
  
  [self setup];
  
  return self;
}

- (void)setup
{
  UIImage *image = KZPShowInternal(_component);
  
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = self.bounds;
  imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self addSubview:imageView];
  self.imageView = imageView;
  self.frame = CGRectMake(0, 0, image.size.width, image.size.height);
}

- (void)setComponent:(id)component
{
  _component = component;
  
  UIImage *image = KZPShowInternal(_component);
  self.imageView.image = image;
  self.type = NSStringFromClass([_component class]);
}

- (BOOL)hasExtraInformation
{
  return YES;
}


- (UIViewController *)extraInfoController
{
  KZPPresenterInfoViewController *presenterInfoViewController = [KZPPresenterInfoViewController new];
  NSString *title = [NSString stringWithFormat:@"%@ %.0f x %.0f", self.type, self.imageView.image.size.width, self.imageView.image.size.height];
  [presenterInfoViewController setFromImage:self.imageView.image title:title];
  return presenterInfoViewController;
}

+ (void)reset
{

}

@end
