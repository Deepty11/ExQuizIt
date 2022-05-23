//
//  CardViewController.swift
//  ExQuizIt
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
    var isCheckedCheckBox = false
    
    var quiz = QuizModel()
    var delegate : PageViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionLabel.text = self.quiz.question
        self.quizIndexLabel.text = "\(self.pageIndex + 1)/\(UtilityService.shared.numberOfPracticeQuizzes)"
        
        self.questionView.isHidden = false
        self.answerView.isHidden = true
        
        self.tapToSeeAnswerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleTapToSeeAnswerButtonTapped)))
        self.uncommonQuestionView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleUncommonQuizButtonTapped)))
        self.commonQuestionView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleCommonQuizButtonTapped)))
        self.checkBoxImageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleCheckBoxImageViewTapped)))
    }
    
    @objc func handleTapToSeeAnswerButtonTapped(sender: UITapGestureRecognizer) {
        answerLabel.text = self.quiz.answer
        
        crossIconImageView.tintColor = .red
        checkIconImageView.tintColor = UIColor(named: "checkIconColor")
        
        flipCard(from: questionView, to: answerView)
    }
    
    @objc func handleUncommonQuizButtonTapped(sender: UITapGestureRecognizer) {
        DatabaseManager.shared.updateLearningStatus(of: quiz, with: false)
        flipCard(from: answerView, to: questionView)
        delegate.gotoNextPage(for: pageIndex)
        
    }
    
    @objc func handleCommonQuizButtonTapped(sender: UITapGestureRecognizer) {
        if self.isCheckedCheckBox {
            // update isKnown to true and set learningStatus to 5
            DatabaseManager.shared.updateLearningStatus(of: quiz, with: true)
        } else {
            // update increment learning status by 1 and check
            // if learning status >= 5, set isKnown to true
            DatabaseManager.shared.updateLearningScale(of: quiz, with: true)
        }
        
        flipCard(from: answerView, to: questionView)
        delegate.gotoNextPage(for: pageIndex)
    }
    
    @objc func handleCheckBoxImageViewTapped(sender: UITapGestureRecognizer) {
        self.checkBoxImageView.image = isCheckedCheckBox
        ? UIImage(named: "CheckboxUncheckedIcon")
        : UIImage(named: "CheckboxCheckedIcon")
        
        self.isCheckedCheckBox = !self.isCheckedCheckBox
    }
    
    func flipCard(from source: UIView, to destination: UIView) {
        UIView.transition(with: source, duration: 0.25, options: .defaultTransitionOption) {
            source.isHidden = true
        }
        
        UIView.transition(with: destination, duration: 0.25, options: .defaultTransitionOption) {
            destination.isHidden = false
        }
            
    }

}
