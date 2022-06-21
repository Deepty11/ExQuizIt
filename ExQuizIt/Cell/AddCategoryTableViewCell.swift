//
//  AddCategoryTableViewCell.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/6/22.
//

import UIKit

class AddCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

}


