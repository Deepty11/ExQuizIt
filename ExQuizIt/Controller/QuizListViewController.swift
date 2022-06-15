//
//  QuizListViewController.swift
//  ExQuizit
//
//  Created by Rehnuma Reza on 5/4/22.
//

import UIKit
import RealmSwift

protocol CellButtonInteractionDelegate {
    func handleUnCommonQuizButtonEvent(cell: UITableViewCell)
    func handleCommonQuizButtonEvent(cell: UITableViewCell)
}

class QuizListViewController: UIViewController {
    @IBOutlet weak var emptyQuizLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var quizLoadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedValueForPracticeQuizLabel: UILabel!
    @IBOutlet weak var practiceQuizStepper: UIStepper!
    @IBOutlet weak var saveSettingsButton: UIButton!
    @IBOutlet weak var practiceButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var visualEffectView: UIVisualEffectView!
    var originYOfSettingsView = 0.0
    var answerViewDisplayed : [Bool] = []
    var isSettingsViewVisible = false
    var selectedValueForPracticeQuizzes = 0
    
    let practiceSessionUtilityService = PracticeSessionUtilityService()
    let databaseManager = DatabaseManager()
    let apiManager = APIManager()
    
    var quizSources = [Quiz]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                guard let self = self else { return }
                self.tableView?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoading()
        
        configureNavigationBar()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        configurePracticeQuizStepper()
        
        saveSettingsButton.layer.cornerRadius = 5.0
        
        practiceButton.isUserInteractionEnabled = true
        practiceButton.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(handlePracticeButtonTapped)
        ))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchQuizzes()
        
    }
    
    @IBAction func handlePracticeButtonTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: String(describing: PracticeListViewController.self))
            as? PracticeListViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func configurePracticeQuizStepper() {
        practiceQuizStepper.layer.cornerRadius = 5.0
        practiceQuizStepper.setIncrementImage(UIImage(named: "AddIcon"), for: .normal)
        practiceQuizStepper.setDecrementImage(UIImage(named: "MinusIcon"), for: .normal)
    
        let currentValue = practiceSessionUtilityService.getPreferredNumberOfPracticeQuizzes()
        practiceQuizStepper.value = currentValue > 0
            ? Double(currentValue)
            : Double(Constants.DefaultNumberOfPracticeQuizzes)
        
        selectedValueForPracticeQuizzes = Int(practiceQuizStepper.value)
        selectedValueForPracticeQuizLabel.text = String(selectedValueForPracticeQuizzes)
        
    }
    
    private func fetchQuizzes() {
        guard databaseManager.getAllQuizzes().isEmpty else {
            refreshUI()
            return
        }
        
        showLoading(true)
        
        apiManager.saveAllQuizzesToDatabase { [weak self]  in
            guard let self = self else { return }
            
            self.showLoading(false)
            self.refreshUI()
        }
    }
    
    private func setupLoading() {
        addVisualEffectSubview()
        emptyQuizLabel.text = "Loading ..."
        view.bringSubviewToFront(quizLoadingActivityIndicatorView)
        quizLoadingActivityIndicatorView.color = .white
        
        showLoading(false)
    }
    
    private func showLoading(_ shouldShow: Bool) {
        // True
        visualEffectView.isHidden = !shouldShow
        quizLoadingActivityIndicatorView.isHidden = !shouldShow
        navigationController?.navigationBar.isUserInteractionEnabled = !shouldShow
        
        if shouldShow {
            quizLoadingActivityIndicatorView.startAnimating()
        } else {
            quizLoadingActivityIndicatorView.stopAnimating()
        }
    }
    
    private func initiateAnswerViewDisplayedArray() {
        quizSources = databaseManager.getAllQuizzes()
        answerViewDisplayed = Array(repeating: false, count: quizSources.count)
    }
    
    private func refreshUI() {
        initiateAnswerViewDisplayedArray()
        
        tableView.reloadData()
        tableView.isHidden = quizSources.isEmpty
        emptyQuizLabel.isHidden = !quizSources.isEmpty
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Quizzes"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleAddButtonTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "SettingsIcon"),
            style: .plain,
            target: self,
            action: #selector(handleSettingsButtonTapped)
        )
    }

    @IBAction private func handleSaveButtonTapped(_ sender: Any) {
        storeNumberOfPracticeQuizzes()
        hideSettingsView()
    }
                                                            
    @objc private func handleViewDidTapped(_ sender: UITapGestureRecognizer) {
        hideSettingsView()
    }
    
    @objc private func handleAddButtonTapped() {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: String(describing: AddQuizViewController.self)) as? AddQuizViewController {
            isSettingsViewVisible = false
            hideSettingsView()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func handleSettingsButtonTapped() {
        isSettingsViewVisible ? hideSettingsView() : showSettingsView()
    }
    
    private func storeNumberOfPracticeQuizzes() {
        UserDefaults.standard.set(selectedValueForPracticeQuizzes,
                                  forKey: Strings.NumberOfPracticeQuizzes)
    }
    
    private func addVisualEffectSubview() {
        let blurrEffect = UIBlurEffect(style: .dark)
        visualEffectView = UIVisualEffectView(effect: blurrEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0)
        ])
        
        self.visualEffectView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleViewDidTapped(_:))))
        visualEffectView.isHidden = true
    }
    
    // MARK: - Private Utils
    
    fileprivate func deleteQuiz(atIndexPath indexPath: IndexPath) {
        tableView.beginUpdates()
        
        self.showAlert(title: "Attention",
                       message: "Are you sure you want to delete this quiz?",
                       cancelTitle: "Cancel") { [weak self] in
            guard let self = self else { return }
            
            self.databaseManager.deleteQuiz(quiz: self.quizSources[indexPath.row])
            
            self.showToast(title: nil, message: "Deleted Successfully") {
                self.quizSources  = self.databaseManager.getAllQuizzes()
                
                if self.quizSources.isEmpty {
                    self.tableView.isHidden = true
                    self.emptyQuizLabel.isHidden = false
                }
            }
        }
        
        tableView.endUpdates()
    }
    
    fileprivate func editQuiz(atIndexPath indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(
            withIdentifier: String(describing: AddQuizViewController.self)) as? AddQuizViewController {
            vc.storeType = .update
            vc.quiz = self.quizSources[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}

//MARK: - Settings View
extension QuizListViewController {
    func showSettingsView() {
        settingsView.backgroundColor = .black
        settingsView.alpha = 0.80
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.visualEffectView.isHidden = false
            self.originYOfSettingsView = self.settingsView.frame.origin.y
            self.settingsView.frame.origin.y = self.view.frame.height - self.settingsView.frame.height
            self.settingsViewBottomConstraint.constant = -self.settingsView.frame.height
            self.isSettingsViewVisible = true
            self.view.bringSubviewToFront(self.settingsView)
        }
    }
    
    func hideSettingsView() {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            
            self.settingsView.frame.origin.y = self.originYOfSettingsView
            self.settingsViewBottomConstraint.constant = 0
            self.visualEffectView.isHidden = true
        }
        
        isSettingsViewVisible = false
        storeNumberOfPracticeQuizzes()
    }
    
    @IBAction func handleStepperTapped(_ sender: Any) {
        if let sender = sender as? UIStepper {
            selectedValueForPracticeQuizLabel.text = String(Int(sender.value))
            selectedValueForPracticeQuizzes = Int(sender.value)
        }
    }
}

