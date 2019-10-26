//
//  Extensions.swift
//  kpiRozklad
//
//  Created by Denis on 9/26/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation
import UIKit

extension String {
  subscript(value: NSRange) -> Substring {
    return self[value.lowerBound..<value.upperBound]
  }
}

extension String {
  subscript(value: CountableClosedRange<Int>) -> Substring {
    get {
      return self[index(at: value.lowerBound)...index(at: value.upperBound)]
    }
  }

  subscript(value: CountableRange<Int>) -> Substring {
    get {
      return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
    }
  }

  subscript(value: PartialRangeUpTo<Int>) -> Substring {
    get {
      return self[..<index(at: value.upperBound)]
    }
  }

  subscript(value: PartialRangeThrough<Int>) -> Substring {
    get {
      return self[...index(at: value.upperBound)]
    }
  }

  subscript(value: PartialRangeFrom<Int>) -> Substring {
    get {
      return self[index(at: value.lowerBound)...]
    }
  }

  func index(at offset: Int) -> String.Index {
    return index(startIndex, offsetBy: offset)
  }
}

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
