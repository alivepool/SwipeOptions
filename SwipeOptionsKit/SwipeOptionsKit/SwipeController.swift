//
//  SwipeController.swift
//  SwipeOptions
//
//  Created by Ameya on 16/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

public enum SwipeActionsViewMode {
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
    var actionsState: SwipeActionsViewMode { get set }
    
    func swipeConfiguration() -> [SwipeActionConfiguration]?
    func actionHandler(configuration: SwipeActionConfiguration)
}

public protocol SwipeControllerType {
    var containerView: UIView { get }
    var swipeView: UIView { get }
    var actionsProvider: SwipeActionsProvider? { get set }
    
    init(containerView: UIView, swipeView: UIView)
    
    func showActions(animated: Bool, mode: SwipeActionsViewMode, completion:(()->Void)?)
    func hideActions(animated: Bool)
    
}

public class SwipeController: NSObject, SwipeControllerType {
    
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
    
    lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gestureRecognizer:)))
        gesture.delegate = self
        return gesture
    }()
    
    lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:)))
        gesture.delegate = self
        return gesture
    }()
    
    required public init(containerView: UIView, swipeView: UIView) {
        self.containerView = containerView
        self.swipeView = swipeView
        super.init()
        configureUI()
        setupViewConstraints()
        setupGestureRecognizers()
    }
    
    private func configureUI() {
        orignalContentLocationX = swipeView.frame.origin.x
        actionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        actionsContainerView.backgroundColor = .white
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
        containerView.addGestureRecognizer(panGestureRecognizer)
        containerView.addGestureRecognizer(tapGestureRecognizer)
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
            button.contentHorizontalAlignment = .leading
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
            if abs(swipeView.frame.origin.x) < actionsContainerView.frame.size.width/2.5 {
                hideActions(animated: true)
            }
            else {
                showActions(animated: true, mode: swipeActionsViewMode)
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
    
    public func showActions(animated: Bool, mode: SwipeActionsViewMode = .right, completion:(()->Void)? = nil) {
        
        if actionButtons == nil || actionButtons?.count == 0 {
            configureActionButtons()
            actionsContainerView.layoutIfNeeded()
        }
        var cvFrame = swipeView.frame
        actionsProvider?.actionsState = mode
        
        
        let width = swipeActionsViewMode == .left ? actionsContainerView.frame.size.width : -actionsContainerView.frame.size.width
        cvFrame.origin.x = width
        UIView.animate(
        withDuration: 0.18,
        delay: 0.0,
        animations: { [weak self] in
            self?.swipeView.frame = cvFrame
        },
        completion: { finished in
            guard let completionHandler = completion else { return }
            completionHandler()
        })
    }
    
    public func hideActions(animated: Bool) {
        var cvFrame = swipeView.frame
        cvFrame.origin.x = orignalContentLocationX
        swipeActionsViewMode = .none
        actionsProvider?.actionsState = swipeActionsViewMode
        let animationDuration = animated ? 0.18 : 0
        
        UIView.animate(
        withDuration: animationDuration,
        delay: 0.0,
        animations: { [weak self] in
            self?.swipeView.frame = cvFrame
            
        },
        completion: { [weak self] finished in
            self?.resetActionsView()
        })
    }
    
    private func resetActionsView() {
        self.actionsStackView.removeAllArrangedSubviews()
        self.actionConfigurations?.removeAll()
        self.actionButtons?.removeAll()
    }
    
}

extension SwipeController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == panGestureRecognizer,
            let view = gestureRecognizer.view,
            let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = gestureRecognizer.translation(in: view)
            return abs(translation.y) <= abs(translation.x)
        }
        
        return true
    }
}
