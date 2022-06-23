//
//  AddCategoryTableViewCell.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/6/22.
//

import UIKit

class AddCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryTextField: UITextField!
    var delegate: CellInteractionDelegte?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    @IBAction func textFieldDidChange(_ sender: Any) {
        delegate?.textFieldDidChanged(cell: self)
    }
}



