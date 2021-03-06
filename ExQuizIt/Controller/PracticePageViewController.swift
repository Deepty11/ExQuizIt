//
//  PracticePageViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 17/4/22.
//

import UIKit

protocol PageViewDelegate {
    func gotoNextPage(for index: Int)
}

class PracticePageViewController: UIPageViewController, PageViewDelegate {
    var quizzes =  [Quiz]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        quizzes = getQuizSource()
        UtilityService.shared.numberOfPracticeQuizzes = self.quizzes.count
        UtilityService.shared.practiceQuizLearningStatusMap = [ : ]
        
        setViewControllers([getViewController(for: 0)], direction: .forward, animated: true)
        
    }
    
    func getQuizSource() -> [Quiz] {
        let unknownQuizArray =  DatabaseManager.shared.getAllUnknownQuizzes()
        return UtilityService.shared.getRandomQuizzes(from: unknownQuizArray)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Practice"
    }
    
    func getViewController(for index: Int) -> UIViewController {
        if let vC = storyboard?.instantiateViewController(
            withIdentifier: String(describing: CardViewController.self)) as? CardViewController {
            vC.pageIndex = index
            vC.quiz = quizzes[index]
            vC.delegate = self
            return vC
            
        }
        
        return UIViewController()
        
    }
// MARK: - PageViewDelegate Method
    func gotoNextPage(for index: Int) {
        if index < self.quizzes.count - 1 {
            setViewControllers([getViewController(for: index + 1)],
                               direction: .forward,
                               animated: true)
        } else {
            if let vC = storyboard?.instantiateViewController(
                withIdentifier: String(describing: PracticeQuizStatisticsViewController.self))
                as? PracticeQuizStatisticsViewController {
                vC.quizzes = self.quizzes
                self.navigationController?.pushViewController(vC, animated: true)
            }
        }
        
    }

}
