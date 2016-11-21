import Foundation
import KZPlayground

class KZPPlaygroundExample : KZPPlayground, KZPActivePlayground, UIScrollViewDelegate
{
    var headerShapeLayer: CAShapeLayer!
    var headerLabel: UILabel!
    var isCollapsed = false
    var headerLineLengthNormalized: CGFloat = 0
    
    override func run() {
        let viewport = prepareiPhoneViewport()
        viewport.center = self.worksheetView.center
        self.worksheetView.addSubview(viewport)
        
        let header = prepareHeader()
        header.center = CGPoint(x: header.bounds.size.width * 0.5, y: header.bounds.size.height * 0.5)
        viewport.addSubview(header)
        
        animateToOpen(shape: headerShapeLayer, duration: 0.25)
    }
    
    func prepareHeader() -> UIView {
        let shape = CAShapeLayer()
        let (shapePath, pathSize, headerLineLengthNormalized, circleCenter) = fullPath()
        self.headerLineLengthNormalized = headerLineLengthNormalized
        shape.path = shapePath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        shape.strokeEnd = headerLineLengthNormalized
        let header = UIView(frame: CGRect(x: 0, y: 0, width: pathSize.width, height: pathSize.height))
        shape.position = CGPoint(x: (viewportWidth() - header.bounds.size.width) / 2, y: 20 + header.bounds.size.height)
        header.layer.addSublayer(shape)
        
        //! add fake hamburger button
        let buttonShape = prepareButton()
        buttonShape.position = CGPoint(x: shape.position.x + circleCenter.x, y: shape.position.y + circleCenter.y)
        header.layer.addSublayer(buttonShape)
        
        headerLabel = UILabel()
        headerLabel.text = "merowing.info"
        headerLabel.textColor = UIColor.white
        headerLabel.sizeToFit()
        headerLabel.center = CGPoint(x: shape.position.x + 70, y: shape.position.y - 20)
        header.addSubview(headerLabel)
        
        headerShapeLayer = shape
        return header
    }

    func prepareiPhoneViewport() -> UIView {
        let viewport = UIView(frame: CGRect(x: 0, y: 0, width: viewportWidth(), height: 568))
        
        let scrollView = prepareScrollView()
        scrollView.frame = viewport.bounds
        viewport.addSubview(scrollView)
        
        let statusBar = UIImage(named: "statusBar")!
        let statusBarImageView = UIImageView(image: statusBar)
        statusBarImageView.center = CGPoint(x: statusBar.size.width * 0.5, y: statusBar.size.height * 0.5)
        viewport.addSubview(statusBarImageView)

        return viewport
    }

    func prepareScrollView() -> UIScrollView {
        let content = UIImage(named: "content")!
        
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: content.size.width, height: 568))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentSize = CGSize(width: 0, height: content.size.height)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor(red:0.32, green:0.44, blue:0.54, alpha:1.0)
        
        let contentImageView = UIImageView(image: content)
        contentImageView.backgroundColor = scrollView.backgroundColor
        scrollView.addSubview(contentImageView)
        return scrollView
    }

    func prepareButton() -> CAShapeLayer {
        let buttonShape = CAShapeLayer()
        let path = buttonPath()
        buttonShape.path = path.cgPath
        buttonShape.fillColor = UIColor.clear.cgColor
        buttonShape.strokeColor = UIColor.white.cgColor
        buttonShape.bounds = path.bounds
        return buttonShape
    }
    
    func fullPath() -> (CGPath, CGSize, CGFloat, CGPoint) {
        let path = UIBezierPath()
        let radius: CGFloat = 20
        let inset: CGFloat = 30
        let lineLength = viewportWidth() - inset
        let lineStart = (viewportWidth() - (lineLength - radius)) / 2
        path.move(to: CGPoint(x: lineStart, y: 0))
        path.addLine(to: CGPoint(x: lineLength, y: 0))

        let circleLength = 2.0 * CGFloat(M_PI) * radius
        let totalLength = circleLength + lineLength - lineStart
        let lineLengthNormalized = (lineLength - lineStart) / totalLength
        
        let circleCenter = CGPoint(x:lineLength, y: -radius)
        
        var nextPoint = CGPoint.zero
        
        let _ = (0..<360).map {
            nextPoint = CGPoint(x: CGFloat(sinf(toRadian(degree: $0))) * radius + circleCenter.x, y: CGFloat(cosf(toRadian(degree: $0))) * radius + circleCenter.y)
            path.addLine(to: nextPoint)
        }
        
        return (path.cgPath, CGSize(width: viewportWidth(), height: path.bounds.size.height), lineLengthNormalized, circleCenter)
    }
    
    func viewportWidth() -> CGFloat {
        return 320
    }
    
    func buttonPath() -> UIBezierPath {
        let distance = 7
        let width = 20
        let path = UIBezierPath()
        
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: width, y: 0))

        path.move(to: CGPoint(x: 0, y: distance))
        path.addLine(to: CGPoint(x: width, y: distance))
        
        path.move(to: CGPoint(x: 0, y: 2 * distance))
        path.addLine(to: CGPoint(x: width, y: 2 * distance))

        path.apply(CGAffineTransform(translationX: CGFloat(0), y: CGFloat(CGFloat(distance) * CGFloat(0.5))))
        return path
    }
    
    func toRadian(degree: Int) -> Float {
        return Float(Double(degree) * (M_PI / 180.0))
    }
    
    func animateToCollapsed(shape: CAShapeLayer, duration: CFTimeInterval) {
        if (isCollapsed) {
            return
        }
        isCollapsed = true
        animate(shape: shape, duration: duration, stroke: (headerLineLengthNormalized, 1), headerAlpha: 0)
    }
    
    func animateToOpen(shape: CAShapeLayer, duration: CFTimeInterval) {
        if (!isCollapsed) {
            return
        }
        isCollapsed = false
        animate(shape: shape, duration: duration, stroke: (0, headerLineLengthNormalized), headerAlpha: 1)
    }

    func animate(shape: CAShapeLayer, duration: CFTimeInterval, stroke: (start: CGFloat, end: CGFloat), headerAlpha: CGFloat) {
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = shape.strokeEnd
        strokeEndAnimation.toValue = stroke.end
        strokeEndAnimation.duration = duration
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        strokeEndAnimation.fillMode = kCAFillModeBoth
        
        shape.strokeEnd = stroke.end
        shape.add(strokeEndAnimation, forKey: strokeEndAnimation.keyPath)
        
        let strokeBeginAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeBeginAnimation.beginTime = CACurrentMediaTime()
        strokeBeginAnimation.fromValue = shape.strokeStart
        strokeBeginAnimation.toValue = stroke.start
        strokeBeginAnimation.duration = duration
        strokeBeginAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear) // animation curve is Ease Out
        strokeBeginAnimation.fillMode = kCAFillModeBoth
        
        shape.strokeStart = stroke.start
        shape.add(strokeBeginAnimation, forKey: strokeBeginAnimation.keyPath)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { () -> Void in
            self.headerLabel.alpha = headerAlpha
            }, completion: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let deadZone = (start: CGFloat(10), end: CGFloat(50))
        if (scrollView.contentOffset.y < deadZone.start && isCollapsed) {
            animateToOpen(shape: headerShapeLayer, duration: 0.25)
        } else
            if (scrollView.contentOffset.y > deadZone.end && !isCollapsed) {
                animateToCollapsed(shape: headerShapeLayer, duration: 0.25)
            }
        }
}
