//
//  CardViewController.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 17/4/22.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var questionView: CardView!
    @IBOutlet weak var answerView: CardView!
    @IBOutlet weak var tapToSeeAnswerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var uncommonQuestionView: UIView!
    @IBOutlet weak var commonQuestionView: UIView!
    @IBOutlet weak var crossIconImageView: UIImageView!
    @IBOutlet weak var checkIconImageView: UIImageView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var quizIndexLabel: UILabel!
    
    var pageIndex = 0
    var quiz: QuizModel?
    var isCheckedCheckBox = false
    var delegate : PageViewDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionView.isHidden = false
        self.answerView.isHidden = true
        self.questionLabel.text = self.quiz?.question
        self.quizIndexLabel.text = "\(self.pageIndex + 1)/\(UtilityService.shared.numberOfPracticeQuizzes)"
        
        self.tapToSeeAnswerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapToSeeAnswerButtonTapped)))
        self.uncommonQuestionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUncommonQuizButtonTapped)))
        self.commonQuestionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCommonQuizButtonTapped)))
        self.checkBoxImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCheckBoxImageViewTapped)))
    }
    
    @objc func handleTapToSeeAnswerButtonTapped(sender: UITapGestureRecognizer){
        self.answerLabel.text = self.quiz?.answer
        self.crossIconImageView.image = self.crossIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.crossIconImageView.tintColor = .red
        self.checkIconImageView.image = self.checkIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.checkIconImageView.tintColor = UIColor(named: "checkIcon Color")
        self.flipCard(from: self.questionView, to:  self.answerView)
    }
    
    
    @objc func handleUncommonQuizButtonTapped(sender: UITapGestureRecognizer){
        DatabaseManager.shared.updateLearningStatus(with: false, of: self.quiz ?? QuizModel())
        self.flipCard(from: self.answerView, to: self.questionView)
        self.delegate.gotoNextPage(for: self.pageIndex)
        
    }
    
    @objc func handleCommonQuizButtonTapped(sender: UITapGestureRecognizer){
        if self.isCheckedCheckBox{
            // update isKnown to true and set learningStatus to 5
            DatabaseManager.shared.updateLearningStatus(with: true, of: self.quiz ?? QuizModel())
        } else{
            // update increment learning status by 1 and check
            // if learning status >= 5, set isKnown to true
            DatabaseManager.shared.updateLearningScale(with: true, of: self.quiz ?? QuizModel())
        }
        self.flipCard(from: self.answerView, to: self.questionView)
        self.delegate.gotoNextPage(for: self.pageIndex)
    }
    
    @objc func handleCheckBoxImageViewTapped(sender: UITapGestureRecognizer){
        self.checkBoxImageView.image = self.isCheckedCheckBox ? UIImage(named: "Checkbox Unchecked Icon") : UIImage(named: "Checkbox Checked Icon")
        self.isCheckedCheckBox = !self.isCheckedCheckBox
    }
    
    func flipCard(from source: UIView, to destination: UIView){
        UIView.transition(with: source,
                          duration: 0.25,
                          options: AppState.shared.transitionOption) {
            source.isHidden = true
            
        }
        
        UIView.transition(with: destination,
                          duration: 0.25,
                          options: AppState.shared.transitionOption) {
            
            destination.isHidden = false
        }
            
    }

}
