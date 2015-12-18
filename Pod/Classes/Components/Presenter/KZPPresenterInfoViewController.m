//
//  KZPPresenterInfoViewController.m
//  Playground
//
//  Created by Krzysztof Zabłocki on 21/10/2014.
//  Copyright (c) 2014 pixle. All rights reserved.
//

#import "KZPPresenterInfoViewController.h"

@interface KZPPresenterInfoViewController ()
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, strong) NSArray *images;

@end

@implementation KZPPresenterInfoViewController

- (void)setFromImages:(NSArray *)images title:(NSString *)title
{
  self.images = images;
  self.title = title;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.titleLabel.text = self.title;
  [self reloadImages];
}

- (void)reloadImages
{
  CGFloat maxWidth = 0;
  CGFloat height = 0;
  UIImageView *previousImageView = nil;
  for (UIImage *image in self.images) {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:imageView];
    CGFloat originY = CGRectGetMaxY(previousImageView.frame);
    imageView.frame = CGRectMake(0, originY, image.size.width, image.size.height);
    previousImageView = imageView;
    
    if (maxWidth<image.size.width) {
      maxWidth = image.size.width;
    }
    height += image.size.height;
  }
  
  self.scrollView.contentSize = CGSizeMake(maxWidth, height);
}

- (CGSize)preferredContentSize
{
  //Show the first image and half of the second one
  UIImage *firstImage = [self.images firstObject];
  UIImage *secondImage = nil;
  if ([self.images count]>1) {
    secondImage = [self.images objectAtIndex:1];
  }
  
  CGFloat scrollViewWidth = self.scrollView.contentSize.width;
  CGFloat scrollViewHeight = floor(firstImage.size.height+(secondImage.size.height/2));
  CGSize labelSize = [self.titleLabel sizeThatFits:CGSizeMake(1024, CGRectGetHeight(self.titleLabel.bounds))];
  return CGSizeMake(MAX(scrollViewWidth, labelSize.width), scrollViewHeight + CGRectGetHeight(self.titleLabel.bounds));
}
@end
