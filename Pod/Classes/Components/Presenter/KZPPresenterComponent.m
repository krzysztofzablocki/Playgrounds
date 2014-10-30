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

  NSString *message = [[NSString alloc] initWithFormat:format arguments:*args];

  UILabel *label = [[UILabel alloc] init];
  label.text = message;
  label.numberOfLines = 0;
  label.textColor = [UIColor blackColor];
  CGSize size = [label sizeThatFits:CGSizeMake([KZPTimelineViewController sharedInstance].maxWidthForSnapshotView, CGFLOAT_MAX)];
  label.frame = CGRectMake(0, 0, size.width, size.height);

  return KZPShowInternal((UIView*)label);
}

UIImage* __attribute__((overloadable)) KZPShowInternal(NSArray *array) {
//    KZPShowRegisterType(@"NSArray");
//    
//    //Render max the first 100 limit
//    NSInteger limit = MAX (100, [array count]);
//    
//    //Create a matrix of previews
//    CGFloat previewSize = 256;
//    NSInteger matrixHorizontalSize = 5;
//    NSInteger numberOfRow = floor(limit/matrixHorizontalSize);
//    CGFloat width = previewSize * matrixHorizontalSize;
//    CGFloat height = width*numberOfRow;
//    
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0);
//    
//    NSUInteger counter = 0;
//    for (id obj in array) {
//        if (counter>limit) {
//            break;
//        }
//        
//        UIImage *
//        
//        counter ++;
//    }
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    KZPShow(image);
//    
//    KZPShowRegisterType(nil);
  return nil;
}

UIImage* __attribute__((overloadable)) KZPShowInternal(id obj) {
  return KZPShowInternal([NSString stringWithFormat:@"%@ : %@", NSStringFromClass([obj class]), [obj description]]);
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
  } else {
      showObj = obj;
  }
  
  UIImage *image = nil;
  if ([showObj isKindOfClass:[CALayer class]]) {
    image = KZPShowInternal((CALayer*)showObj);
  } else if ([showObj isKindOfClass:[UIView class]]){
    image = KZPShowInternal((UIView*)showObj);
  } else if ([showObj isKindOfClass:[UIBezierPath class]]){
    image = KZPShowInternal((UIBezierPath*)showObj);
  } else if ([showObj isKindOfClass:[UIImage class]]){
    image = KZPShowInternal((UIImage*)showObj);
  } else if ([showObj isKindOfClass:[NSString class]]){
    va_list(args);
    va_start(args, obj);
    image = KZPShowInternal((NSString*)showObj, &args);
    va_end(args);
  }else if ([showObj isKindOfClass:[NSArray class]]){
    image = KZPShowInternal((NSArray*)showObj);
  } else {
    image = KZPShowInternal([NSString stringWithFormat:@"%@ : %@", NSStringFromClass([obj class]), [obj description]]);
  }
  
  KZPPresenterComponent *presenter = [[KZPPresenterComponent alloc] initWithImage:image type:KZPShowType];
  if (!presenter) {
    KZPShow(@"Error: Unable to present image with size %@", NSStringFromCGSize(image.size));
    return;
  }
  [[KZPTimelineViewController sharedInstance] addView:presenter];
}

@interface KZPPresenterComponent () <KZPSnapshotView>
@property(nonatomic, weak) UIImageView *imageView;
@property(nonatomic, copy) NSString *type;
@end

@implementation KZPPresenterComponent
- (instancetype)initWithImage:(UIImage *)image type:(NSString *)type
{
  self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
  if (!self) {
    return nil;
  }

  _image = image;
  _type = [type copy];
  [self setup];
  return self;
}

- (void)setup
{
  UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
  imageView.contentMode = UIViewContentModeScaleAspectFit;
  imageView.frame = self.bounds;
  imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self addSubview:imageView];
  self.imageView = imageView;
}

- (BOOL)hasExtraInformation
{
  return YES;
}

- (void)setImage:(UIImage *)image
{
  _image = image;
  self.imageView.image = image;
}


- (UIViewController *)extraInfoController
{
  KZPPresenterInfoViewController *presenterInfoViewController = [KZPPresenterInfoViewController new];
  NSString *title = [NSString stringWithFormat:@"%@ %.0f x %.0f", self.type, self.image.size.width, self.image.size.height];
  [presenterInfoViewController setFromImage:self.image title:title];
  return presenterInfoViewController;
}

+ (void)reset
{

}

@end