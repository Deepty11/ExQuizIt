//
//  NotesTableViewCell.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 6/4/22.
//

import UIKit

class QuizTableViewCell: UITableViewCell {

    @IBOutlet weak var questionView: CardView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerView: CardView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var unFamiliarQuizButton: UIButton!
    @IBOutlet weak var familiarQuizButton: UIButton!
    @IBOutlet weak var learningView: UIView!
    
    var delegate: CellButtonInteractionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.learningView.layer.borderWidth = 1
        self.learningView.layer.borderColor = UIColor.systemPink.cgColor
        self.learningView.layer.cornerRadius = 2
        
        selectionStyle = .none
    }
    
    @IBAction func handleUnFamiliarQuizButtonTapped(_ sender: Any) {
        delegate?.handleUnCommonQuizButtonEvent(cell: self)
    }
    
    @IBAction func handleCommonQuizButtonTapped(_ sender: Any) {
        delegate?.handleCommonQuizButtonEvent(cell: self)
    }
}
