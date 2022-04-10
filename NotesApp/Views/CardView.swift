//
//  CardView.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 10/4/22.
//

import UIKit

class CardView: UIView {

    override func layoutSubviews() {
        self.setRoundedBorderAndShadow()
    }
    
    func setRoundedBorderAndShadow(){
        self.layer.cornerRadius = 5.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.75
        
        // cacheing shadow
//        self.cellView.layer.shouldRasterize = true
//        self.cellView.layer.rasterizationScale = UIScreen.main.scale
        
        
        
    }

}
