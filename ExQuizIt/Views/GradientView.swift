//
//  GradientView.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 24/4/22.
//

import Foundation
import UIKit

class GradientView: UIView{
    
    var fromColor: UIColor = UIColor(named:"Gradient From Color") ?? UIColor.black
    var toColor: UIColor = UIColor(named:"Gradient To Color") ?? UIColor.white
    override func layoutSubviews() {
        if let subLayer = self.layer.sublayers?[0] as? CAGradientLayer{
            subLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [self.fromColor.cgColor , self.toColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.frame = self.bounds
        
        self.layer.addSublayer(gradientLayer)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
