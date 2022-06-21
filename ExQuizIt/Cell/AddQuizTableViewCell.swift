//
//  AddNoteTableViewCell.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 6/4/22.
//

import UIKit

class AddQuizTableViewCell: UITableViewCell {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var quizTextView: UITextView!
    @IBOutlet weak var quizLabel: UILabel!
    
    var inputType = InputType.question
    var delegate: CellInteractionDelegte?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell() {
        quizTextView.delegate = self
//        if quizTextView.text?.isEmpty ?? true {
//            quizTextView.text = inputType.rawValue
//            quizTextView.textColor = UIColor.gray
//        } else {
//            quizTextView.textColor = UIColor.black
//        }
        
        cellView.layer.cornerRadius = 5.0
    }
    
}

//MARK: -UITextViewDelegate
extension AddQuizTableViewCell: UITextViewDelegate {
    internal func textViewDidChange(_ textView: UITextView) {
//        if quizTextView.text?.isEmpty ?? true {
//            quizTextView.text = inputType.rawValue
//            quizTextView.resignFirstResponder()
//        } else {
//            quizTextView.textColor = .black
//        }
        
        delegate?.textViewDidChanged(cell: self)
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView) {
//        if InputType.allCases.map(\.rawValue).contains(quizTextView.text) {
//            quizTextView.text = ""
//        }
//
//        quizTextView.textColor = .black
        delegate?.textViewDidBeginEditing(cell: self)
    }
    
    /*
     * isEmpty | Result
     * --------+----------
     * nil     |  √
     * true    |  √
     * false   |  x
     */
    internal func textViewDidEndEditing(_ textView: UITextView) {
//        if quizTextView.text?.isEmpty ?? true {
//            quizTextView.text = inputType.rawValue
//            quizTextView.resignFirstResponder()
//            //quizTextView.textColor = .gray
//        } else {
//            //quizTextView.textColor = .black
//        }
    }
}
