//
//  ViewController.swift
//  WhatEat
//
//  Created by Hira on 2021/9/29.
//
#warning("圓形進度表動畫")

import UIKit

class LotteryViewController: UIViewController {

    var timerT: CGFloat = 0
    var mTimer: Timer?
    var views = UIView()
    /// 標籤
    var mLabel = UILabel()
    /// 圓線條寬
    var progressWidth: CGFloat = 20
    /// 圓中心半徑
    let radius: CGFloat = 75
    /// 進度條
    var percentLayer = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //送回圓環layer，叫他trackLayer，加入view
        let trackLayer = createRingLayer(strokeColor: #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), fillColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
        views.layer.addSublayer(trackLayer)

        //送回圓環layer，叫他runningLayer，修圓角，轉180度，描邊線停留在0，加入view
        percentLayer = createRingLayer(strokeColor: #colorLiteral(red: 0.9490196078, green: 0.9960784314, blue: 0.3960784314, alpha: 1), fillColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))
        percentLayer.lineCap = .round
        percentLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1) //逆時針轉90度
        percentLayer.strokeEnd = 0 //描邊線動作停留的相對位置為0
        views.layer.addSublayer(percentLayer)
        views.layer.addSublayer(addWaveGradientLayer(percentLayer))
        
        mTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { timer in
            self.timerT += 0.5
            if self.timerT > 100 {
                self.mTimer?.invalidate()
                self.mTimer = nil
            } else {
                DispatchQueue.main.async {
                    self.mLabel.text = "\(Int(self.timerT))%"
                    self.percentLayer.strokeEnd = self.timerT / 100
                }
            }
        })
    }

    //加入標籤、view
    func setupUI() {
        mLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 2 * (radius + progressWidth), height: 2 * (radius + progressWidth)))
        mLabel.textAlignment = .center
        mLabel.text = "0%"
        mLabel.font = UIFont.systemFont(ofSize: 30, weight: .light)
        mLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        views = UIView(frame: CGRect(x: 50, y: 50, width: mLabel.frame.width, height: mLabel.frame.height))
        views.addSubview(mLabel)
        self.view.addSubview(views)
    }
    
    //圓環layer
    private func createRingLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let ringPath = UIBezierPath(arcCenter: CGPoint.zero,
                                    radius: radius,
                                    startAngle: 0,
                                    endAngle: .pi * 2,
                                    clockwise: true)
        let layer = CAShapeLayer()
        layer.path = ringPath.cgPath
        layer.lineWidth = progressWidth
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.position = CGPoint(x: views.frame.width / 2, y: views.frame.height / 2)
        return layer
    }

    /// 漸層色layer
    func addWaveGradientLayer(_ layer: CAShapeLayer) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = views.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1).cgColor, #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor]
        gradientLayer.mask = layer
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        return gradientLayer
    }
}
