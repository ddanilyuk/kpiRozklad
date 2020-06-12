//
//  StringExtensions.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension String {
    
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound..<value.upperBound]
    }

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
    
    var stringTime: String {
        return String(self[0..<5])
    }
}


extension StringProtocol {
    
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
            }
        return result
    }
}
