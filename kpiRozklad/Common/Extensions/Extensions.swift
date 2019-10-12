//
//  Extensions.swift
//  kpiRozklad
//
//  Created by Denis on 9/26/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation

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