//MARK: -TableView Delegate and DataSource
extension QuizListViewController: UITableViewDelegate, UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizSources.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: QuizTableViewCell.self),
                                                    for: indexPath) as? QuizTableViewCell {
            let quiz = quizSources[indexPath.row]
            
            cell.questionLabel.text = quiz.question
            cell.answerLabel.text = quiz.correct_answer
            cell.appearedInPracticeLabel.text = Strings.AppearedInPracticeString
                + String(quiz.numberOfTimesAppeared ?? Constants.DefaultNumberOfTimesAppeared)
            cell.lastUpdateLabel.text = Strings.LastUpdateString
                + (quiz.latestTimeAppeared ?? Strings.DefaultAppearedInPracticeString)
            
            let isAnswerDisplayed = answerViewDisplayed[indexPath.row]
            cell.questionView.isHidden = isAnswerDisplayed
            cell.answerView.isHidden = !isAnswerDisplayed
            cell.learningView.isHidden = quiz.isKnown
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    internal func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] _, indexPath in
            self?.deleteQuiz(atIndexPath: indexPath)
        }
        deleteAction.backgroundColor = .red
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] _, indexPath in
            self?.editQuiz(atIndexPath: indexPath)
        }
        editAction.backgroundColor = .green
        
        return [deleteAction, editAction]
    }
    
    //selecting on cell will flip the view
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        if let cell =  tableView.cellForRow(at: indexPath) as? QuizTableViewCell {
            let quiz = quizSources[indexPath.row]
            cell.learningView.isHidden = quiz.isKnown
            
            if !answerViewDisplayed[indexPath.row] {
                flipCard(from: cell.questionView, to: cell.answerView)
            } else {
                flipCard(from: cell.answerView, to: cell.questionView)
            }
            
            answerViewDisplayed[indexPath.row] = !answerViewDisplayed[indexPath.row]
        }
        
        tableView.endUpdates()
        
    }
}

//MARK: - Searchbar delegates
extension QuizListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //
    }
}
