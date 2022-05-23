//
//  AddNoteTableViewCell.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 6/4/22.
//

import UIKit

class AddQuizTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var quizTextView: UITextView!
    
    var inputType: InputType!
    var delegate: CellInteractionDelegte?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(){
        self.quizTextView.delegate = self
        if self.quizTextView.text == "" || self.quizTextView.text == nil {
            self.quizTextView.text = inputType.rawValue
            self.quizTextView.textColor = UIColor.gray
        } else {
            self.quizTextView.textColor = UIColor.black
        }
        
        self.cellView.layer.cornerRadius = 5.0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if self.quizTextView.text == "" || self.quizTextView.text == nil {
            self.quizTextView.text = inputType.rawValue
            self.quizTextView.resignFirstResponder()
            self.quizTextView.textColor = .gray
        } else {
            self.quizTextView.textColor = .black
        }
        
        delegate?.textViewDidChanged(cell: self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if InputType.allCases.map(\.rawValue).contains(self.quizTextView.text) {
            self.quizTextView.text = ""
        }
        
        self.quizTextView.textColor = .black
        delegate?.textViewDidBeginEditing(cell: self)
    }
    
    /*
     * isEmpty | Result
     * --------+----------
     * nil     |  √
     * true    |  √
     * false   |  x
     */
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.quizTextView.text?.isEmpty ?? true {
            self.quizTextView.text = inputType.rawValue
            self.quizTextView.resignFirstResponder()
            self.quizTextView.textColor = .gray
        } else {
            self.quizTextView.textColor = .black
        }
    }
    
}
