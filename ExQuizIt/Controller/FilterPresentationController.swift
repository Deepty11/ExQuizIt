//
//  FilterPresentationController.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 3/7/22.
//

import UIKit

class FilterPresentationController: UIPresentationController {
    var blurEffectView: UIVisualEffectView!
    
    init(presentedViewController: UIViewController!,
         presenting presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        
        configureBlurEffectView()
        
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height * 0.65),
               size: CGSize(width: self.containerView!.frame.width,
                            height: self.containerView!.frame.height * 0.35))
    }
    
    override func presentationTransitionWillBegin() {
        blurEffectView.alpha = 0
        containerView?.addSubview(blurEffectView)
        presentedViewController
            .transitionCoordinator?
            .animate(alongsideTransition: {
                [weak self] (UIViewControllerTransitionCoordinatorContext)  in
                self?.blurEffectView.alpha = 1
            })
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController
            .transitionCoordinator?
            .animate(alongsideTransition: {
                [weak self] (UIViewControllerTransitionCoordinatorContext) in
            self?.blurEffectView.alpha = 0
        }, completion: {[weak self] (UIViewControllerTransitionCoordinatorContext) in
            self?.blurEffectView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView?.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView?.bounds ?? CGRect()
    }
    
    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.isUserInteractionEnabled = true
        
        blurEffectView.addGestureRecognizer(
            UITapGestureRecognizer(target: self,
                                   action: #selector(dissmissController)))
    }
    
    @objc func dissmissController(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
}
