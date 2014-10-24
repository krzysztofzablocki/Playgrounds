//
//  Created by Krzysztof Zabłocki(http://twitter.com/merowing_) on 19/10/14.
//
//
//


#import <objc/runtime.h>
#import "KZPPlaygroundViewController.h"
#import "KZPTimelineViewController.h"
#import "KZPPlayground+Internal.h"

@interface KZPPlaygroundViewController ()
@property(weak, nonatomic) IBOutlet UIView *timelineContainerView;
@property(weak, nonatomic) IBOutlet UIView *worksheetContainerView;
@property(strong, nonatomic) KZPPlayground *currentPlayground;
@end

@implementation KZPPlaygroundViewController

+ (KZPPlaygroundViewController*)playgroundViewController
{
  return [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle bundleForClass:self]] instantiateInitialViewController];
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:KZPPlaygroundDidChangeImplementationNotification object:nil];
}

- (void)awakeFromNib
{
  [super awakeFromNib];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playgroundImplementationChanged) name:KZPPlaygroundDidChangeImplementationNotification object:nil];

  NSArray *playgrounds = [self findClassesConformingToProtocol:@protocol(KZPActivePlayground)];
  NSAssert(playgrounds.count == 1, @"One KZPPlayground subclass needs to conform to KZPActivePlayground, it will be the active playground for the current run.");
  KZPPlayground *playground = (KZPPlayground *)[playgrounds.firstObject new];
  NSAssert([playground isKindOfClass:KZPPlayground.class], @"Class conforming to KZPActivePlayground has to be a subclass of KZPPlayground.");

  self.currentPlayground = playground;
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self executePlayground];
}

- (void)reset
{
  self.currentPlayground.worksheetView = [self cleanWorksheet];
  self.currentPlayground.viewController = self;
  [self dismissViewControllerAnimated:NO completion:nil];

  [self.timelineViewController reset];
  [[self findClassesConformingToProtocol:@protocol(KZPComponent)] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj reset];
  }];
}

- (UIView *)cleanWorksheet
{
  [self.worksheetContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  UIView *worksheetView = [[UIView alloc] initWithFrame:self.worksheetContainerView.bounds];
  worksheetView.clipsToBounds = YES;
  worksheetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  worksheetView.backgroundColor = UIColor.lightGrayColor;
  [self.worksheetContainerView addSubview:worksheetView];
  return worksheetView;
}

- (void)executePlayground
{
  [self reset];
  [self.currentPlayground run];
  [self playgroundDidRun];
}

- (void)playgroundDidRun
{
  [self.timelineViewController playgroundDidRun];
}

- (void)playgroundImplementationChanged
{
  [self executePlayground];
}

#pragma mark - Helpers

- (NSArray *)findClassesConformingToProtocol:(Protocol *)protocol
{
  int numberOfClasses = objc_getClassList(NULL, 0);
  Class *classes;

  classes = (Class *)malloc(sizeof(Class) * numberOfClasses);
  objc_getClassList(classes, numberOfClasses);

  NSMutableArray *conformingClasses = [NSMutableArray array];
  for (NSInteger i = 0; i < numberOfClasses; i++) {
    Class lClass = classes[i];
    if (class_conformsToProtocol(lClass, protocol)) {
      [conformingClasses addObject:classes[i]];
    }
  }

  free(classes);
  return [conformingClasses copy];
}

- (KZPTimelineViewController *)timelineViewController
{
  return [self controllerOfClass:KZPTimelineViewController.class];
}

- (id)controllerOfClass:(Class)aClass
{
  for (UIViewController *controller in self.childViewControllers) {
    if ([controller isKindOfClass:aClass]) {
      return controller;
    }
  }

  return nil;
}
@end
