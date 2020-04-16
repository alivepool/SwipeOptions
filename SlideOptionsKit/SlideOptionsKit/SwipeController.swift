//
//  SwipeController.swift
//  SlideOptions
//
//  Created by Ameya on 16/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

public enum OptionsSide {
    case left, right
}

private enum SwipeActionsViewMode {
    case none, left, right
}

public protocol SwipableView {
    
}

public struct SwipeActionConfiguration {
    // Unique Identifier
    public var identifier: String?
    public var title: String?
    public var backgroundColor: UIColor = .white
    public var image: UIImage?
    public var handler: ((SwipeActionConfiguration, IndexPath) -> Void)?
    
    public init() {}
}

public protocol SwipeActionsProvider: AnyObject {
    func swipeConfiguration() -> [SwipeActionConfiguration]?
    func actionHandler(configuration: SwipeActionConfiguration)
}

public protocol SwipeControllerType {
    var containerView: UIView { get }
    var swipeView: UIView { get }
    var actionsProvider: SwipeActionsProvider? { get set }
    
    init(containerView: UIView, swipeView: UIView)
    
    func showActions(_ mode: OptionsSide?)
    func hideActions()
    
}

public class SwipeController: SwipeControllerType {
    
    private (set) public var containerView: UIView
    private (set) public var swipeView: UIView
    public var actionsProvider: SwipeActionsProvider?
    
    private var actionsContainerView = UIView()
    private var actionsStackView = UIStackView()
    
    private var orignalLocation = CGPoint.zero
    private var orignalContentLocationX: CGFloat = 0
    
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadConstraint: NSLayoutConstraint!
    private var trailConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
    private var swipeActionsViewMode = SwipeActionsViewMode.none
    
    private var actionButtons: [UIButton]?
    private var actionConfigurations: [SwipeActionConfiguration]?
    
    required public init(containerView: UIView, swipeView: UIView) {
        self.containerView = containerView
        self.swipeView = swipeView
        configureUI()
        setupViewConstraints()
        setupGestureRecognizers()
    }
    
    private func configureUI() {
        orignalContentLocationX = swipeView.frame.origin.x
        actionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        actionsContainerView.backgroundColor = .red
        containerView.insertSubview(actionsContainerView, belowSubview: swipeView)
        
        actionsStackView.axis = .vertical
        actionsStackView.alignment = .fill
        actionsStackView.distribution = .fill
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsContainerView.addSubview(actionsStackView)
    }
    
    private func setupViewConstraints() {
        // actionsContainerView constraints
        topConstraint = actionsContainerView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor)
        bottomConstraint = actionsContainerView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
        leadConstraint = actionsContainerView.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor)
        trailConstraint = actionsContainerView.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)
        widthConstraint = actionsContainerView.widthAnchor.constraint(equalToConstant: 120)
        
        
        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            trailConstraint,
//            widthConstraint,
            
            actionsStackView.centerYAnchor.constraint(equalTo: actionsContainerView.centerYAnchor),
            actionsStackView.centerXAnchor.constraint(equalTo: actionsContainerView.centerXAnchor),
            actionsStackView.leadingAnchor.constraint(equalTo: actionsContainerView.leadingAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: actionsContainerView.trailingAnchor),
        ])
    }
    
    private func setupGestureRecognizers() {
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gestureRecognizer:))))
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:))))
    }
    
    private func configureActionButtons() {
        actionConfigurations = actionsProvider?.swipeConfiguration()
        actionButtons = createActionButtons(configurations: actionConfigurations)
        guard let ab = actionButtons, ab.count > 0 else {
            return
        }
        actionsStackView.removeAllArrangedSubviews()
        ab.forEach { button in
            actionsStackView.addArrangedSubview(button)
        }
    }
    
    private func createActionButtons(configurations: [SwipeActionConfiguration]?) -> [UIButton] {
        var customActionButtons: [UIButton] = []
        configurations?.forEach{ config in
            let button = UIButton(type: .custom)
            button.setTitle(config.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = config.backgroundColor
            if let image = config.image {
                button.leftImage(image: image, renderMode: .automatic)
            }
            button.addTarget(self, action: #selector(buttonHandler(sender:)), for: .touchUpInside)
            customActionButtons.append(button)
        }
        return customActionButtons
    }
    
    @objc func buttonHandler(sender: UIButton) {
        let index = actionButtons?.firstIndex(of: sender)
        guard let buttonIndex = index, let configuration = actionConfigurations?[buttonIndex]  else { return }
        actionsProvider?.actionHandler(configuration: configuration)
    }
    
    @objc func panGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        
        let velocity = gestureRecognizer.velocity(in: actionsContainerView)
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
            if actionConfigurations?.isEmpty ?? true || actionButtons?.isEmpty ?? true {
                configureActionButtons()
            }
        case .changed :
            
            let newX = gestureRecognizer.translation(in: containerView).x
            var cvFrame = swipeView.frame
            cvFrame.origin.x = newX + orignalLocation.x
            if abs(cvFrame.origin.x) < actionsContainerView.frame.size.width {
                swipeView.frame = cvFrame
            }
            
            
            
        case .ended, .cancelled, .failed:
            
            var cvFrame = swipeView.frame
            if abs(swipeView.frame.origin.x) < actionsContainerView.frame.size.width/2.5 {
                cvFrame.origin.x = orignalContentLocationX
                swipeActionsViewMode = .none
                UIView.animate(withDuration: 0.18) {
                    
                    
                }
                
                UIView.animate(
                withDuration: 0.18,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    self?.swipeView.frame = cvFrame
                    
                },
                completion: { [weak self] finished in
                    self?.actionsStackView.removeAllArrangedSubviews()
                    self?.actionConfigurations?.removeAll()
                    self?.actionButtons?.removeAll()
                })
            }
            else {
                let width = swipeActionsViewMode == .left ? actionsContainerView.frame.size.width : -actionsContainerView.frame.size.width
                cvFrame.origin.x = width
                UIView.animate(
                withDuration: 0.18,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    self?.swipeView.frame = cvFrame
                    
                })
            }
            
        default:
            break
        }
    }

    
    @objc func tapGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        swipeActionsViewMode = .none
        var cvFrame = swipeView.frame
        cvFrame.origin.x = orignalContentLocationX
        UIView.animate(withDuration: 0.18) { [weak self] in
            self?.swipeView.frame = cvFrame
        }
    }
    
    public func showActions(_ mode: OptionsSide? = .right) {
        
    }
    
    public func hideActions() {
        
    }
    
}
