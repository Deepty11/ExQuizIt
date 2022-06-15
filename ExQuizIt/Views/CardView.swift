//
//  CardView.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 10/4/22.
//

import UIKit

class CardView: UIView {

    override func layoutSubviews() {
        setRoundedBorderAndShadow()
    }
    
    func setRoundedBorderAndShadow() {
        layer.cornerRadius = 5.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowOpacity = 0.65
    }

}
