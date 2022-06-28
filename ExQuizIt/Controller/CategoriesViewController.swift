//
//  CategoriesViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 23/6/22.
//

import UIKit

enum ActionType: String {
    case edit = "Edit"
    case add = "Add new"
}

class CategoriesViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyQuizLabel: UILabel!
    @IBOutlet weak var quizLoadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableViewBottomConstraints: NSLayoutConstraint!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedValueForPracticeQuizLabel: UILabel!
    @IBOutlet weak var practiceQuizStepper: UIStepper!
    @IBOutlet weak var saveSettingsButton: UIButton!
    
    var visualEffectView: UIVisualEffectView!
    var originYOfSettingsView = 0.0
    var isSettingsViewVisible = false
    var selectedValueForPracticeQuizzes = 0
    
    var contentType = ContentType.categories
    var categories: [Category] = []
    let apiManager = APIManager()
    let databaseManager = DatabaseManager()
    let practiceSessionUtilityService = PracticeSessionUtilityService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveSettingsButton.layer.cornerRadius = 5.0
        searchBar.showsCancelButton = false
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        setupLoading()
        configureNavigationBar()
        configurePracticeQuizStepper()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                         action: #selector(handleViewDidTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCategories()
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
    
    private func fetchCategories() {
        guard databaseManager.getAllQuizzes().isEmpty else {
            categories = databaseManager.getAllQuizCategories()
            refreshUI()
            return
        }
        
        showLoading(true)
        
        apiManager.getQuizzesFromAPI { [weak self] quizzes in
            guard let self = self else { return }
            
            self.databaseManager.storeQuizzes(quizzes)
            self.databaseManager.storeCategories()
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
        getInputAndUpdateCategory()
        
    }
    
    @objc private func handleSettingsButtonTapped() {
        isSettingsViewVisible ? hideSettingsView() : showSettingsView()
    }
    
    @objc private func handleViewDidTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func handleCategorySelected(_ sender: UITapGestureRecognizer) {
        if let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)) {
            if let vc = storyboard?.instantiateViewController(
                withIdentifier: String(describing: QuizListViewController.self))
                as? QuizListViewController {
                vc.selectedCategory = categories[indexPath.row].name ?? ""
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func handleStepperTapped(_ sender: Any) {
        if let sender = sender as? UIStepper {
            selectedValueForPracticeQuizLabel.text = String(Int(sender.value))
            selectedValueForPracticeQuizzes = Int(sender.value)
        }
    }
    
    @IBAction private func handleSaveButtonTapped(_ sender: Any) {
        storeNumberOfPracticeQuizzes()
        hideSettingsView()
    }
    
    // MARK: - Edit and delete Utils
    fileprivate func deleteQuiz(atIndexPath indexPath: IndexPath) {
        tableView.beginUpdates()
        
        self.showAlert(title: "Attention",
                       message: "Are you sure you want to delete this quiz?",
                       cancelTitle: "Cancel") { [weak self] _ in
            guard let self = self else { return }
            
            self.databaseManager.deleteCategory(by: self.categories[indexPath.row].id ?? "")
            
            self.showToast(title: nil, message: "Deleted Successfully") {
                self.fetchCategories()
            }
        }
        
        tableView.endUpdates()
    }
    
    fileprivate func editQuiz(atIndexPath indexPath: IndexPath) {
        getInputAndUpdateCategory(selectedCategory: categories[indexPath.row])
        fetchCategories()
    }
    
    func getInputAndUpdateCategory(selectedCategory: Category? = nil) {
        let action = selectedCategory != nil
            ? ActionType.edit.rawValue
            : ActionType.add.rawValue
        
        let placeHolder = selectedCategory != nil ? selectedCategory?.name : ""
        
        showAlert(title: "\(action) category",
                  message: "Please enter category name",
                  placeHolder: placeHolder,
                  okTitle: "Confirm",
                  cancelTitle: "Cancel") { [weak self] categoryName in
            guard let self = self else { return }
            
            guard let categoryName = categoryName else { return }
            
            if categoryName != selectedCategory?.name
                && !self.databaseManager.getAllQuizCategories(by: categoryName).isEmpty {
                self.showAlert(title: "Attention",
                          message: "\(categoryName) already exists",
                          okTitle: "Ok")
            } else {
                //edit or add
                //let categoryFound = self.databaseManager.getAllQuizCategories(by: selectedCategory).first
                var category = selectedCategory
                category?.name = categoryName
                self.databaseManager.saveCategory(category ?? Category(name: categoryName))
            }
            
            self.fetchCategories()
        }
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
            cell.categoryLabel.text = categories[indexPath.row].name
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
            vc.selectedCategory = categories[indexPath.row].name ?? ""
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Searchbar delegates
extension CategoriesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        categories = searchText.isEmpty
            ? databaseManager.getAllQuizCategories()
            : databaseManager.getFilteredCategories(by: searchText)
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
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

//MARK: - Settings View
extension CategoriesViewController {
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
    
    private func storeNumberOfPracticeQuizzes() {
        UserDefaults.standard.set(selectedValueForPracticeQuizzes,
                                  forKey: Strings.NumberOfPracticeQuizzes)
    }
    
    
    
    
    
    
    
}

