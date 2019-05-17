//
//  UIKit+Extension.swift
//
//  Created by Yi Zhang on 2019/1/12.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

// MARK: 通过Storyboard加载

protocol StoryboardLoadable {}
extension StoryboardLoadable where Self: UIViewController
{
    static func loadStoryboard() -> Self {
        return UIStoryboard(name: "\(self)", bundle: nil).instantiateViewController(withIdentifier: "\(self)") as! Self
    }
}


// MARK: 通过xib文件加载

protocol NibLoadable {}
extension NibLoadable
{
    static func loadViewFromNib() -> Self {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.first as! Self
    }
}


// MARK: Tableview和Cell注册

protocol RegisterCellFromNib{}
extension RegisterCellFromNib
{
    static var identifier: String { return "\(self)" }
    static var nib: UINib? { return UINib(nibName: identifier, bundle: nil) }
}

extension UITableView
{
    func yi_registerCell<T: UITableViewCell>(cell: T.Type) where T:RegisterCellFromNib {
        if let nib = T.nib {
            register(nib, forCellReuseIdentifier: T.identifier)
        } else {
            register(cell, forCellReuseIdentifier: T.identifier)
        }
    }
    
    func yi_dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T:RegisterCellFromNib {
        return dequeueReusableCell(withIdentifier: T.identifier, for: IndexPath) as! T
    }
}


// MARK: CGRect和CGPoint扩展

extension CGRect
{
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale:CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
}

extension CGPoint
{
    func offsetBy(dx: CGFloat, dy:CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}


// MARK: UIView

extension UIView {
  func addSubview(
    _ subview: UIView,
    constrainedTo anchorsView: UIView, widthAnchorView: UIView? = nil,
    multiplier: CGFloat = 1
  ) {
    addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subview.centerXAnchor.constraint(equalTo: anchorsView.centerXAnchor),
      subview.centerYAnchor.constraint(equalTo: anchorsView.centerYAnchor),
      subview.widthAnchor.constraint(
        equalTo: (widthAnchorView ?? anchorsView).widthAnchor,
        multiplier: multiplier
      ),
      subview.heightAnchor.constraint(
        equalTo: anchorsView.heightAnchor,
        multiplier: multiplier
      )
    ])
  }

  func animateIn(handleCompletion: ( () -> Void )? = nil) {
    transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
    alpha = 0
    isHidden = false

    UIView.animate(
      withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 0.4,
      initialSpringVelocity: 0.5,
      animations: {
        self.alpha = 1
        self.transform = .identity
      },
      completion: handleCompletion.map { handleCompletion in
        { _ in handleCompletion() }
      }
    )
  }

  func roundCorners() {
    layer.cornerRadius = {
      let cardRadius = bounds.maxX / 6
      switch self {
      case is CardView, is CardSuperview:
        return cardRadius
      default:
        return cardRadius / 3
      }
    } ()
  }
}
