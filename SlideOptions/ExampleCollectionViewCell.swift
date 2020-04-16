//
//  ExampleCollectionViewCell.swift
//  SlideOptions
//
//  Created by Ameya on 14/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

enum SwipeActionsViewMode {
    case none, left, right
}

protocol SwipableView {
    
}

struct SwipeActionConfiguration {

    var title: String?

    var backgroundColor: UIColor = .blue

    var image: UIImage?
}

protocol SwipableCollectionViewCellDelegate {
    func tableView(_ collectionView: UICollectionView,
    trailingSwipeActionConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
}

class ExampleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var collectionView: UICollectionView?
    private var actionsView = UIView()
    
    private var orignalLocation = CGPoint.zero
    private var orignalContentLocationX: CGFloat = 0
    
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadConstraint: NSLayoutConstraint!
    private var trailConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!
    
    private var swipeActionsViewMode = SwipeActionsViewMode.none
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        orignalContentLocationX = contentView.frame.origin.x
        
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.backgroundColor = .red
        self.insertSubview(actionsView, belowSubview: contentView)
        
        
        topConstraint = actionsView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor)
        bottomConstraint = actionsView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        leadConstraint = actionsView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor)
        trailConstraint = actionsView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor)
        widthConstraint = actionsView.widthAnchor.constraint(equalToConstant: 120)
        
        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            trailConstraint,
            widthConstraint
        ])
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gestureRecognizer:))))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(gestureRecognizer:))))
    }
    
    @objc func panGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        
        let velocity = gestureRecognizer.velocity(in: actionsView)
        if velocity.x > 0 { // Left
            
            if swipeActionsViewMode == .none {
                swipeActionsViewMode = .left
            }
            
            
            if contentView.frame.origin.x > orignalContentLocationX {
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
            
            if contentView.frame.origin.x < orignalContentLocationX {
                if leadConstraint.isActive {
                    NSLayoutConstraint.deactivate([leadConstraint])
                    NSLayoutConstraint.activate([trailConstraint])
                    swipeActionsViewMode = .right
                }
            }
        }
        
        
        switch gestureRecognizer.state {
        case .began:
            orignalLocation =  contentView.frame.origin
        case .changed :
            
            let newX = gestureRecognizer.translation(in: self).x
            var cvFrame = contentView.frame
            cvFrame.origin.x = newX + orignalLocation.x
            if abs(cvFrame.origin.x) < actionsView.frame.size.width {
                contentView.frame = cvFrame
            }
                
            
            
        case .ended, .cancelled, .failed:
            
            var cvFrame = contentView.frame
            if abs(contentView.frame.origin.x) < actionsView.frame.size.width/2.5 {
                    cvFrame.origin.x = orignalContentLocationX
                }
                else {
                    let width = swipeActionsViewMode == .left ? actionsView.frame.size.width : -actionsView.frame.size.width
                    cvFrame.origin.x = width
                }
            
            UIView.animate(withDuration: 0.18) {
                self.contentView.frame = cvFrame
            }
            
        default:
            break
        }
    }
    
    @objc func tapGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        swipeActionsViewMode = .none
        var cvFrame = contentView.frame
        cvFrame.origin.x = orignalContentLocationX
        UIView.animate(withDuration: 0.18) {
            self.contentView.frame = cvFrame
        }
    }
    
}
