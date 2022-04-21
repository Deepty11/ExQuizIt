//
//  NotesListViewController.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 5/4/22.
//

import UIKit
import RealmSwift

class QuizListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

   
    @IBOutlet weak var emptyQuizLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var quizLoadingActivityIndicatorView: UIActivityIndicatorView!
    let realm = try! Realm()
    var quizSources = [QuizModel](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var quizzes: [QuizModel]{
        return Array(realm.objects(QuizModel.self))
    }
    
    override func viewDidLoad() {
        self.fetchQuizzes()
        super.viewDidLoad()
        configureNavigationBar()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchQuizzes()
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for (id,_) in AppState.shared.answerViewDisplayed.enumerated(){
            AppState.shared.answerViewDisplayed[id] = false
        }
    }
    
    @IBAction func handlePracticeButtonTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PracticePageViewController") as? PracticePageViewController{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchQuizzes(){
        if self.quizzes.isEmpty{
            self.emptyQuizLabel.text = "Loading ..."
            self.quizLoadingActivityIndicatorView.startAnimating()
            JSONManager.shared.getAllQuizzesFromAPIsAndCachingToRealm { quizzes in
                self.quizLoadingActivityIndicatorView.stopAnimating()
                self.quizLoadingActivityIndicatorView.isHidden = true
                self.refreshUI()
                return
            }
        }
        self.refreshUI()
        
    }
    
    func refreshUI(){
        self.quizSources = self.quizzes
        for _ in 0 ..< self.quizSources.count{
            AppState.shared.answerViewDisplayed.append(false)
        }
        self.tableView.reloadData()
        self.tableView.isHidden = self.quizSources.isEmpty ? true : false
        self.emptyQuizLabel.isHidden = self.quizSources.isEmpty ? false : true
    }
    
    private func configureNavigationBar(){
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = "Quizzes"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(addButtonTapped))
    }
    
    func displayAlert(title: String?, message: String?){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.dismiss(animated: true) {
                    self.quizSources  = self.quizzes
                    if self.quizSources.isEmpty{
                        self.tableView.isHidden = true
                        self.emptyQuizLabel.isHidden = false
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    @objc func addButtonTapped(){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddQuizViewController") as? AddQuizViewController{
            self.navigationController?.pushViewController(vc,
                                                          animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "QuizTableViewCell", for: indexPath) as? QuizTableViewCell{
            
            cell.questionLabel.text = quizSources[indexPath.row].question
            cell.answerLabel.text = quizSources[indexPath.row].answer
            let tp = UITapGestureRecognizer(target: self, action: #selector(handleCommonQuizViewTapped))
            let tp2 = UITapGestureRecognizer(target: self, action: #selector(handleUnCommonQuizViewTapped))
            cell.commonQuizView.addGestureRecognizer(tp)
            cell.uncommonQuizView.addGestureRecognizer(tp2)
            cell.questionView.isHidden = AppState.shared.answerViewDisplayed[indexPath.row] ? true : false
            cell.answerView.isHidden = AppState.shared.answerViewDisplayed[indexPath.row] ? false : true
            cell.learningView.isHidden = quizSources[indexPath.row].isKnown ? true : false
            
            cell.selectionStyle = .none
            return cell
            
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.beginUpdates()
            let alert = UIAlertController(title: "Attention",
                                          message: "Do you want to delete the quiz?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok",
                                         style: .default) { _ in
                self.dismiss(animated: true)
                DatabaseManager.shared.deleteQuizFromDatabase(quiz: self.quizSources[indexPath.row])
                self.displayAlert(title: nil, message: "Deleted Successfully")
            }
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            
            //self.displayAlert(title: nil, message: "Deleted Successfully")
            tableView.endUpdates()
            self.quizSources = quizzes
            tableView.reloadData()
        }
    }
    
    
    @objc func handleCommonQuizViewTapped(sender: UITapGestureRecognizer){
        if let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)){
            tableView.beginUpdates()
            if let cell = tableView.cellForRow(at: indexPath) as? QuizTableViewCell{
                AppState.shared.answerViewDisplayed[indexPath.row] = false
                DatabaseManager.shared.updateLearningStatus(with: true, of: quizSources[indexPath.row])
                self.flipCardOnCell(from: cell.answerView, to: cell.questionView)
                cell.learningView.isHidden = quizSources[indexPath.row].isKnown ? true : false
            }
            tableView.endUpdates()
        }
        
    }
    
    @objc func handleUnCommonQuizViewTapped(sender: UITapGestureRecognizer){
        if let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)){
            tableView.beginUpdates()
            if let cell = tableView.cellForRow(at: indexPath) as? QuizTableViewCell{
                AppState.shared.answerViewDisplayed[indexPath.row] = false
                DatabaseManager.shared.updateLearningStatus(with: false, of: quizSources[indexPath.row])
                self.flipCardOnCell(from: cell.answerView, to: cell.questionView)
                cell.learningView.isHidden = quizSources[indexPath.row].isKnown ? true : false
            }
            tableView.endUpdates()
        }
    }
    
    //selecting on cell will flip the view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !AppState.shared.answerViewDisplayed[indexPath.row]{
            tableView.beginUpdates()
            if let cell =  tableView.cellForRow(at: indexPath) as? QuizTableViewCell{
                AppState.shared.answerViewDisplayed[indexPath.row] = true
                self.flipCardOnCell(from: cell.questionView, to: cell.answerView)
                cell.learningView.isHidden = quizSources[indexPath.row].isKnown ? true : false
            }
            tableView.endUpdates()
        }
        
    }
    
    func flipCardOnCell(from source: UIView, to destination: UIView){
        UIView.transition(with: source,
                          duration: 0.25,
                          options: AppState.shared.transitionOption) {
            source.isHidden = true
            
        }
        
        UIView.transition(with: destination,
                          duration: 0.25,
                          options: AppState.shared.transitionOption) {
            
            destination.isHidden = false
        }
            
    }
  

}
