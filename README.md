# Playgrounds for Objective-C

[You need to watch this](https://vimeo.com/109757619)
![](/Screenshots/small_playground.gif?raw=true)

[![Version](https://img.shields.io/cocoapods/v/KZPlayground.svg?style=flat)](http://cocoadocs.org/docsets/KZPlayground)
[![License](https://img.shields.io/cocoapods/l/KZPlayground.svg?style=flat)](http://cocoadocs.org/docsets/KZPlayground)
[![Platform](https://img.shields.io/cocoapods/p/KZPlayground.svg?style=flat)](http://cocoadocs.org/docsets/KZPlayground)

Playgrounds are awesome, Apple has made amazing job with Xcode 6 and Playgrounds were the icying on the cake. 

They have multitude of use cases, eg.

- prototype custom algorithms
- design custom UI
- learn the language or explore different API

But since most of us still need to write Objective-C I give you
# Objective-C Playgrounds
Features:
- Faster than Swift playgrounds (a lot)
- Extra controls for tweaking:
- Adjustable values
- Autoanimated values
- Buttons
- IDE agnostic, once you run it, you can modify the code even from vim.
- Full iOS simulator and access to all iOS features, so you can prototype production ready code.
- Nice DSL for rapid prototyping
- CocoaPods support, so you can add it to existing projects to experiment
- Open source, anyone can contribute to make them better!

It’s just a start.

# Technical details
![](/Screenshots/playground.png?raw=true)
First, let’s establish naming:
- Timeline is a place where you have snapshots and controls.
- Worksheet is a place where you can add views / controls and have interaction with them. You can use all the stuff you’d normally use with iOS like UIGestureRecognizers etc.
- Tick counter - number of times the code changes have been loaded, multiply by the time it takes to compile + load your project and you see how much time you saved.

## DSL’s
### Timeline snapshots
`KZPShow(obj)`
- CALayer
- UIView
- UIBezierPath
- CGPathRef
- CGImageRef
- UIImage
- NSString, with format or without
- id

#### Implementing snapshoting for your custom classes
You can implement custom debug image:

```objc
- (UIImage*)kzp_debugImage;
```

If you have already implemented `- (id)debugQuickLookObject` that returns any of types supported by the KZPShow, you don’t need to do anything.

### Controls
- Button

```objc
KZPAction(@"Press me", ^{
// Magic code
})
```

- Adjusters
`KZPAdjustValue(scale, 0.5f, 1.0f)` - for floats
`KZPAdjustValue(position, 0, 100)`- for integers
- Also available as block callbacks `KZPAdjust`

### Animations
- Block animation callback, wrap the changes you want to be dynamic in them. 
```objc
KZPAnimate(CGFloat from, CGFloat to, void (^block)(CGFloat));
KZPAnimate(void (^block)());
```

- Auto-animated values, defines new variable and automatically animates them. AR -\> AutoReverse

```objc
KZPAnimateValue(rotation, 0, 360)
KZPAnimateValueAR(scale, 0, 1)
```

# Instalation and setup
KZPlayground is distributed as a [CocoaPod](http://cocoapods.org):
`pod KZPlayground`
so you can either add it to your existing project or clone this repository and play with it. 

> Remember to not add playgrounds in production builds (easy with new cocoapods configuartion scoping).

Once you have pod installed, you need to create your playground, it’s simple:
1. Subclass KZPPlayground
2. Implement run method
3. Conform to KZPActivePlayground protocol
- You can have many playgrounds in one project, but only one should be marked as KZPActivePlayground. It will be automatically loaded.
4. present `[KZPPlaygroundViewController playgroundViewController]`

To apply your changes you have 2 approaches:
- Xcode/Appcode you can use cmd/ctrl + x (done via dyci plugin) while you are modifing your playground to re-run your code.
- Continous on file save (IDE agnostic), just launch kicker gem in terminal: 

```bash
kicker -l 0.016 -e "/usr/bin/python ~/.dyci/scripts/dyci-recompile.py PATH_TO_YOUR_PLAYGROUND_IMPLEMENTATION" PATH_TO_YOUR_PLAYGROUND_IMPLEMENTATION`
```

### Only once
KZPlayground is powered by [Dyci](https://github.com/DyCI/dyci-main/) code injection tool, you only need to install it once on your machine (You’ll need to reinstall it on Xcode updates):

```bash
git clone https://github.com/DyCI/dyci-main.git
cd dyci-main/Install/
./install.sh
```

## Roadmap & Contributing

- Integrate graph displays.
- Resizable timeline/worksheet splitter.
- Nicer visualisations for Arrays && Dictionaries.

Pull-requests and ideas for features are welcomed and encouraged.

It took me around 12h to get from idea to release so the code is likely to change before 1.0 release.

If you'd like to get specific features [I'm available for iOS consulting](http://www.merowing.info/about/).

## License

KZPlayground is available under the modified MIT license. See the LICENSE file for more info.

## Author

Krzysztof Zablocki, krzysztof.zablocki@pixle.pl

[Follow me on twitter.](http://twitter.com/merowing_)

[Check-out my blog](http://merowing.info) or [GitHub profile](https://github.com/krzysztofzablocki) for more cool stuff.

#### Attribution

SceneKit example code has been taken from [David Ronnqvist](http://ronnqvi.st/book/) upcoming SceneKit book, recommended.