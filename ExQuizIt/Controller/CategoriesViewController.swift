//
//  CategoriesViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 23/6/22.
//

import UIKit

class CategoriesViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyQuizLabel: UILabel!
    @IBOutlet weak var quizLoadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableViewBottomConstraints: NSLayoutConstraint!
    
    var visualEffectView: UIVisualEffectView!
    var originYOfSettingsView = 0.0
    var isSettingsViewVisible = false
    var selectedValueForPracticeQuizzes = 0
    
    var contentType = ContentType.categories
    var categories: [String] = []
    let apiManager = APIManager()
    let databaseManager = DatabaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        setupLoading()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchQuizzes()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = contentType.rawValue
        
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
    
//    func setViewSources() {
//        categories = databaseManager.getAllQuizCategories()
//    }
    
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
    
    private func refreshUI() {
        tableView.reloadData()
        tableView.isHidden = categories.isEmpty
        emptyQuizLabel.isHidden = !categories.isEmpty
    }
    
    private func fetchQuizzes() {
        guard databaseManager.getAllQuizzes().isEmpty else {
            categories = databaseManager.getAllQuizCategories()
            refreshUI()
            return
        }
        
        showLoading(true)
        
        apiManager.getQuizzesFromAPI { [weak self] quizzes in
            guard let self = self else { return }
            
            self.databaseManager.storeQuizzes(quizzes)
            self.categories = self.databaseManager.getAllQuizCategories()
            self.showLoading(false)
            self.refreshUI()
        }
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
    
    @objc private func handleAddButtonTapped() {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: String(describing: AddQuizViewController.self)) as? AddQuizViewController {
            isSettingsViewVisible = false
            
            //hideSettingsView()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func handleSettingsButtonTapped() {
        //isSettingsViewVisible ? hideSettingsView() : showSettingsView()
    }
    
    @objc private func handleViewDidTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func handleCategorySelected(_ sender: UITapGestureRecognizer) {
        if let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)) {
            if let vc = storyboard?.instantiateViewController(
                withIdentifier: String(describing: QuizListViewController.self))
                as? QuizListViewController {
                vc.selectedCategory = categories[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Edit and delete Utils
    fileprivate func deleteQuiz(atIndexPath indexPath: IndexPath) {
        tableView.beginUpdates()
        
        self.showAlert(title: "Attention",
                       message: "Are you sure you want to delete this quiz?",
                       cancelTitle: "Cancel") { [weak self] _ in
            guard let self = self else { return }
            
            self.databaseManager.deleteQuiz(by: self.categories[indexPath.row])
            
            self.showToast(title: nil, message: "Deleted Successfully") {
                self.categories  = self.databaseManager.getAllQuizCategories()
                
                if self.categories.isEmpty {
                    self.tableView.isHidden = true
                    self.emptyQuizLabel.isHidden = false
                }
            }
        }
        
        tableView.endUpdates()
    }
    
    fileprivate func editQuiz(atIndexPath indexPath: IndexPath) {
        showAlert(title: "Edit",
                  message: "Please enter category name",
                  placeHolder: categories[indexPath.row],
                  okTitle: "Confirm",
                  cancelTitle: "Cancel") { [weak self] category in
            guard let self = self else { return }
            
            guard let category = category else { return }
            
            if self.databaseManager.getAllQuizCategories().contains(category)
                && category != self.categories[indexPath.row] {
                
            }
        }
//        if let vc = self.storyboard?.instantiateViewController(
//            withIdentifier: String(describing: AddQuizViewController.self)) as? AddQuizViewController {
//            vc.storeType = .update
//            vc.selectedCategory = quizSources[indexPath.row].category ?? ""
//            vc.quiz = quizSources[indexPath.row]
//            navigationController?.pushViewController(vc, animated: true)
//
//        }
    }

}


//MARK: -TableView Delegate and DataSource
extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CategoryTableViewCell.self),
                                                    for: indexPath) as? CategoryTableViewCell {
            cell.categoryLabel.text = categories[indexPath.row]
            cell.cellView.addGestureRecognizer(
                UITapGestureRecognizer(target: self,
                                       action: #selector(handleCategorySelected)))
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(
            withIdentifier: String(describing: QuizListViewController.self))
            as? QuizListViewController {
            vc.selectedCategory = categories[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Searchbar delegates
extension CategoriesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        categories = searchText.isEmpty
            ? databaseManager.getAllQuizCategories()
            : databaseManager.getFilteredCategories(by: searchText)
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        categories = databaseManager.getAllQuizCategories()
        
        view.endEditing(true)
        tableView.reloadData()
    }
}

//MARK: - Keyboard hide/show notification
extension CategoriesViewController {
    @objc private func keyBoardWillShow(notification: Notification) {
        if let keyBoardFrameInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyBoardFrameInfo.cgRectValue.height
            tableViewBottomConstraints.constant = keyboardHeight
        }
    }
    
    @objc private func keyBoardWillHide(notification: Notification) {
        if let _ = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            tableViewBottomConstraints.constant = 0
        }
    }
}

