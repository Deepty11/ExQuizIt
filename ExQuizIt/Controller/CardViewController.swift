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
    @IBOutlet weak var unFamiliarQuestionButton: UIButton!
    @IBOutlet weak var familiarQuestionButton: UIButton!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var quizIndexLabel: UILabel!
    
    var pageIndex = 0
    var quiz = Quiz(id: "", question: "", correct_answer: "", isKnown: false, learningStatus: 0)
    var delegate: PageViewDelegate?
    var practiceQuizRecord: PracticeRecord?
    
    var isCheckedCheckBox: Bool = false {
        didSet {
            checkBoxButton.isSelected = isCheckedCheckBox
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionLabel.text = self.quiz.question
        self.quizIndexLabel.text = "\(self.pageIndex + 1)/\(UtilityService.shared.numberOfPracticeQuizzes)"
        
        self.questionView.isHidden = false
        self.answerView.isHidden = true
        
        self.checkBoxButton.tintColor = .black
        self.checkBoxButton.setImage(UIImage(named: "CheckboxCheckedIcon"), for: .selected)
        
        self.tapToSeeAnswerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleTapToSeeAnswerButtonTapped)))
        self.unFamiliarQuestionButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleUncommonQuizButtonTapped)))
        self.familiarQuestionButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleCommonQuizButtonTapped)))
    }
    
    @objc func handleTapToSeeAnswerButtonTapped(sender: UITapGestureRecognizer) {
        answerLabel.text = self.quiz.correct_answer
        
        flipCard(from: questionView, to: answerView)
    }
    
    @objc func handleUncommonQuizButtonTapped(sender: UITapGestureRecognizer) {
        DatabaseManager.shared.setLearningScale(of: quiz, with: Constants.MinLearningStatus)
        flipCard(from: answerView, to: questionView)
        delegate?.gotoNextPage(for: pageIndex)
        
    }
    
    @objc func handleCommonQuizButtonTapped(sender: UITapGestureRecognizer) {
        if self.isCheckedCheckBox {
            // update isKnown to true and set learningStatus to 5
            DatabaseManager.shared.setLearningScale(of: quiz, with: Constants.MaxLearningStatus)
        } else {
            // update increment learning status by 1 and check
            // if learning status >= 5, set isKnown to true
            DatabaseManager.shared.increaseLearningScale(of: quiz)
        }
        
        flipCard(from: answerView, to: questionView)
        delegate?.gotoNextPage(for: pageIndex)
    }
    
    @IBAction func handleCheckBoxButtonTapped(_ sender: Any) {
        self.isCheckedCheckBox = !self.isCheckedCheckBox
    }

}
