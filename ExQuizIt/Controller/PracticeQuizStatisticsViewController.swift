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
    
    var numberOflearnings = 0
    var numberOfReviews = 0
    var numberOfMastered = 0
    
    var quizzes = [QuizModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setValuesForProgressView()
        self.setProgressViews()
        self.navigationItem.title = "Statistics"
        navigationController?.viewControllers.removeAll(where: {
            (vc) -> Bool in
            if vc.isKind(of: PracticePageViewController.self){
                return true
            } else{
                return false
            }
        })
        
    }
    
    func setProgressViews(){
        
        self.masteredProgressView.setProgress(0, animated: false)
        self.reviewProgressView.setProgress(0, animated: false)
        self.learningProgressView.setProgress(0, animated: false)
        
        self.masteredRatioLabel.text = "\(self.numberOfMastered)/\(self.quizzes.count)"
        self.reviewRatioLabel.text = "\(self.numberOfReviews)/\(self.quizzes.count)"
        self.learningRatioLabel.text = "\(self.numberOflearnings)/\(self.quizzes.count)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.masteredProgressView.setProgress(Float(self.numberOfMastered)/Float(self.quizzes.count), animated: true)
            self.reviewProgressView.setProgress(Float(self.numberOfReviews)/Float(self.quizzes.count), animated: true)
            self.learningProgressView.setProgress(Float(self.numberOflearnings)/Float(self.quizzes.count), animated: true)
            
            print(self.numberOfMastered)
            print(self.numberOfReviews)
            print(self.numberOflearnings)
        }
        
    }
    
    func setValuesForProgressView(){
        
        for quiz in self.quizzes{
            if quiz.isKnown{
                self.numberOfMastered += 1
            } else{
                quiz.learningStatus == 0 ? (self.numberOflearnings += 1) : (self.numberOfReviews += 1)
            }
        }
    }
    

}
