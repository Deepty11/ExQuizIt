//
//  practiceTableViewCell.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 2/6/22.
//

import UIKit

class PracticeTableViewCell: UITableViewCell {
    @IBOutlet weak var practiceView: CardView!
    @IBOutlet weak var practiceNoLabel: UILabel!
    @IBOutlet weak var totalNoOfQuizzesLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none                
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
