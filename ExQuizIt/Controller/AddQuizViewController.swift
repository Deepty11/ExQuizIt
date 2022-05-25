//
//  AddQuizViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 5/4/22.
//

import UIKit
import RealmSwift

enum InputType: String, CaseIterable {
    case question = "Question"
    case answer = "Answer"
}

enum StoreType: String {
    case update = "Edited"
    case create = "Saved"
}

protocol CellInteractionDelegte {
    func textViewDidBeginEditing(cell: UITableViewCell)
    func textViewDidChanged(cell: UITableViewCell)
}

class AddQuizViewController: UIViewController,
                             UIScrollViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var questionText = ""
    var answerText = ""
    var storeType = StoreType.create
    var quiz = QuizModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.questionText = self.quiz.question ?? ""
        self.answerText = self.quiz.answer ?? ""
        
        self.view.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(handleTableViewTapped)))
    
    }
    
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = "Add Quiz"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(handleSaveButtonTapped))
    }
    
    @objc private func handleTableViewTapped(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @objc private func keyBoardWillShow(notification: Notification) {
        if let keyBoardFrameInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyBoardFrameInfo.cgRectValue.height
            self.tableViewBottomConstraint.constant = keyboardHeight
        }
    }
    
    @objc private func keyBoardWillHide(notification: Notification) {
        if let _ = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.tableViewBottomConstraint.constant = 0
        }
    }
    
    @objc private func handleSaveButtonTapped() {
        if questionText.isVisuallyEmpty || answerText.isVisuallyEmpty {
            showAlert(title: "Attention", message: "Unable to save if any field is empty")
            return
        }
        
        switch(storeType) {
        case .update:
            let previousQuiz = DatabaseManager.shared.getQuizBy(id: quiz.id)
            DatabaseManager.shared.saveQuiz(quiz: previousQuiz, question: questionText, answer: answerText)
        case .create:
            let quiz = QuizModel()
            DatabaseManager.shared.saveQuiz(quiz: quiz, question: questionText, answer: answerText)
            
        }
        
        showToast(title: nil, message: storeType.rawValue) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
}

//MARK: -TableView Delegate and DataSource
extension AddQuizViewController: UITableViewDelegate, UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return getCell(for: indexPath, inputType: .question)
        }
        
        return getCell(for: indexPath, inputType: .answer)
    }
    
    private func getCell(for indexPath: IndexPath, inputType: InputType) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddQuizTableViewCell.self), for: indexPath) as? AddQuizTableViewCell {
            cell.inputType = inputType
            cell.quizTextView.text = inputType == .question ? quiz.question : quiz.answer
            cell.configureCell()
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
}
//MARK: - CellInteractionDelegte
extension AddQuizViewController: CellInteractionDelegte {
    internal func textViewDidBeginEditing(cell: UITableViewCell) {
        if let row = tableView.indexPath(for: cell) {
            tableView.scrollToRow(at: row, at: .top, animated: true)
        }
    }
    
    internal func textViewDidChanged(cell: UITableViewCell) {
        if let indexPath = tableView.indexPath(for: cell),
           let cell = cell as? AddQuizTableViewCell {
            let text = cell.quizTextView.text
            
            if indexPath.row == 0 {
                questionText = text ?? ""
            } else {
                answerText = text ??  ""
            }
        }
    }
}

