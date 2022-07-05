//
//  SettingsViewController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 4/7/22.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var practiceQuizSelectionStepper: UIStepper!
    @IBOutlet weak var selectedPreferredNumberLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    var selectedValueForPracticeQuizzes = 0
    let practiceSessionUtilityService = PracticeSessionUtilityService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePracticeQuizStepper()
        saveButton.layer.cornerRadius = 5
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self,
                                   action: #selector(handlePanGestureRecognizerAction)))
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = view.frame.origin
        }
    }
    
    private func configurePracticeQuizStepper() {
        practiceQuizSelectionStepper.layer.cornerRadius = 5.0
        practiceQuizSelectionStepper.setIncrementImage(UIImage(named: "AddIcon"), for: .normal)
        practiceQuizSelectionStepper.setDecrementImage(UIImage(named: "MinusIcon"), for: .normal)
    
        let currentValue = practiceSessionUtilityService.getPreferredNumberOfPracticeQuizzes()
                practiceQuizSelectionStepper.value = currentValue > 0
            ? Double(currentValue)
            : Double(Constants.DefaultNumberOfPracticeQuizzes)
        
        selectedValueForPracticeQuizzes = Int(practiceQuizSelectionStepper.value)
        selectedPreferredNumberLabel.text = String(selectedValueForPracticeQuizzes)
    }
    
    @objc func handlePanGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }

        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: (pointOrigin?.y ?? CGFloat()) + translation.y)

        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                // Velocity fast enough to dismiss the uiview
                dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.view.frame.origin = self?.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    @IBAction func handleStepperTapped(_ sender: Any) {
        if let sender = sender as? UIStepper {
            selectedPreferredNumberLabel.text = String(Int(sender.value))
            selectedValueForPracticeQuizzes = Int(sender.value)
        }
    }
    
    @IBAction func handleSaveButtonTapped(_ sender: Any) {
        storeNumberOfPracticeQuizzes()
        dismiss(animated: true)
    }
    
    private func storeNumberOfPracticeQuizzes() {
        UserDefaults.standard.set(selectedValueForPracticeQuizzes,
                                  forKey: Strings.NumberOfPracticeQuizzes)
    }
    
}
