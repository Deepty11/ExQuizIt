//
//  PracticePageViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 17/4/22.
//

import UIKit

protocol PageViewDelegate {
    func sendQuizRecordBackToSession(record: QuizRecord, for pageIndex: Int)
}

class PracticePageViewController: UIPageViewController {
    var quizzes =  [Quiz]()
    var practiceSession = PracticeSession()
    let practiceSessionUtilityService = PracticeSessionUtilityService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        quizzes = getQuizSource()
        
        setViewControllers([getViewController(for: 0)], direction: .forward, animated: true)
        
    }
    
    func getQuizSource() -> [Quiz] {
        let unknownQuizArray =  DatabaseManager.shared.getAllUnknownQuizzes()
        return practiceSessionUtilityService.getRandomQuizzes(from: unknownQuizArray)
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Practice"
    }
    
    func getViewController(for index: Int) -> UIViewController {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: String(describing: CardViewController.self)) as? CardViewController {
            vc.pageIndex = index
            vc.quiz = quizzes[index]
            vc.quizRecord = QuizRecord(id: quizzes[index].id ?? "")
            vc.delegate = self
            return vc
        }
        
        return UIViewController()
    }
    
}

// MARK: - PageViewDelegate Method
extension PracticePageViewController: PageViewDelegate {
    func sendQuizRecordBackToSession(record: QuizRecord, for pageIndex: Int) {
        //update quizRecords in the practiceSession
        practiceSession.quizRecords.append(record)
        gotoNextPage(for: pageIndex)
    }
    
    func gotoNextPage(for index: Int) {
        if index < self.quizzes.count - 1 {
            setViewControllers([getViewController(for: index + 1)],
                               direction: .forward,
                               animated: true)
        } else {
            // set end time and then save the practiceSession in realm
            practiceSession.endTime = Date().getFormattedDate(format: Strings.DateFormat)
            DatabaseManager.shared.savePracticeSession(practiceSession: practiceSession)
            
            if let vc = storyboard?.instantiateViewController(
                withIdentifier: String(describing: PracticeQuizStatisticsViewController.self))
                as? PracticeQuizStatisticsViewController {
                vc.practiceSession = practiceSession
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
