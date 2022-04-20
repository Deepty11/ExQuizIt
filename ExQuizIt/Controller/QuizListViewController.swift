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
    
    let realm = try! Realm()
    var quizSources = [QuizModel](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var quizes: [QuizModel]{
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
        if self.quizes.isEmpty{
            /// calls and downloads data from API and then saves to realm
            /// and then fetch data from realm
            ///save dummy quiz from JSON to realm
            JSONManager.shared.getAllQuizzesFromAPIs { quizzes in
                DatabaseManager.shared.storeJSONParsedQuiz(with: quizzes)
                self.quizSources = self.quizes
                
                /// initializing answerFlipped false for each quiz
                for _ in self.quizSources{
                    AppState.shared.answerViewDisplayed.append(false)
                }
                self.tableView.reloadData()
               // self.tableView.isHidden = self.quizSources.isEmpty ? true : false
               // self.emptyQuizLabel.isHidden = self.quizSources.isEmpty ? false : true
                
            }
        } else{
            /// fetch data from realm
            self.quizSources = self.quizes
            self.tableView.reloadData()
            self.tableView.isHidden = self.quizSources.isEmpty ? true : false
            self.emptyQuizLabel.isHidden = self.quizSources.isEmpty ? false : true
            
        }
        
    }
    
    private func configureNavigationBar(){
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = "Quizzes"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                 target: self,
                                                                 action: #selector(addButtonTapped))
    }
    // long press to delete a note by its id provided
//    @objc func handleLongPressed(sender: UILongPressGestureRecognizer){
//        if sender.state == .began{
//            let touchPoint = sender.location(in: self.tableView)
//            if var indexRow = tableView.indexPathForRow(at: touchPoint)?.row{
//                let alert = UIAlertController(title: "Attention",
//                                              message: "Do you want to delete the note?",
//                                              preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "Confirm",
//                                             style: .default) { action in
//                    let note = self.realm.objects(Note.self).filter("id == %d", indexRow)[0]
//                    let nextNotes = self.realm.objects(Note.self).filter("id > %d", indexRow)
//                    do{
//                        try self.realm.write {
//                            self.realm.delete(note)
//                            for note in nextNotes{
//                                note.id = indexRow
//                                indexRow += 1
//                            }
//                            self.realm.add(nextNotes)
//
//                        }
//                    }catch{
//                        print(error.localizedDescription)
//                    }
//                    self.displayAlert(title: nil, message: "Deleted Successfully")
//                }
//
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                alert.addAction(okAction)
//                alert.addAction(cancelAction)
//                self.present(alert, animated: true, completion: nil)
//            }
//
//        }
//    }
    
    func displayAlert(title: String?, message: String?){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self.dismiss(animated: true) {
                    self.quizSources  = self.quizes
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
