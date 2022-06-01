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
    var quiz = Quiz(id: "", question: "", correct_answer: "", learningStatus: 0)
    var delegate: PageViewDelegate?
    var quizRecord = QuizRecord(id: "")
    let practiceSessionUtilityService = PracticeSessionUtilityService()
    let databaseManager = DatabaseManager()
    
    var isCheckedCheckBox: Bool = false {
        didSet {
            checkBoxButton.isSelected = isCheckedCheckBox
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questionLabel.text = self.quiz.question
        self.quizIndexLabel.text = "\(self.pageIndex + 1)/\(practiceSessionUtilityService.getPreferredNumberOfPracticeQuizzes())"
        
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
        quiz.learningStatus = Constants.MinLearningStatus
        databaseManager.saveQuiz(quiz)
        setQuizRecordStatus(with: Constants.MinLearningStatus)
        
        flipCard(from: answerView, to: questionView)
        
        delegate?.sendQuizRecordBackToSession(record: quizRecord, for: pageIndex)
    }
    
    @objc func handleCommonQuizButtonTapped(sender: UITapGestureRecognizer) {
        if self.isCheckedCheckBox {
            // update isKnown to true and set learningStatus to 5
            quiz.learningStatus = Constants.MaxLearningStatus
            databaseManager.saveQuiz(quiz)
        } else {
            // update increment learning status by 1 and check
            // if learning status >= 5, set isKnown to true
            quiz.learningStatus = getLearningStatus(of: quiz)
            databaseManager.saveQuiz(quiz)
        }
        
        setQuizRecordStatus(with: quiz.learningStatus ?? Constants.MinLearningStatus)
        
        flipCard(from: answerView, to: questionView)
        
        delegate?.sendQuizRecordBackToSession(record: quizRecord, for: pageIndex)
    }
    
    @IBAction func handleCheckBoxButtonTapped(_ sender: Any) {
        self.isCheckedCheckBox = !self.isCheckedCheckBox
    }
    
    func getLearningStatus(of quiz: Quiz) -> Int {
        min((quiz.learningStatus ?? Constants.MinLearningStatus) + 1, Constants.MaxLearningStatus)
    }
    
    func setQuizRecordStatus(with value: Int) {
        switch value {
        case Constants.MaxLearningStatus:
            print("\(quiz.id ?? "") mastered")
            quizRecord.status = PracticeQuizStatus.mastered.rawValue
        case Constants.MinLearningStatus:
            print("\(quiz.id ?? "") learning")
            quizRecord.status = PracticeQuizStatus.learning.rawValue
        default:
            print("\(quiz.id ?? "") review")
            quizRecord.status = PracticeQuizStatus.reviewing.rawValue
        }
    }
    
}
