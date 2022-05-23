//
//  PracticeQuizStatisticsViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 26/4/22.
//

import UIKit

class PracticeQuizStatisticsViewController: UIViewController {
    @IBOutlet weak var masteredRatioLabel: UILabel!
    @IBOutlet weak var masteredProgressView: UIProgressView!
    @IBOutlet weak var reviewProgressView: UIProgressView!
    @IBOutlet weak var reviewRatioLabel: UILabel!
    @IBOutlet weak var learningProgressView: UIProgressView!
    @IBOutlet weak var learningRatioLabel: UILabel!
    @IBOutlet weak var statisticsView: CardView!
    
    var numberOfLearnings = 0
    var numberOfReviews = 0
    var numberOfMastered = 0
    var totalNumberOfPracticeQuizzes = 0
    
    var quizzes = [QuizModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        totalNumberOfPracticeQuizzes = UtilityService.shared.getPreferredNumberOfPracticeQuizzes()
        calculateProgress()
        setProgressViews()
        
        navigationController?.viewControllers.removeAll(where: {
            (vc) -> Bool in
            if vc.isKind(of: PracticePageViewController.self){
                return true
            } else{
                return false
            }
        })
        
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Statistics"
    }
    
    func setProgressViews() {
        
        masteredProgressView.setProgress(0, animated: false)
        reviewProgressView.setProgress(0, animated: false)
        learningProgressView.setProgress(0, animated: false)
        
        masteredRatioLabel.text = "\(numberOfMastered)/\(totalNumberOfPracticeQuizzes)"
        reviewRatioLabel.text = "\(numberOfReviews)/\(totalNumberOfPracticeQuizzes)"
        learningRatioLabel.text = "\(numberOfLearnings)/\(totalNumberOfPracticeQuizzes)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {[weak self] in
            guard let self = self else { return }
            
            self.masteredProgressView.setProgress(Float(self.numberOfMastered)/Float(self.totalNumberOfPracticeQuizzes),
                                                  animated: true)
            self.reviewProgressView.setProgress(Float(self.numberOfReviews)/Float(self.totalNumberOfPracticeQuizzes),
                                                animated: true)
            self.learningProgressView.setProgress(Float(self.numberOfLearnings)/Float(self.totalNumberOfPracticeQuizzes),
                                                  animated: true)
            
            print(self.numberOfMastered)
            print(self.numberOfReviews)
            print(self.numberOfLearnings)
        }
        
    }
    
    func calculateProgress() {
        numberOfLearnings = 0
        numberOfReviews = 0
        numberOfMastered = 0
        
        for status in UtilityService.shared.practiceQuizLearningStatusArray {
            switch(status) {
            case .mastered:
                numberOfMastered += 1
            case .reviewing:
                numberOfReviews += 1
            case .learning:
                numberOfLearnings += 1
            }
        }
        
        UtilityService.shared.practiceQuizLearningStatusArray = []
    }

}
