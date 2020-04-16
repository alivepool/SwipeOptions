//
//  SwipeController.swift
//  SlideOptions
//
//  Created by Ameya on 16/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

enum OptionsSide {
    case left, right
}

private enum SwipeActionsViewMode {
    case none, left, right
}

protocol SwipableView {
    
}

struct SwipeActionConfiguration {
    // Unique Identifier
    var identifier: String?
    var title: String?
    var backgroundColor: UIColor = .red
    var image: UIImage?
    var handler: ((SwipeActionConfiguration, IndexPath) -> Void)?
}

protocol SwipeActionsProvider: AnyObject {
    func tableView(_ collectionView: UICollectionView,
    swipeActionConfigurationForRowAt indexPath: IndexPath) -> [SwipeActionConfiguration]?
}

protocol SwipeControllerType {
    var containerView: UIView { get }
    var swipeView: UIView { get }
    var actionsProvider: SwipeActionsProvider? { get set }
    
    init(containerView: UIView, swipeView: UIView)
    
    func showActions(_ mode: OptionsSide?)
    func hideActions()
    
}

class SwipeController: SwipeControllerType {
    
    private (set) var containerView: UIView
    private (set) var swipeView: UIView
    var actionsProvider: SwipeActionsProvider?
    
    private var actionsView = UIView()
    
    private var orignalLocation = CGPoint.zero
    private var orignalContentLocationX: CGFloat = 0
    
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadConstraint: NSLayoutConstraint!
    private var trailConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
    private var swipeActionsViewMode = SwipeActionsViewMode.none
    
    required init(containerView: UIView, swipeView: UIView) {
        self.containerView = containerView
        self.swipeView = swipeView
        
        orignalContentLocationX = swipeView.frame.origin.x
        
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.backgroundColor = .red
        containerView.insertSubview(actionsView, belowSubview: swipeView)
        
        
        topConstraint = actionsView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor)
        bottomConstraint = actionsView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
        leadConstraint = actionsView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor)
        trailConstraint = actionsView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)
        widthConstraint = actionsView.widthAnchor.constraint(equalToConstant: 120)
        
        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            trailConstraint,
            widthConstraint
        ])
        
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gestureRecognizer:))))
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:))))
        
    }
    
    
    @objc func panGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        
        let velocity = gestureRecognizer.velocity(in: actionsView)
        if velocity.x > 0 { // Left
            
            if swipeActionsViewMode == .none {
                swipeActionsViewMode = .left
            }
            
            
            if swipeView.frame.origin.x > orignalContentLocationX {
                if trailConstraint.isActive {
                    NSLayoutConstraint.deactivate([trailConstraint])
                    NSLayoutConstraint.activate([leadConstraint])
                    swipeActionsViewMode = .left
                }
            }
        }
        else if velocity.x < 0 { //right
            
            if swipeActionsViewMode == .none {
                swipeActionsViewMode = .right
            }
            
            if swipeView.frame.origin.x < orignalContentLocationX {
                if leadConstraint.isActive {
                    NSLayoutConstraint.deactivate([leadConstraint])
                    NSLayoutConstraint.activate([trailConstraint])
                    swipeActionsViewMode = .right
                }
            }
        }
        
        
        switch gestureRecognizer.state {
        case .began:
            orignalLocation =  swipeView.frame.origin
        case .changed :
            
            let newX = gestureRecognizer.translation(in: containerView).x
            var cvFrame = swipeView.frame
            cvFrame.origin.x = newX + orignalLocation.x
            if abs(cvFrame.origin.x) < actionsView.frame.size.width {
                swipeView.frame = cvFrame
            }
                
            
            
        case .ended, .cancelled, .failed:
            
            var cvFrame = swipeView.frame
            if abs(swipeView.frame.origin.x) < actionsView.frame.size.width/2.5 {
                    cvFrame.origin.x = orignalContentLocationX
                }
                else {
                    let width = swipeActionsViewMode == .left ? actionsView.frame.size.width : -actionsView.frame.size.width
                    cvFrame.origin.x = width
                }
            
            UIView.animate(withDuration: 0.18) {
                self.swipeView.frame = cvFrame
            }
            
        default:
            break
        }
    }
    
    @objc func tapGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        swipeActionsViewMode = .none
        var cvFrame = swipeView.frame
        cvFrame.origin.x = orignalContentLocationX
        UIView.animate(withDuration: 0.18) {
            self.swipeView.frame = cvFrame
        }
    }
    
    func showActions(_ mode: OptionsSide? = .right) {
        
    }
    
    func hideActions() {
        
    }
    
}
