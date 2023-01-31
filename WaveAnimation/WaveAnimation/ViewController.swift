//
//  ViewController.swift
//  WaveAnimation
//
//  Created by Hira on 2021/9/14.
//
#warning("波浪動畫")
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bottleImageView: UIImageView!
    @IBOutlet weak var lightningImageView: UIImageView!
    @IBOutlet weak var contentView: UIView!

    var frontWaveLayer: CAShapeLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        frontWaveLayer = addWaveLayer()
        contentView.layer.addSublayer(frontWaveLayer)
        contentView.layer.addSublayer(addWaveGradientLayer())

        contentView.bringSubviewToFront(bottleImageView)
        contentView.bringSubviewToFront(lightningImageView)
        contentView.layer.masksToBounds = true

        contentView.layer.add(bottleAnimate(), forKey: "bottle1")
        frontWaveLayer.add(imgAnimate(), forKey: "wave")
        lightningImageView.layer.add(iconImgAnimate(), forKey: "lightning1")
    }

    /// 波浪漸層layer
    func addWaveGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frontWaveLayer.bounds
        gradientLayer.colors = [#colorLiteral(red: 0, green: 0.7529411765, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.3333333333, green: 0.3450980392, blue: 1, alpha: 1).cgColor]
        gradientLayer.mask = frontWaveLayer
        return gradientLayer
    }

    /// 波浪layer
    func addWaveLayer() -> CAShapeLayer {
        let layer1 = CAShapeLayer()
        layer1.bounds = contentView.bounds
        layer1.position = CGPoint(x: 0, y: contentView.frame.height)
        layer1.anchorPoint = CGPoint.zero
        layer1.path = frontLayerPath()
        layer1.fillColor = #colorLiteral(red: 0, green: 0.7529411765, blue: 1, alpha: 1)
        return layer1
    }

    /// 繪製波浪
    func frontLayerPath() -> CGPath? {

        let w: CGFloat = contentView.frame.width
        let h: CGFloat = contentView.frame.height
        let bezierFristWave = UIBezierPath()
        let waveHeight: CGFloat = 5
        let pathRef = CGMutablePath()
        let startOffY = waveHeight * CGFloat(sinf(0 * .pi * 2 / Float(w)))
        var orignOffY: CGFloat = 0.0
        pathRef.move(to: CGPoint(x: 0, y: startOffY), transform: .identity)
        bezierFristWave.move(to: CGPoint(x: 0, y: startOffY))

        for i in stride(from: 0 as CGFloat, to: w * 2, by: +1 as CGFloat) {
            orignOffY = waveHeight * CGFloat(sinf(Float(2 * .pi / w * i)))
            bezierFristWave.addLine(to: CGPoint(x: CGFloat(i), y: orignOffY))
        }

        bezierFristWave.addLine(to: CGPoint(x: w * 2, y: orignOffY))
        bezierFristWave.addLine(to: CGPoint(x: w * 2, y: h))
        bezierFristWave.addLine(to: CGPoint(x: 0, y: h))
        bezierFristWave.addLine(to: CGPoint(x: 0, y: startOffY))
        bezierFristWave.close()
        return bezierFristWave.cgPath
    }

    /// 瓶子組動畫效果搖晃
    func bottleAnimate() -> CABasicAnimation {
        //這一段是Z搖晃
        let mAnimationZ = CABasicAnimation(keyPath: "transform.rotation.z")
        mAnimationZ.duration = 0.1
        mAnimationZ.fromValue = -0.1
        mAnimationZ.toValue = 0.1
        mAnimationZ.autoreverses = true
        mAnimationZ.fillMode = .removed
        mAnimationZ.repeatCount = 10
        return mAnimationZ
    }

    /// 波浪組動畫效果
    func imgAnimate() -> CAAnimationGroup {
        let w: CGFloat = contentView.frame.width
        let height = contentView.frame.height * 0.7

        //這一段是向左移
        let mAnimationX = CABasicAnimation(keyPath: "transform.translation.x")
        mAnimationX.duration = 1.5
        mAnimationX.fromValue = NSNumber(value: 0)
        mAnimationX.toValue = NSNumber(value: Float(-w))
        mAnimationX.repeatCount = MAXFLOAT
        mAnimationX.fillMode = .forwards
        //這一段是向上移
        let mAnimationY = CABasicAnimation(keyPath: "transform.translation.y")
        mAnimationX.fromValue = 0
        mAnimationY.toValue = -height
        mAnimationY.duration = 2
        mAnimationY.isRemovedOnCompletion = false
        mAnimationY.fillMode = .forwards

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [mAnimationX, mAnimationY]
        groupAnimation.duration = 9999
        groupAnimation.repeatCount = 0
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        return groupAnimation
    }

    /// 閃電組動畫效果
    func iconImgAnimate() -> CAAnimationGroup {
        //這一段是透明度
        let animationO = CABasicAnimation(keyPath: "opacity")
        animationO.byValue = 1
        animationO.duration = 0.4
        animationO.repeatCount = 0
        animationO.isRemovedOnCompletion = false
        animationO.fillMode = CAMediaTimingFillMode.forwards
        //這一段是旋轉
        let animationZ = CABasicAnimation(keyPath: "transform.rotation.z")
        animationZ.byValue = Double.pi
        animationZ.duration = 0.2
        animationZ.repeatCount = 3
        animationZ.isRemovedOnCompletion = false
        animationZ.fillMode = CAMediaTimingFillMode.forwards

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animationO, animationZ]
        groupAnimation.duration = 0.6
        groupAnimation.repeatCount = 0
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        groupAnimation.beginTime = CACurrentMediaTime() + 2.1
        groupAnimation.delegate = self
        return groupAnimation
    }

    /// 閃電組動畫效果2
    func iconImgAnimate2(_ beginTime: TimeInterval = 0) -> CAAnimationGroup {
        //這一段是透明度
        let animationO2 = CABasicAnimation(keyPath: "opacity")
        animationO2.byValue = -0.1
        animationO2.duration = 0.15
        animationO2.repeatCount = 0
        animationO2.isRemovedOnCompletion = false
        animationO2.fillMode = CAMediaTimingFillMode.removed
        //這一段是縮放
        let animationsS = CABasicAnimation(keyPath: "transform.scale")
        animationsS.byValue = 0.4
        animationsS.duration = 0.15
        animationsS.repeatCount = 0
        animationsS.isRemovedOnCompletion = false
        animationsS.fillMode = CAMediaTimingFillMode.removed

        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [animationO2, animationsS]
        groupAnimation.duration = 0.3
        groupAnimation.repeatCount = 0
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = CAMediaTimingFillMode.forwards
        groupAnimation.beginTime = CACurrentMediaTime() + beginTime
        return groupAnimation
    }
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == lightningImageView.layer.animation(forKey: "lightning1") {
            self.lightningImageView.layer.add(self.iconImgAnimate2(), forKey: "lightning2")
        }
    }
}
