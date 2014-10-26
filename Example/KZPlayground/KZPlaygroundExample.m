//
//  KZPlaygroundExample.m
//
//  Created by Krzysztof Zabłocki on 19/10/2014.
//  Copyright (c) 2014 pixle. All rights reserved.
//

#import "KZPlaygroundExample.h"
#import "KZPPlayground+Internal.h"

@import SceneKit;

@implementation KZPlaygroundExample
- (void)setup
{
  KZPShow(@"Setup snapshot");
}

- (void)run
{
  [self backgroundImagePickingExample];
  [self samplePlayground];
//   [self sceneKit];

}

- (void)backgroundImagePickingExample
{
  UIImageView *imageView = [UIImageView new];
  imageView.center = self.worksheetView.center;
  [self.worksheetView addSubview:imageView];

  KZPAdjustImage(myImage);
  KZPWhenChanged(myImage, (^(UIImage *img) {
    imageView.image = img;
    [imageView sizeToFit];
    imageView.center = self.worksheetView.center;
  }));
}

- (void)samplePlayground
{
  UIImage *img = [UIImage imageNamed:@"avatar.jpg"];
  KZPShow(img);

  UIImage *bigImage = [UIImage imageNamed:@"foldify"];
  KZPShow(bigImage);
  
  UILabel *label = [[UILabel alloc] init];
  label.text = NSLocalizedString(@"main.hello", nil);
  [label sizeToFit];
  KZPShow(label);

  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 128, 256)];
  view.layer.borderColor = UIColor.yellowColor.CGColor;
  view.layer.borderWidth = 2;
  view.backgroundColor = UIColor.blueColor;
  [view addSubview:({
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bigImage];
    imgView.transform = CGAffineTransformMakeRotation(M_PI_2);
    imgView.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds));
    imgView;
  })];
  view.layer.cornerRadius = 30;
  view.clipsToBounds = YES;
  KZPShow(view);

  view.center = self.worksheetView.center;
  [self.worksheetView addSubview:view];

  KZPAdjustValue(rotation, 0, 360).defaultValue(120);
  KZPAdjustValue(scale, 0.3f, 3.0f).defaultValue(1.5f);
  //KZPAnimateValueAR(scale, 0.3, 3.0f);

  UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
  [self.worksheetView addGestureRecognizer:panGestureRecognizer];
  self.transientObjects[@"pannableView"] = view;

  KZPAnimate(^{
    view.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(scale, scale), rotation * (M_PI / 180));
  });

  UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 128, 128)];
  [bezierPath setLineWidth:5];
  CGFloat pattern[] = { 9, 4, 0, 1 };
  [bezierPath setLineDash:pattern count:4 phase:2];
  KZPShow(bezierPath);
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
  UIView *view = self.transientObjects[@"pannableView"];
  view.center = [panGestureRecognizer locationInView:panGestureRecognizer.view];
}

- (void)sceneKit
{
  SCNView *sceneView = [[SCNView alloc] initWithFrame:self.worksheetView.bounds];
  [self.worksheetView addSubview:sceneView];

  // An empty scene
  SCNScene *scene = [SCNScene scene];
  sceneView.scene = scene;

// A camera
  SCNNode *cameraNode = [SCNNode node];
  cameraNode.camera = [SCNCamera camera];

  KZPAdjustValue(xPosition, 0, 20);
  KZPAdjustValue(yPosition, -5, 10);
  KZPAdjustValue(zPosition, 30, 60);

  KZPAnimate(^{
    cameraNode.transform = SCNMatrix4Rotate(SCNMatrix4MakeTranslation(xPosition, yPosition, zPosition),
      -M_PI / 7.0,
      1, 0, 0);
  });

  [scene.rootNode addChildNode:cameraNode];

// A spotlight
  SCNLight *spotLight = [SCNLight light];
  spotLight.type = SCNLightTypeSpot;
  spotLight.color = [UIColor redColor];
  SCNNode *spotLightNode = [SCNNode node];
  spotLightNode.light = spotLight;
  spotLightNode.position = SCNVector3Make(-2, 1, 0);

  [cameraNode addChildNode:spotLightNode];

// A square box
  CGFloat boxSide = 2.0;
  SCNBox *box = [SCNBox boxWithWidth:boxSide
                        height:boxSide
                        length:boxSide
                        chamferRadius:0];
  SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
  boxNode.transform = SCNMatrix4MakeRotation(M_PI_2 / 3, 0, 1, 0);
  [scene.rootNode addChildNode:boxNode];


  KZPAnimateValueAR(yRotation, 0, 120);
  KZPAnimate(^{
    boxNode.transform = SCNMatrix4MakeRotation(yRotation * (M_PI / 180), 0, 1, 0);
  });

  KZPAction(@"Toggle Visibility", ^{
    boxNode.hidden = !boxNode.hidden;
  });
}
@end
