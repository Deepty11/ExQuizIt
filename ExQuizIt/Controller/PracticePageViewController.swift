//
//  PracticePageViewController.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 17/4/22.
//

import UIKit

protocol PageViewDelegate{
    func gotoNextPage(for index: Int)
}

class PracticePageViewController: UIPageViewController, /*UIPageViewControllerDataSource,*/ PageViewDelegate {
    
    

    var quizzes =  [QuizModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.dataSource = self
        self.quizzes = getQuizSource()
        UtilityService.shared.numberOfPracticeQuizzes = self.quizzes.count
        setViewControllers([getViewController(for: 0)], direction: .forward, animated: true)
        
        self.configureNavigationBar()
    }
    
    func getQuizSource() -> [QuizModel]{
        let unknownQuizArray =  DatabaseManager.shared.getAllUnknownQuizzes()
        return  UtilityService.shared.getRandomQuizzes(from: unknownQuizArray)
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Practice"
    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        if let currentVC = viewController as? CardViewController{
//            let pageIndex = currentVC.pageIndex
//            if pageIndex > 0{
//                return getViewController(for: pageIndex - 1)
//            }
//        }
//        return nil
//
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        if let currentVC = viewController as? CardViewController{
//            let pageIndex = currentVC.pageIndex
//            if pageIndex < quizzes.count - 1{
//                return getViewController(for: pageIndex + 1)
//            }
//        }
//        return nil
//    }
    
    func getViewController(for index: Int) -> UIViewController{
        if let vC = storyboard?.instantiateViewController(withIdentifier: String(describing: CardViewController.self)) as? CardViewController{
            vC.pageIndex = index
            vC.quiz = quizzes[index]
            vC.delegate = self
            return vC
            
        }
        return UIViewController()
        
    }
// MARK: - PageViewDelegate Method
    func gotoNextPage(for index: Int) {
        if index < self.quizzes.count - 1{
            setViewControllers([getViewController(for: index + 1)], direction: .forward, animated: true)
        }
        
    }
    
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return quizzes.count
//    }
//    
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        if let currentVc = pageViewController.viewControllers?.first as? CardViewController{
//            return currentVc.pageIndex
//        }
//        return 0
//    }

}
