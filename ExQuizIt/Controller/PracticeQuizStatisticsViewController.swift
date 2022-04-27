//
//  PracticeQuizStatisticsViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 26/4/22.
//

import UIKit

class PracticeQuizStatisticsViewController: UIViewController {

    @IBOutlet weak var masteredProgressView: UIProgressView!
    @IBOutlet weak var reviewProgressView: UIProgressView!
    @IBOutlet weak var learningProgressView: UIProgressView!
    @IBOutlet weak var statisticsView: CardView!
    
    var numberOflearnings = 0
    var numberOfReviews = 0
    var numberOfMastered = 0
    
    var quizzes = [QuizModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getValuesForProgressView()
        self.setProgressViews()
        self.navigationItem.title = "Statistics"
        
    }
    
    func setProgressViews(){
        
        self.masteredProgressView.setProgress(0, animated: false)
        self.reviewProgressView.setProgress(0, animated: false)
        self.learningProgressView.setProgress(0, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.masteredProgressView.setProgress(Float(self.numberOfMastered)/Float(self.quizzes.count), animated: true)
            self.reviewProgressView.setProgress(Float(self.numberOfReviews)/Float(self.quizzes.count), animated: true)
            self.learningProgressView.setProgress(Float(self.numberOflearnings)/Float(self.quizzes.count), animated: true)
            print(self.numberOfMastered)
            print(self.numberOfReviews)
            print(self.numberOflearnings)
        }
        
    }
    
    func getValuesForProgressView(){
        
        for quiz in self.quizzes{
            if quiz.isKnown{
                self.numberOfMastered += 1
            } else{
                quiz.learningStatus == 0 ? (self.numberOflearnings += 1) : (self.numberOfReviews += 1)
            }
        }
    }
    

}
