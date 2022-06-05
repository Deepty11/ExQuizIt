//
//  PracticeListViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 2/6/22.
//

import UIKit

class PracticeListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var practiceSessions = [PracticeSession]()
    var databaseManager = DatabaseManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        practiceSessions = databaseManager.getAllPracticeSessions()
        tableView.reloadData()
        
        emptyLabel.isHidden = !practiceSessions.isEmpty
        tableView.isHidden = practiceSessions.isEmpty
    }
    
    @IBAction func handleTakeAQuizTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: String(describing: PracticePageViewController.self))
            as? PracticePageViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }

}

 // MARK: - TableView Delegates and Datasource
extension PracticeListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return practiceSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PracticeTableViewCell.self),
                                                    for: indexPath) as? PracticeTableViewCell {
            let practiceRecord = practiceSessions[indexPath.row]
            
            cell.practiceNoLabel.text = Strings.practiceNoString + String(indexPath.row + 1)
            cell.totalNoOfQuizzesLabel.text = Strings.totalQuizString + String(practiceRecord.quizRecords.count)
            cell.startTimeLabel.text = Strings.startTimeString + practiceRecord.startTime
            cell.endTimeLabel.text = Strings.endTimeString + practiceRecord.endTime
            
            return cell
        }
        
        return  UITableViewCell()
    }
    
    
}
